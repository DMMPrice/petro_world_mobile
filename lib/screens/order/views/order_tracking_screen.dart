import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/supabase_service.dart';
import 'package:shop/screens/order/views/components/order_status_tracker.dart';
import 'package:intl/intl.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String orderNumber;
  final String trackingNumber;
  final String? shipmentId;
  final String? invoiceUrl;
  final OrderStatus status;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.trackingNumber,
    this.shipmentId,
    this.invoiceUrl,
    required this.status,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _loading = true;
  bool _actionLoading = false;
  String? _error;

  String _courierStatus = 'Fetching status…';
  String? _courierName;
  String? _labelUrl;
  List<Map<String, dynamic>> _activities = [];
  late OrderStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
    _labelUrl      = widget.invoiceUrl;
    _syncStatus();
  }

  Future<void> _syncStatus() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await SupabaseService.syncOrder(widget.orderId);
      if (result != null && mounted) {
        setState(() {
          _courierStatus = result['current_status']?.toString() ?? _courierStatus;
          _activities    = List<Map<String, dynamic>>.from(result['activities'] ?? []);
          if (result['label_url'] != null) _labelUrl = result['label_url'].toString();
          // Update status if changed
          final statusStr = _courierStatus.toLowerCase();
          if (statusStr.contains('deliver')) {
            _currentStatus = OrderStatus.delivered;
          } else if (statusStr.contains('cancel')) {
            _currentStatus = OrderStatus.canceled;
          } else if (statusStr.contains('transit') || statusStr.contains('ship') || statusStr.contains('delivery')) {
            _currentStatus = OrderStatus.shipped;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not refresh tracking. Showing cached data.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleCancel() async {
    final confirm = await _showConfirm(
      title: 'Cancel Order?',
      message: 'This will cancel your order${widget.trackingNumber.isNotEmpty ? ' and notify the courier' : ''}. This cannot be undone.',
      confirmLabel: 'Yes, Cancel',
      confirmColor: Colors.red,
    );
    if (!confirm) return;

    setState(() => _actionLoading = true);
    try {
      await SupabaseService.cancelOrder(widget.orderId);
      if (mounted) {
        setState(() => _currentStatus = OrderStatus.canceled);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully'), backgroundColor: Colors.red),
        );
        Navigator.pop(context, 'canceled');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _handleReturn() async {
    final confirm = await _showConfirm(
      title: 'Request Return?',
      message: 'We will arrange a pickup to collect the item(s). A return courier will contact you.',
      confirmLabel: 'Request Return',
      confirmColor: Colors.orange,
    );
    if (!confirm) return;

    setState(() => _actionLoading = true);
    try {
      await SupabaseService.requestReturn(widget.orderId);
      if (mounted) {
        setState(() => _currentStatus = OrderStatus.returned);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Return requested. We will contact you shortly.'), backgroundColor: Colors.orange),
        );
        Navigator.pop(context, 'returned');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to request return: $e')));
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<bool> _showConfirm({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Order')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmLabel, style: TextStyle(color: confirmColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _openInvoice() async {
    if (_labelUrl == null) return;
    try {
      await launchUrl(Uri.parse(_labelUrl!), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open invoice')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCancel = [OrderStatus.ordered, OrderStatus.processing].contains(_currentStatus);
    final canReturn = _currentStatus == OrderStatus.delivered;
    final hasInvoice = _labelUrl != null && _labelUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Track Order'),
        actions: [
          IconButton(
            onPressed: _syncStatus,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _actionLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Order Summary Card ──────────────────────────────
                  _buildSummaryCard(),
                  const SizedBox(height: defaultPadding),

                  // ── Error / refresh notice ──────────────────────────
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: defaultPadding),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!, style: const TextStyle(fontSize: 12, color: Colors.amber))),
                        ],
                      ),
                    ),

                  // ── Actions ─────────────────────────────────────────
                  if (hasInvoice || canCancel || canReturn) ...[
                    _buildActionsRow(canCancel: canCancel, canReturn: canReturn, hasInvoice: hasInvoice),
                    const SizedBox(height: defaultPadding),
                  ],

                  // ── Timeline ────────────────────────────────────────
                  if (_loading)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (_activities.isEmpty)
                    _buildNoTrackingYet()
                  else ...[
                    Text(
                      'Tracking History',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildTimeline(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.orderNumber,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.trackingNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('AWB copied to clipboard'), duration: Duration(seconds: 1)),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            'AWB: ${widget.trackingNumber}',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy_outlined, size: 12, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(_currentStatus).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _courierStatus,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(_currentStatus),
                  ),
                ),
              ),
            ],
          ),
          if (_courierName != null) ...[
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined, size: 18, color: primaryColor),
                const SizedBox(width: 8),
                Text(_courierName!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsRow({required bool canCancel, required bool canReturn, required bool hasInvoice}) {
    return Row(
      children: [
        if (hasInvoice)
          Expanded(
            child: _actionButton(
              label: 'View Invoice',
              icon: Icons.receipt_long_outlined,
              color: const Color(0xFF6366F1),
              onTap: _openInvoice,
            ),
          ),
        if (hasInvoice && (canCancel || canReturn)) const SizedBox(width: 8),
        if (canCancel)
          Expanded(
            child: _actionButton(
              label: 'Cancel Order',
              icon: Icons.cancel_outlined,
              color: Colors.red,
              onTap: _handleCancel,
            ),
          ),
        if (canReturn)
          Expanded(
            child: _actionButton(
              label: 'Return Item',
              icon: Icons.assignment_return_outlined,
              color: Colors.orange,
              onTap: _handleReturn,
            ),
          ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTrackingYet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text('Tracking not yet available', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            'Your order is confirmed and being processed. Tracking details will appear here once the courier picks up your package.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final act    = _activities[index];
          final isFirst = index == 0;
          final isLast  = index == _activities.length - 1;

          final String message  = act['activity']?.toString() ?? act['message']?.toString() ?? '';
          final String location = act['location']?.toString() ?? '';
          final String dateStr  = act['date']?.toString() ?? '';

          String formattedDate = '';
          try {
            formattedDate = DateFormat('dd MMM, hh:mm a').format(DateTime.parse(dateStr));
          } catch (_) {
            formattedDate = dateStr;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline line + dot
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 2,
                        height: 20,
                        color: isFirst ? Colors.transparent : Colors.grey.withValues(alpha: 0.2),
                      ),
                      Container(
                        width: isFirst ? 14 : 10,
                        height: isFirst ? 14 : 10,
                        decoration: BoxDecoration(
                          color: isFirst ? primaryColor : Colors.grey[300],
                          shape: BoxShape.circle,
                          boxShadow: isFirst
                              ? [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 2)]
                              : null,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: isLast ? 0 : 40,
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message,
                          style: TextStyle(
                            fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                            color: isFirst ? Colors.black87 : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (location.isNotEmpty) ...[
                              Icon(Icons.place_outlined, size: 11, color: Colors.grey[400]),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(location,
                                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (formattedDate.isNotEmpty)
                              Text(formattedDate, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered:  return const Color(0xFF16A34A);
      case OrderStatus.shipped:    return const Color(0xFF0284C7);
      case OrderStatus.canceled:   return const Color(0xFFDC2626);
      case OrderStatus.returned:   return const Color(0xFFEA580C);
      default:                     return primaryColor;
    }
  }
}
