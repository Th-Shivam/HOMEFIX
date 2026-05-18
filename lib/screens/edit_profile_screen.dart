import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _emailController = TextEditingController(text: user.email);
    // Assuming user might not have an address in the model, or using an empty string if not available
    _addressController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    // Implement save functionality logic here
    // e.g. updating the auth provider or firestore
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15161A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 110),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: Stack(
        children: [
          // Cinematic Background
          Positioned.fill(
            child: Image.asset(
              'assets/nivasa-homescreen.png',
              fit: BoxFit.cover,
              color: const Color(0xFF0A0A0C).withOpacity(0.5),
              colorBlendMode: BlendMode.srcOver,
            ),
          ),
          // Vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0A0A0C).withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // Vertical Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0A0C),
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xFF0A0A0C),
                  ],
                  stops: [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),
          // Main Content
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 80, bottom: 120, left: 24, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios, color: const Color(0xFFA3A19E).withOpacity(0.5), size: 12),
                          const SizedBox(width: 8),
                          Text(
                            'BACK',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 9,
                              letterSpacing: 3.6,
                              color: const Color(0xFFA3A19E).withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 36,
                        fontWeight: FontWeight.w200,
                        letterSpacing: 4.32,
                        color: Color(0xFFFBF8F4),
                        height: 1.2,
                        shadows: [
                          Shadow(color: Color(0x1AFBF8F4), blurRadius: 15),
                        ],
                      ),
                    ),
                    const SizedBox(height: 42),

                    // Form Fields inside a Glass Container
                    _buildGlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField('FULL NAME', _nameController, Icons.person_outline),
                          const SizedBox(height: 24),
                          _buildTextField('EMAIL ADDRESS', _emailController, Icons.email_outlined, isEmail: true),
                          const SizedBox(height: 24),
                          _buildTextField('PHONE NUMBER', _phoneController, Icons.phone_outlined, isPhone: true),
                          const SizedBox(height: 24),
                          _buildTextField('RESIDENCE ADDRESS', _addressController, Icons.location_on_outlined, maxLines: 3),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),

                    // Save Button
                    GestureDetector(
                      onTap: _saveProfile,
                      child: Container(
                        width: double.infinity,
                        height: 66,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.38)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.34),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.save_outlined,
                              color: Color(0xFFF2CA50),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'SAVE CHANGES',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                color: Color(0xFFF2CA50),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E12).withOpacity(0.4),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isEmail = false, bool isPhone = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10,
            letterSpacing: 2.0,
            color: const Color(0xFFA3A19E).withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16, top: maxLines > 1 ? 16 : 0),
                child: Icon(icon, color: Colors.white.withOpacity(0.3), size: 20),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: Color(0xFFFBF8F4),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: maxLines,
                  keyboardType: isEmail ? TextInputType.emailAddress : isPhone ? TextInputType.phone : TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Enter $label',
                    hintStyle: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(top: 40, left: 32, right: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0A0C).withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'NIVASA',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              letterSpacing: 6.4,
              color: Color(0xFFFBF8F4),
              fontWeight: FontWeight.w300,
              shadows: [
                Shadow(color: Color(0x1AFBF8F4), blurRadius: 15),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Usually goes to profile or home
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Center(
                child: Icon(
                  Icons.person_outline,
                  color: const Color(0xFFFBF8F4).withOpacity(0.4),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
