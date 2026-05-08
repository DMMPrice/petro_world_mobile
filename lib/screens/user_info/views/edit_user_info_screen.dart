import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shop/services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class EditUserInfoScreen extends StatefulWidget {
  const EditUserInfoScreen({super.key});

  @override
  State<EditUserInfoScreen> createState() => _EditUserInfoScreenState();
}

class _EditUserInfoScreenState extends State<EditUserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  PhoneNumber _number = PhoneNumber(isoCode: 'IN');
  String? _selectedGender;
  
  String? _selectedCountryCode;
  String? _avatarUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await SupabaseService.getProfile();
    final user = SupabaseService.client.auth.currentUser;
    
    PhoneNumber? parsedNumber;
    if (profile != null && profile['phone_number'] != null && profile['phone_number'].toString().isNotEmpty) {
      try {
        parsedNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(profile['phone_number']);
      } catch (e) {
        parsedNumber = PhoneNumber(isoCode: 'IN', phoneNumber: profile['phone_number']);
      }
    }

    if (mounted) {
      setState(() {
        if (profile != null) {
          _nameController.text = "${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}".trim();
          
          // Handle DOB formatting from DB (YYYY-MM-DD) to UI (DD/MM/YYYY)
          if (profile['dob'] != null && profile['dob'].toString().isNotEmpty) {
            try {
              DateTime dbDate = DateTime.parse(profile['dob']);
              _dobController.text = DateFormat('dd/MM/yyyy').format(dbDate);
            } catch (e) {
              _dobController.text = profile['dob'];
            }
          } else {
            _dobController.text = '';
          }
          
          _phoneController.text = profile['phone_number'] ?? '';
          _selectedGender = profile['gender'];
          _avatarUrl = profile['avatar_url'];
          if (parsedNumber != null) _number = parsedNumber;
        }
        _emailController.text = user?.email ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _isLoading = true);
      try {
        String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.png';
        String? url;
        
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          url = await SupabaseService.uploadAvatar(bytes, fileName);
        } else {
          url = await SupabaseService.uploadAvatar(File(image.path), fileName);
        }
        
        if (url != null) {
          setState(() {
            _avatarUrl = url;
          });
          // Update profile immediately with new avatar URL
          await SupabaseService.updateProfile({'avatar_url': url});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error uploading image: $e")),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final names = _nameController.text.split(' ');
        final firstName = names.isNotEmpty ? names[0] : '';
        final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

        // Handle DOB formatting from UI (DD/MM/YYYY) to DB (YYYY-MM-DD)
        String? dbDob;
        if (_dobController.text.isNotEmpty) {
          try {
            DateTime uiDate = DateFormat('dd/MM/yyyy').parse(_dobController.text);
            dbDob = DateFormat('yyyy-MM-dd').format(uiDate);
          } catch (e) {
            dbDob = _dobController.text;
          }
        }

        await SupabaseService.updateProfile({
          'first_name': firstName,
          'last_name': lastName,
          'dob': dbDob,
          'phone_number': _phoneController.text,
          'gender': _selectedGender,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error updating profile: $e")),
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
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/info.svg",
              colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!, BlendMode.srcIn),
            ),
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  children: [
                    const SizedBox(height: defaultPadding),
                    EditAvatar(
                      avatarUrl: _avatarUrl,
                      onTap: _pickImage,
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            validator: (value) => value!.isEmpty ? "Name is required" : null,
                            decoration: InputDecoration(
                              hintText: "Full Name",
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(defaultPadding * 0.75),
                                child: SvgPicture.asset(
                                  "assets/icons/Profile.svg",
                                  height: 24,
                                  width: 24,
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7),
                                      BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          TextFormField(
                            controller: _emailController,
                            readOnly: true,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(defaultPadding * 0.75),
                                child: SvgPicture.asset(
                                  "assets/icons/Message.svg",
                                  height: 24,
                                  width: 24,
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7),
                                      BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            onTap: _selectDate,
                            decoration: InputDecoration(
                              hintText: "Date of birth",
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(defaultPadding * 0.75),
                                child: SvgPicture.asset(
                                  "assets/icons/Calender.svg",
                                  height: 24,
                                  width: 24,
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7),
                                      BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedGender,
                            items: ["Male", "Female", "Other"]
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedGender = value),
                            decoration: InputDecoration(
                              hintText: "Gender",
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(defaultPadding * 0.75),
                                child: Icon(Icons.person_outline, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber number) {
                              _number = number;
                              _phoneController.text = number.phoneNumber ?? '';
                            },
                            selectorConfig: const SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                              showFlags: false,
                            ),
                            ignoreBlank: false,
                            autoValidateMode: AutovalidateMode.disabled,
                            initialValue: _number,
                            formatInput: false,
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                            inputDecoration: InputDecoration(
                              hintText: "Phone Number",
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditAvatar extends StatelessWidget {
  const EditAvatar({
    super.key,
    this.avatarUrl,
    required this.onTap,
  });

  final String? avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null || avatarUrl!.isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            Positioned(
              right: -5,
              bottom: -5,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/Edit-Bold.svg",
                      height: 16,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: defaultPadding),
        TextButton(
          onPressed: onTap,
          child: const Text(
            "Edit photo",
            style: TextStyle(color: primaryColor),
          ),
        )
      ],
    );
  }
}
