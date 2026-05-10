import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/providers.dart';
import 'components/address_card.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/services/supabase_service.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/checkout/views/payment_screen.dart';

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  String? _selectedAddressId;

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Addresses"),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, addNewAddressesScreenRoute);
              if (result == true) _refresh();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<AddressModel>>(
        future: SupabaseService.getAddresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined, size: 64, color: greyColor),
                  const SizedBox(height: defaultPadding),
                  Text("No addresses found", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: defaultPadding / 2),
                  const Text("Please add a delivery address to continue."),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, addNewAddressesScreenRoute);
                      if (result == true) _refresh();
                    },
                    child: const Text("Add New Address"),
                  ),
                ],
              ),
            );
          }

          // Auto-select default address if none selected
          if (_selectedAddressId == null && addresses.isNotEmpty) {
            final defaultAddr = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
            _selectedAddressId = defaultAddr.id;
          }

          return ListView.separated(
            padding: const EdgeInsets.all(defaultPadding),
            itemCount: addresses.length,
            separatorBuilder: (context, index) => const SizedBox(height: defaultPadding),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return AddressCard(
                name: address.name,
                address: "${address.address}, ${address.city}, ${address.state} - ${address.pincode}",
                phoneNumber: address.phoneNumber,
                isActive: _selectedAddressId == address.id,
                press: () {
                  setState(() {
                    _selectedAddressId = address.id;
                  });
                },
                onEdit: () async {
                  final result = await Navigator.pushNamed(
                    context, 
                    addNewAddressesScreenRoute, 
                    arguments: address
                  );
                  if (result == true) _refresh();
                },
                onDelete: () async {
                  final confirm = await _confirmDelete(context);
                  if (confirm == true) {
                    await SupabaseService.deleteAddress(address.id!);
                    _refresh();
                  }
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<List<AddressModel>>(
        future: SupabaseService.getAddresses(),
        builder: (context, snapshot) {
          final addresses = snapshot.data ?? [];
          if (addresses.isEmpty) return const SizedBox.shrink();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedAddressId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select an address"))
                    );
                    return;
                  }

                  final cartItems = ref.read(cartProvider).value ?? [];
                  if (cartItems.isEmpty) return;

                  final subtotal = cartItems.fold<double>(
                    0,
                    (sum, item) => sum + (item.product.price * item.quantity),
                  );
                  final productDiscount = cartItems.fold<double>(
                    0,
                    (sum, item) => sum + ((item.product.price - (item.product.priceAfterDiscount ?? item.product.price)) * item.quantity),
                  );
                  
                  final appliedCoupon = ref.read(couponProvider);
                  final shippingSettings = ref.read(shippingSettingsProvider);
                  double couponDiscount = 0.0;
                  if (appliedCoupon != null) {
                    if (appliedCoupon.type == 'percentage') {
                      couponDiscount = (subtotal - productDiscount) * (appliedCoupon.discount / 100);
                    } else {
                      couponDiscount = appliedCoupon.discount;
                    }
                  }

                  final totalAfterProductDiscount = subtotal - productDiscount;
                  final shippingFee = totalAfterProductDiscount > shippingSettings.threshold ? 0.0 : shippingSettings.fee;
                  final total = totalAfterProductDiscount + shippingFee - couponDiscount;

                  // Find the selected AddressModel to pass to PaymentScreen
                  final allAddresses = snapshot.data ?? [];
                  final selectedAddress = allAddresses.firstWhere(
                    (a) => a.id == _selectedAddressId,
                    orElse: () => allAddresses.first,
                  );

                  Navigator.pushNamed(
                    context,
                    paymentScreenRoute,
                    arguments: PaymentScreenArgs(
                      addressId: _selectedAddressId!,
                      address: selectedAddress,
                      cartItems: cartItems,
                      total: total,
                      subtotal: subtotal,
                      productDiscount: productDiscount,
                      couponId: appliedCoupon?.id,
                      couponDiscount: couponDiscount,
                    ),
                  );
                },
                child: const Text("Continue"),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Address"),
        content: const Text("Are you sure you want to delete this address? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
