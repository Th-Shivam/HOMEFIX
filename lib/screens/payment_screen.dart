import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import 'subscription_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String name;
  final String mobile;
  final String alternateMobile;
  final String address;

  const PaymentScreen({
    Key? key,
    required this.name,
    required this.mobile,
    required this.alternateMobile,
    required this.address,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Prevent button spamming while saving
  bool _isProcessing = false;

  Future<void> _onPaymentComplete(BuildContext context) async {
    // 1. Start loading state and debug log
    debugPrint('Navigation: "I have paid" clicked - Starting Firestore save...');
    setState(() {
      _isProcessing = true;
    });

    try {
      // 2. Call service to save securely in Firestore
      // Added a timeout to forcefully unfreeze UI if Firebase connection drops/fails
      debugPrint('Navigation: Sending Data to Firestore: {name: ${widget.name}, mobile: ${widget.mobile}}');
      
      await SubscriptionService().saveSubscription(
        name: widget.name,
        mobile: widget.mobile,
        alternateMobile: widget.alternateMobile,
        address: widget.address,
        paymentStatus: 'pending', 
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        // This fires if Firebase hangs because of no internet or unauthenticated user
        throw Exception("Connection timed out. Please check your internet connection.");
      });

      debugPrint('Navigation: Successfully saved to Firestore!');

      // 3. Navigate to success screen if context matches
      if (context.mounted) {
        debugPrint('Navigation: Payment Screen -> Success Screen (Removing ALL previous routes)');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionSuccessScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // 4. Properly catch any exceptions (Firestore rules error, no auth, timeouts)
      debugPrint('Navigation [ERROR]: Failed to save subscription - $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // 5. Ensure button ALWAYS unlocks, even if an error is thrown
      if (mounted) {
        debugPrint('Navigation: Resetting Payment Processing State');
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Complete Payment',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Subscription Price Header
                const Text(
                  'Subscription Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '₹3600 / year', // Adjusted to match your modifications
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 48),

                // 2. Local QR Code from pubspec assets
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/qr.png', // Relies on you declaring it in pubspec.yaml
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('UI Warning: Could not find assets/qr.png rendering fallback');
                      return Container(
                        width: 220,
                        height: 220,
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 48),

                // 3. Instructions Text
                const Text(
                  'Scan the QR code with any UPI app to pay.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'After completing the transaction on your device, press the button below to verify your subscription.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // 4. "I have paid" Button with Loading State
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Disables button automatically when _isProcessing == true
                    onPressed: _isProcessing ? null : () => _onPaymentComplete(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'I have paid',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
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
