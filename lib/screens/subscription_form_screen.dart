import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'terms_conditions_screen.dart';

class SubscriptionFormScreen extends StatefulWidget {
  const SubscriptionFormScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionFormScreen> createState() => _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState extends State<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _altMobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void _submitForm() {
    // Validate form inputs
    if (_formKey.currentState!.validate()) {
      debugPrint('Navigation: Form Screen -> Terms Screen');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TermsConditionsScreen(
            name: _nameController.text.trim(),
            mobile: _mobileController.text.trim(),
            alternateMobile: _altMobileController.text.trim(),
            address: _addressController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light, clean background color
      appBar: AppBar(
        title: const Text(
          'Subscription Details',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87), // Dark back arrow
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Let\'s get started',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please fill in your details to continue the subscription.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // 1. Full Name Field
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'e.g. John Doe',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 2. Mobile Number Field
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: '10-digit mobile number',
                    prefixIcon: const Icon(Icons.phone_android),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    counterText: '', // Hides the 0/10 character counter
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (value.trim().length != 10) {
                      return 'Mobile number must be exactly 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 3. Alternate Mobile Number Field (Optional)
                TextFormField(
                  controller: _altMobileController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: 'Alternate Mobile Number (Optional)',
                    hintText: '10-digit alternate mobile number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    counterText: '',
                  ),
                  validator: (value) {
                    // It's optional, but if they enter something, it must be 10 digits
                    if (value != null &&
                        value.trim().isNotEmpty &&
                        value.trim().length != 10) {
                      return 'Alternate mobile number must be exactly 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 4. Full Address Field (Multi-line)
                TextFormField(
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.done,
                  maxLines: 3, // Allows typing multiple lines
                  decoration: InputDecoration(
                    labelText: 'Full Address',
                    hintText: 'House/Flat No., Street, Area, City, Pincode',
                    // Align the icon at the top of the multi-line textfield
                    prefixIcon: const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 14.0),
                          child: Icon(Icons.location_on_outlined),
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    alignLabelWithHint: true, // Fix label alignment for multi-line
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // 5. Continue Button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
