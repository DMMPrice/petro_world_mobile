import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shop/constants.dart';

import 'package:shop/screens/order/views/components/order_status_tracker.dart';
import '../order_tracking_screen.dart';

/// Status config: color and label for each order status.
class _StatusStyle {
  final Color color;
  final Color bg;
  final String label;
  final IconData icon;
  const _StatusStyle(this.color, this.bg, this.label, this.icon);
}

const _statusStyles = <OrderStatus, _StatusStyle>{
  OrderStatus.ordered:        _StatusStyle(Color(0xFFD97706), Color(0xFFFFF7ED), 'New Order',   Icons.receipt_long_outlined),
  OrderStatus.processing:     _StatusStyle(Color(0xFF2563EB), Color(0xFFEFF6FF), 'Processing',  Icons.inventory_2_outlined),
  OrderStatus.packed:         _StatusStyle(Color(0xFF7C3AED), Color(0xFFF5F3FF), 'Packed',      Icons.inventory_outlined),
  OrderStatus.shipped:        _StatusStyle(Color(0xFF0284C7), Color(0xFFE0F2FE), 'Shipped',     Icons.local_shipping_outlined),
  OrderStatus.delivered:      _StatusStyle(Color(0xFF16A34A), Color(0xFFF0FDF4), 'Delivered',   Icons.check_circle_outline),
  OrderStatus.canceled:       _StatusStyle(Color(0xFFDC2626), Color(0xFFFEF2F2), 'Canceled',    Icons.cancel_outlined),
  OrderStatus.returned:       _StatusStyle(Color(0xFFEA580C), Color(0xFFFFF7ED), 'Returned',    Icons.assignment_return_outlined),
  OrderStatus.awaitingPayment:_StatusStyle(Color(0xFFCA8A04), Color(0xFFFEFCE8), 'Awaiting',   Icons.access_time_outlined),
};

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderId,           // internal DB uuid
    required this.orderNumber,       // PW-XXXXXXXXX
    required this.date,
    required this.status,
    required this.products,
    this.totalAmount,
    this.shiprocketOrderId,
    this.shipmentId,
    this.trackingNumber,
    this.invoiceUrl,
    this.courierName,
    this.courierStatus,
  });

  final String orderId;
  final String orderNumber;
  final String date;
  final OrderStatus status;
  final List<Map<String, dynamic>> products;
  final double? totalAmount;
  final String? shiprocketOrderId;
  final String? shipmentId;
  final String? trackingNumber;       // AWB number — null until Shiprocket assigns
  final String? invoiceUrl;
  final String? courierName;
  final String? courierStatus;

  bool get _hasAwb => trackingNumber != null && trackingNumber!.isNotEmpty;
  bool get _hasInvoice => invoiceUrl != null && invoiceUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyles[status] ?? _statusStyles[OrderStatus.processing]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderNumber,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: -0.3),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Placed on $date',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: style.bg, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(style.icon, size: 12, color: style.color),
                      const SizedBox(width: 4),
                      Text(style.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: style.color)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Shiprocket ID row (shown only if pushed) ─────────────
          if (shiprocketOrderId != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SR #$shiprocketOrderId',
                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (courierName != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        courierName!,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  if (courierStatus != null) ...[
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '· $courierStatus',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 20),
          ),

          // ── Product List ──────────────────────────────────────────
          ...products.take(2).map((product) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product['image'] != null
                          ? Image.network(
                              product['image'],
                              width: 52, height: 52, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['title'] ?? 'Product',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (product['brandName'] != null)
                            Text(product['brandName'], style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    Text(
                      '₹${(product['price'] as num?)?.toStringAsFixed(0) ?? '—'}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: primaryColor),
                    ),
                  ],
                ),
              )),

          if (products.length > 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                '+${products.length - 2} more item${products.length - 2 > 1 ? 's' : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),

          // ── Actions Row ───────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.12))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                if (totalAmount != null)
                  Expanded(
                    child: Text(
                      'Total ₹${totalAmount!.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                // Invoice button — only if label URL is available
                if (_hasInvoice)
                  TextButton.icon(
                    onPressed: () => _openUrl(context, invoiceUrl!),
                    icon: const Icon(Icons.download_outlined, size: 15),
                    label: const Text('Invoice'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                // Track Order — only if AWB is assigned
                if (_hasAwb)
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(
                          orderId:        orderId,
                          orderNumber:    orderNumber,
                          trackingNumber: trackingNumber!,
                          shipmentId:     shipmentId,
                          invoiceUrl:     invoiceUrl,
                          status:         status,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.location_on_outlined, size: 15),
                    label: const Text('Track Order'),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 22),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    // Use url_launcher
    try {
      final uri = Uri.parse(url);
      // ignore: deprecated_member_use
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open invoice URL')),
        );
      }
    }
  }
}

