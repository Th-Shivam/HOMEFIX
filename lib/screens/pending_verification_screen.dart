import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_provider.dart';
import '../services/subscription_service.dart';

class PendingVerificationScreen extends StatefulWidget {
  const PendingVerificationScreen({super.key});

  @override
  State<PendingVerificationScreen> createState() => _PendingVerificationScreenState();
}

class _PendingVerificationScreenState extends State<PendingVerificationScreen> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    
    try {
      final paymentStatus = await SubscriptionService().getPaymentStatus();
      if (!mounted) return;

      if (paymentStatus == 'active' || paymentStatus == 'done') {
        // Sync with Firestore so UI updates accordingly
        await context.read<SubscriptionProvider>().syncWithFirestore();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your payment is still being verified. Please try again later.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verification Pending', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    size: 80,
                    color: Colors.orange.shade400,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Payment Under Verification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your payment is currently being manually verified by our team. This usually takes a little while.\n\nPlease check back soon to access your account.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isChecking ? null : _checkStatus,
                    icon: _isChecking 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        ) 
                      : const Icon(Icons.refresh),
                    label: Text(_isChecking ? 'Checking...' : 'Check Status Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
