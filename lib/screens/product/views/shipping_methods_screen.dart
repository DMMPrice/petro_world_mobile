import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants.dart';
import '../../../providers/providers.dart';

import 'package:intl/intl.dart';

class ShippingMethodsScreen extends ConsumerStatefulWidget {
  const ShippingMethodsScreen({super.key});

  @override
  ConsumerState<ShippingMethodsScreen> createState() => _ShippingMethodsScreenState();
}

class _ShippingMethodsScreenState extends ConsumerState<ShippingMethodsScreen> {
  final TextEditingController _pincodeController = TextEditingController();
  String _currentPincode = "";
  bool _hasChecked = false;

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  String _getEstimatedDate(int minDays, int maxDays) {
    final now = DateTime.now();
    final minDate = now.add(Duration(days: minDays));
    final maxDate = now.add(Duration(days: maxDays));

    final format = DateFormat('EEEE, MMM d');
    if (minDays == maxDays) {
      return format.format(minDate);
    }
    return "${format.format(minDate)} - ${format.format(maxDate)}";
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final estimateAsync = ref.watch(pincodeEstimateProvider(_currentPincode));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Shipping & Delivery",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Global Policy Card
            settingsAsync.when(
              data: (settings) => Container(
                width: double.infinity,
                margin: const EdgeInsets.all(defaultPadding),
                padding: const EdgeInsets.all(defaultPadding * 1.2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.05),
                      primaryColor.withOpacity(0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primaryColor.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome_outlined,
                              color: primaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Global Shipping Policy",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      settings['shipping_info'] ??
                          "PetroWorld Global Shipping: Standard delivery in 3-5 days. Free for orders over ₹1000.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.7),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 8),
              child: Divider(),
            ),

            // Pincode Checker Section
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Check Delivery Timeline",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your 6-digit pincode to get an accurate delivery date for your region.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  
                  // Pincode Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.location_on, color: primaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _pincodeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: "Enter Pincode",
                              border: InputBorder.none,
                              counterText: "",
                              hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.grey),
                            ),
                            onChanged: (val) {
                              if (val.length < 6 && _hasChecked) {
                                setState(() => _hasChecked = false);
                              }
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_pincodeController.text.length >= 3) {
                              setState(() {
                                _currentPincode = _pincodeController.text;
                                _hasChecked = true;
                              });
                              FocusScope.of(context).unfocus();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            minimumSize: const Size(0, 48), // Fix: Prevent infinite width in Row
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Check", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Result Area
                  if (_hasChecked)
                    estimateAsync.when(
                      data: (estimate) {
                        if (estimate == null) {
                          return _buildEstimateResult(
                            icon: Icons.error_outline_rounded,
                            color: Colors.red,
                            title: "Not Serviceable",
                            subtitle: "We're sorry, we don't deliver to this pincode yet.",
                            date: "Contact Support",
                          );
                        }

                        final bool isLive = estimate['is_live'] ?? false;
                        final String? etd = estimate['etd'];

                        return _buildEstimateResult(
                          icon: isLive ? Icons.speed_rounded : Icons.info_outline,
                          color: isLive ? Colors.green : Colors.blue,
                          title: estimate['description'] ?? "Standard Delivery",
                          subtitle: isLive ? "Live estimate from Shiprocket" : "Estimated timeframe for your region",
                          date: etd ?? _getEstimatedDate(estimate['min_days'], estimate['max_days']),
                          isLive: isLive,
                        );
                      },
                      loading: () => Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            const CircularProgressIndicator(strokeWidth: 2),
                            const SizedBox(height: 16),
                            Text("Consulting Shiprocket...", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                          ],
                        ),
                      ),
                      error: (e, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text("Connection issue. Please try again.", style: TextStyle(color: Colors.grey[600])),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimateResult({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String date,
    bool isLive = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (isLive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.withOpacity(0.2)),
                            ),
                            child: const Text(
                              "LIVE",
                              style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ESTIMATED ARRIVAL",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, color: color, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        date,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
