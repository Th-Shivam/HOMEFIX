import 'package:flutter/material.dart';
import 'payment_screen.dart';

class TermsConditionsScreen extends StatefulWidget {
  final String name;
  final String mobile;
  final String alternateMobile;
  final String address;

  const TermsConditionsScreen({
    Key? key,
    required this.name,
    required this.mobile,
    required this.alternateMobile,
    required this.address,
  }) : super(key: key);

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  // State for the checkbox
  bool _isAgreed = false;

  // The actual text content shown in the scrollable view
  final String _termsText = '''
Welcome to the HOMEFIX Subscription Service. 
By subscribing to our home services, you agree to the following terms and conditions:

1. Subscription Validity
Your subscription is valid for exactly one (1) year from the date of purchase.

2. Service Charges vs. Material Costs
The subscription covers only the service charge (labor cost) for standard plumbing and electrical repairs. All materials, spare parts, and specialized equipment required for the repair must be paid for separately by the customer.

3. Usage Scope
The subscription is explicitly limited to standard household usage at the registered address. It does not cover commercial properties, full-scale renovations, or industrial installations.

4. Fair Usage and Misuse
We reserve the right to flag accounts with abnormally high frequencies of requests. Deliberate misuse of the service, abusive behavior towards professionals, or sharing your subscription with unregistered households will lead to immediate cancellation of your subscription without refund.

5. Liability
HOMEFIX ensures professional service but is not liable for pre-existing structural damage or damages resulting from non-compliant third-party materials.

By proceeding, you acknowledge that you have read, understood, and agreed to these terms.
''';

  void _proceedToPayment() {
    if (_isAgreed) {
      debugPrint('Navigation: Terms Screen -> Payment Screen');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            name: widget.name,
            mobile: widget.mobile,
            alternateMobile: widget.alternateMobile,
            address: widget.address,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Scrollable Terms Text Container
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Text(
                      _termsText,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.5, // Improves reading clarity
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Checkbox and Agreement Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _isAgreed,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (bool? value) {
                      setState(() {
                        // Updates the state (changes checkbox look and enables button)
                        _isAgreed = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to the Terms & Conditions',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Proceed to Payment Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity, // Fills the width
                child: ElevatedButton(
                  // The button is disabled mathematically when onPressed is null.
                  // This happens automatically based on the `_isAgreed` state.
                  onPressed: _isAgreed ? _proceedToPayment : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.grey.shade500,
                    elevation: _isAgreed ? 2 : 0, // Flat when disabled
                  ),
                  child: const Text(
                    'Proceed to Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
