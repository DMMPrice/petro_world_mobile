import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'components/address_card.dart';

import 'package:shop/services/supabase_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  int _selectedAddressIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Addresses"),
        actions: [
          IconButton(
            onPressed: () {
              // Add new address logic
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: SupabaseService.getAddresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return const Center(child: Text("No addresses found"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(defaultPadding),
            itemCount: addresses.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: defaultPadding),
            itemBuilder: (context, index) => AddressCard(
              name: addresses[index]["name"] ?? "Station",
              address: addresses[index]["address"] ?? "No address",
              phoneNumber: addresses[index]["phone_number"] ?? "No phone",
              isActive: _selectedAddressIndex == index,
              press: () {
                setState(() {
                  _selectedAddressIndex = index;
                });
              },
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: ElevatedButton(
            onPressed: () {
              // Navigator.pushNamed(context, addNewAddressScreenRoute);
            },
            child: const Text("Add New Address"),
          ),
        ),
      ),
    );
  }
}
