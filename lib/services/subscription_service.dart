import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates or updates a subscription for the currently logged-in user.
  /// Prevents duplication by using the user's exact UID as the document ID.
  Future<void> saveSubscription({
    required String name,
    required String mobile,
    required String alternateMobile,
    required String address,
    required String paymentStatus, // Should be "pending" or "done"
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('You cannot save a subscription without being logged in.');
    }

    final String uid = currentUser.uid;

    // Calculate dates
    final DateTime startDate = DateTime.now();
    // Valid for exactly 1 year from local time
    final DateTime endDate = DateTime(
      startDate.year + 1,
      startDate.month,
      startDate.day,
      startDate.hour,
      startDate.minute,
    );

    // Using the user's UID as the document ID explicitly prevents duplicate
    // documents from being created if they try to subscribe again.
    final subscriptionRef = _firestore.collection('subscriptions').doc(uid);

    await subscriptionRef.set({
      'userId': uid,
      'email': currentUser.email ?? 'No email',
      'name': name.trim(),
      'mobile': mobile.trim(),
      'alternateMobile': alternateMobile.trim(),
      'address': address.trim(),
      // Use Firebase server time for the exact insertion time to avoid spoofing
      'subscriptionStartDate': FieldValue.serverTimestamp(),
      // Send the calculated 1-year end date
      'subscriptionEndDate': Timestamp.fromDate(endDate),
      'paymentStatus': paymentStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // Merge ensures we safely update if it already exists
  }

  /// Gets the current payment status for the logged-in user.
  /// Returns null if no subscription exists.
  Future<String?> getPaymentStatus() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final doc = await _firestore.collection('subscriptions').doc(currentUser.uid).get();
      if (doc.exists) {
        return doc.data()?['paymentStatus'] as String?;
      }
    } catch (_) {
      // Ignore error and return null if unavailable
    }
    return null;
  }
}
