import 'package:flutter/material.dart';
import 'components/order_card.dart';
import 'components/order_status_tracker.dart';
import 'package:shop/services/supabase_service.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({
    super.key,
    required this.title,
    required this.status,
  });

  final String title;
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: SupabaseService.getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Filter orders by status
          final allOrders = snapshot.data ?? [];
          final orders = allOrders.where((o) {
            final oStatus = o['status'].toString().toLowerCase();
            final sStatus = status.name.toLowerCase();
            return oStatus == sStatus;
          }).toList();

          if (orders.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = order['order_items'] as List;

              // Convert items to mockProducts format for OrderCard
              final List<Map<String, dynamic>> products = items.map((item) {
                final p = item['products'];
                return {
                  "image": p['image_url'],
                  "brandName": p['brand_name'] ?? "Unknown",
                  "title": p['title'],
                  "price": (p['price'] as num).toDouble(),
                  "priceAfterDiscount": p['price_after_discount'] != null
                      ? (p['price_after_discount'] as num).toDouble()
                      : null,
                  "discountPercent": p['discount_percent'],
                };
              }).toList();

              return OrderCard(
                orderId: "#${order['id'].toString().substring(0, 8).toUpperCase()}",
                date: order['created_at'].toString().split('T')[0],
                status: status,
                products: products,
              );
            },
          );
        },
      ),
    );
  }
}
