import 'package:flutter/material.dart';
import 'components/order_card.dart';
import 'components/order_status_tracker.dart';
import 'package:petro_world/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:petro_world/constants.dart' as constants;

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({
    super.key,
    required this.title,
    required this.status,
  });

  final String title;
  final OrderStatus status;

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiService.instance.getOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = ApiService.instance.getOrders();
    });
  }

  Future<void> _confirmCancel(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text('This order will move to your canceled orders.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: constants.errorColor),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiService.instance.cancelOrder(orderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order canceled successfully')),
      );
      _refreshOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to cancel order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allOrders = snapshot.data ?? [];

          // Filter by status group
          final orders = allOrders.where((o) {
            final String s = o['status'].toString().toLowerCase();
            if (widget.status == OrderStatus.processing) {
              return ['ordered', 'processing', 'packed', 'shipped'].contains(s);
            }
            return s == widget.status.name.toLowerCase();
          }).toList();

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined,
                      size: 64, color: constants.greyColor),
                  const SizedBox(height: constants.defaultPadding),
                  Text('No ${widget.title} orders',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = order['order_items'] as List? ?? [];

              final List<Map<String, dynamic>> products = items.map((item) {
                // orders query uses json_build_object(...'product', row_to_json(p.*))
                final p = (item['product'] ?? item['products'] ?? {})
                    as Map<String, dynamic>;
                final rawPrice = p['price'];
                final price = rawPrice is num
                    ? rawPrice.toDouble()
                    : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0;
                return {
                  'image': p['image_url'],
                  'brandName': p['brand_name'] ?? '',
                  'title': p['title'] ?? 'Product',
                  'price': price,
                };
              }).toList();

              String formattedDate = '';
              try {
                formattedDate = DateFormat('dd/MM/yyyy')
                    .format(DateTime.parse(order['created_at']));
              } catch (_) {
                formattedDate =
                    order['created_at']?.toString().split('T')[0] ?? '';
              }

              // Map DB status string â†’ OrderStatus enum
              OrderStatus currentStatus = widget.status;
              try {
                final s = order['status'].toString().toLowerCase();
                currentStatus = OrderStatus.values.firstWhere(
                  (e) => e.name.toLowerCase() == s,
                  orElse: () => widget.status,
                );
              } catch (_) {}

              return OrderCard(
                orderId: order['id'].toString(),
                orderNumber: order['order_number']?.toString() ??
                    '#${order['id'].toString().substring(0, 8).toUpperCase()}',
                date: formattedDate,
                status: currentStatus,
                products: products,
                totalAmount: () {
                  final raw = order['total_amount'];
                  if (raw == null) return null;
                  if (raw is num) return raw.toDouble();
                  return double.tryParse(raw.toString());
                }(),
                shiprocketOrderId: order['shiprocket_order_id']?.toString(),
                shipmentId: order['shipment_id']?.toString(),
                trackingNumber: order['tracking_number']?.toString(),
                invoiceUrl: order['shipping_label_url']?.toString(),
                courierName: order['courier_name']?.toString(),
                courierStatus: order['courier_status']?.toString(),
                onCancel: () => _confirmCancel(order['id'].toString()),
              );
            },
          );
        },
      ),
    );
  }
}
