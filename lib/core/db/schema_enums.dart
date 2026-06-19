/// Canonical enum string values stored in Firestore.
abstract final class DbEnums {
  // auth
  static const authEmail = 'email';
  static const authGoogle = 'google';

  // roles
  static const roleCustomer = 'customer';
  static const roleTechnician = 'technician';
  static const roleAdmin = 'admin';

  // subscription
  static const planMonthly = 'monthly';
  static const planYearly = 'yearly';

  static const paymentPending = 'pending';
  static const paymentActive = 'active';
  static const paymentDone = 'done'; // legacy
  static const paymentExpired = 'expired';
  static const paymentCancelled = 'cancelled';
  static const paymentRejected = 'rejected';

  static const methodUpiManual = 'upi_manual';
  static const methodRazorpay = 'razorpay';

  // service request priority
  static const priorityLow = 'low';
  static const priorityMedium = 'medium';
  static const priorityHigh = 'high';
  static const priorityEmergency = 'emergency';

  // service request status
  static const statusRequested = 'requested';
  static const statusFindingTechnician = 'finding_technician';
  static const statusAssigned = 'assigned';
  static const statusInProgress = 'in_progress';
  static const statusOnTheWay = 'on_the_way';
  static const statusCompleted = 'completed';
  static const statusCancelled = 'cancelled';

  // service categories
  static const categoryPlumbing = 'plumbing';
  static const categoryElectrical = 'electrical';
  static const categoryCleaning = 'cleaning';
  static const categoryInternetWifi = 'internet_wifi';
  static const categorySecurity = 'security';
  static const categoryApplianceRepair = 'appliance_repair';
  static const categoryWaterLeakage = 'water_leakage';
  static const categoryOther = 'other';

  // payment record status
  static const txnPending = 'pending';
  static const txnVerified = 'verified';
  static const txnFailed = 'failed';
  static const txnRefunded = 'refunded';

  // worker types
  static const workerPlumber = 'plumber';
  static const workerElectrician = 'electrician';
  static const workerGeneral = 'general';

  // notifications
  static const notifServiceUpdate = 'service_update';
  static const notifPayment = 'payment';
  static const notifSubscription = 'subscription';
  static const notifSystem = 'system';

  // assignment status
  static const assignmentActive = 'active';
  static const assignmentCompleted = 'completed';
  static const assignmentReassigned = 'reassigned';
  static const assignmentCancelled = 'cancelled';

  // image types
  static const imageBefore = 'before';
  static const imageAfter = 'after';
  static const imageInvoice = 'invoice';
  static const imageOther = 'other';

  // chat message status
  static const msgSent = 'sent';
  static const msgDelivered = 'delivered';
  static const msgRead = 'read';

  // subscription status (v2)
  static const subPending = 'pending';
  static const subActive = 'active';
  static const subExpired = 'expired';
  static const subCancelled = 'cancelled';

  // support ticket status
  static const supportOpen = 'open';
  static const supportInProgress = 'in_progress';
  static const supportResolved = 'resolved';
  static const supportClosed = 'closed';

  // payment gateways
  static const gatewayUpiManual = 'upi_manual';
  static const gatewayRazorpay = 'razorpay';
  static const gatewayStripe = 'stripe';

  /// Maps UI display labels from ServiceRequestScreen to DB values.
  static String categoryFromLabel(String label) {
    switch (label) {
      case 'Plumbing':
        return categoryPlumbing;
      case 'Electrical':
        return categoryElectrical;
      case 'Cleaning':
        return categoryCleaning;
      case 'Internet / WiFi':
        return categoryInternetWifi;
      case 'Security':
        return categorySecurity;
      case 'Appliance Repair':
        return categoryApplianceRepair;
      case 'Water Leakage':
        return categoryWaterLeakage;
      default:
        return categoryOther;
    }
  }

  static String priorityFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'low':
        return priorityLow;
      case 'medium':
        return priorityMedium;
      case 'high':
        return priorityHigh;
      case 'emergency':
        return priorityEmergency;
      default:
        return priorityMedium;
    }
  }

  /// Active subscription statuses (v2 status + legacy paymentStatus).
  static const activePaymentStatuses = [paymentActive, paymentDone, subActive];

  static bool isSubscriptionActive(String? status) {
    return status != null && activePaymentStatuses.contains(status);
  }
}
