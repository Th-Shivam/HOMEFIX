import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().signup(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await context.read<AuthProvider>().signInWithGoogle();

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  void _goToLogin() {
    context.read<AuthProvider>().clearError();
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const _RegistrationBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTitle(),
                                const SizedBox(height: 48),
                                if (authProvider.errorMessage != null) ...[
                                  _buildError(authProvider.errorMessage!),
                                  const SizedBox(height: 24),
                                ],
                                _buildGlassInput(
                                  label: 'FULL NAME',
                                  controller: _nameController,
                                  hintText: 'John Doe',
                                  icon: Icons.person_outline_rounded,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Required'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                _buildGlassInput(
                                  label: 'PHONE NUMBER',
                                  controller: _phoneController,
                                  hintText: '+1 XXX XXX XXXX',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Required'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                _buildGlassInput(
                                  label: 'RESIDENCE ID / EMAIL',
                                  controller: _emailController,
                                  hintText: 'name@domain.com',
                                  icon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Required'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                _buildGlassInput(
                                  label: 'SECURITY KEY',
                                  controller: _passwordController,
                                  hintText: '........',
                                  icon: _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  obscureText: _obscurePassword,
                                  onIconTap: () => setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  }),
                                  validator: (value) =>
                                      value == null || value.length < 6
                                          ? 'Min 6 chars'
                                          : null,
                                ),
                                const SizedBox(height: 40),
                                _buildActionButton(authProvider),
                                const SizedBox(height: 16),
                                _buildGoogleButton(authProvider),
                                const SizedBox(height: 24),
                                _buildRegistrationLinks(),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
          const _TopEdgeAccent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'NIVASA',
            style: GoogleFonts.raleway(
              fontSize: 11,
              fontWeight: FontWeight.w300,
              letterSpacing: 4.4,
              color: Colors.white.withAlpha(230),
            ),
          ),
          GestureDetector(
            onTap: _goToLogin,
            child: Row(
              children: [
                Text(
                  'SIGN IN',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: Colors.white.withAlpha(102),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_back_rounded,
                  size: 16,
                  color: Colors.white.withAlpha(102),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Begin Your Journey.',
          textAlign: TextAlign.center,
          style: GoogleFonts.raleway(
            fontSize: 34,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -0.5,
            shadows: const [
              Shadow(
                color: Colors.black54,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Create your residence profile.',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Colors.white.withAlpha(128),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withAlpha(20),
        border: Border.all(color: Colors.redAccent.withAlpha(50)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(
          fontSize: 12,
          color: Colors.red[200],
        ),
      ),
    );
  }

  Widget _buildActionButton(AuthProvider authProvider) {
    return GestureDetector(
      onTap: authProvider.isLoading ? null : _handleSubmit,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
          ),
          boxShadow: [
            const BoxShadow(
              color: Color(0x26FFFFFF),
              offset: Offset(0, 1),
              blurRadius: 0,
              blurStyle: BlurStyle.inner,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(153),
              offset: const Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: authProvider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'CREATE ACCOUNT',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.85,
                  color: Colors.white.withAlpha(230),
                ),
              ),
      ),
    );
  }

  Widget _buildGoogleButton(AuthProvider authProvider) {
    return GestureDetector(
      onTap: authProvider.isLoading ? null : _handleGoogleSignIn,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withAlpha(18),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.g_mobiledata_rounded,
              color: Colors.white.withAlpha(210),
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              'CONTINUE WITH GOOGLE',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: Colors.white.withAlpha(210),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationLinks() {
    return Column(
      children: [
        Text(
          'ALREADY HAVE AN ACCOUNT?',
          style: GoogleFonts.manrope(
            fontSize: 9,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
            color: Colors.white.withAlpha(76),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _goToLogin,
          child: Container(
            padding: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withAlpha(50),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'SIGN IN',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
                color: Colors.white.withAlpha(178),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Text(
        '(C) NIVASA MMXXIV',
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w300,
          letterSpacing: 3.6,
          color: Colors.white.withAlpha(76),
        ),
      ),
    );
  }

  Widget _buildGlassInput({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onIconTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
              color: Colors.white.withAlpha(102),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(12)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(7),
                    Colors.white.withAlpha(2),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      obscureText: obscureText,
                      keyboardType: keyboardType,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: GoogleFonts.manrope(
                          color: Colors.white.withAlpha(51),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isDense: true,
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        errorStyle: const TextStyle(height: 0),
                      ),
                      validator: validator,
                    ),
                  ),
                  GestureDetector(
                    onTap: onIconTap,
                    child: Icon(
                      icon,
                      color: Colors.white.withAlpha(76),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RegistrationBackground extends StatelessWidget {
  const _RegistrationBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/nivasa-login-blur.png',
          fit: BoxFit.cover,
        ),
        Opacity(
          opacity: 0.68,
          child: Image.asset(
            'assets/nivasa-login.png',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black,
                Colors.transparent,
                Colors.black.withAlpha(102),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Colors.transparent,
                Colors.black.withAlpha(128),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TopEdgeAccent extends StatelessWidget {
  const _TopEdgeAccent();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withAlpha(12),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
