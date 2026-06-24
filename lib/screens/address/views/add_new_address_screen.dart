import 'package:flutter/material.dart';
import 'package:petro_world/constants.dart';
import 'package:petro_world/models/address_model.dart';
import 'package:petro_world/services/api_service.dart';
import 'package:petro_world/services/logistics_service.dart';

class AddNewAddressScreen extends StatefulWidget {
  final AddressModel? address;
  const AddNewAddressScreen({super.key, this.address});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.address?.name);
    _phoneController = TextEditingController(text: widget.address?.phoneNumber);
    _addressController = TextEditingController(text: widget.address?.address);
    _cityController = TextEditingController(text: widget.address?.city);
    _stateController = TextEditingController(text: widget.address?.state);
    _pincodeController = TextEditingController(text: widget.address?.pincode);
    _isDefault = widget.address?.isDefault ?? false;
    
    _pincodeController.addListener(_onPincodeChanged);
    super.initState();
  }

  void _onPincodeChanged() {
    if (_pincodeController.text.length == 6) {
      _lookupAddress(_pincodeController.text);
    }
  }

  Future<void> _lookupAddress(String pincode) async {
    final result = await LogisticsService().lookupPincode(pincode);
    if (result != null && mounted) {
      setState(() {
        _cityController.text = result['city'] ?? _cityController.text;
        _stateController.text = result['state'] ?? _stateController.text;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final address = AddressModel(
          id: widget.address?.id,
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          pincode: _pincodeController.text,
          isDefault: _isDefault,
        );

        if (widget.address == null) {
          await ApiService.instance.addAddress(address);
        } else {
          await ApiService.instance.updateAddress(address);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? "Add New Address" : "Edit Address"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Receiver Details", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
                validator: (val) => val!.isEmpty ? "Enter phone number" : null,
              ),
              const SizedBox(height: defaultPadding * 2),
              Text("Address Details", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Full Address (Street, Building, etc.)"),
                validator: (val) => val!.isEmpty ? "Enter address" : null,
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Pincode"),
                validator: (val) => val!.length != 6 ? "Enter valid 6-digit pincode" : null,
              ),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: "City"),
                      validator: (val) => val!.isEmpty ? "Enter city" : null,
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(labelText: "State"),
                      validator: (val) => val!.isEmpty ? "Enter state" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              SwitchListTile(
                title: const Text("Set as default address"),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: defaultPadding * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Save Address"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
