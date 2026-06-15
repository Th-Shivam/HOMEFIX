/// Firestore collection paths.
abstract final class DbCollections {
  static const users = 'users';
  static const subscriptions = 'subscriptions';
  static const serviceRequests = 'service_requests';
  static const workers = 'workers';
  static const payments = 'payments';
  static const reviews = 'reviews';
  static const notifications = 'notifications';
  static const appConfig = 'app_config';
  static const counters = 'counters';
  static const statusHistory = 'status_history';
}

/// Subcollection / singleton document IDs.
abstract final class DbDocuments {
  static const pricing = 'pricing';
  static const serviceTickets = 'service_tickets';
}

/// Standard field names — single source of truth for reads/writes.
abstract final class DbFields {
  static const schemaVersion = 'schemaVersion';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
  static const isDeleted = 'isDeleted';

  // users
  static const uid = 'uid';
  static const name = 'name';
  static const email = 'email';
  static const phone = 'phone';
  static const photoUrl = 'photoUrl';
  static const address = 'address';
  static const authProvider = 'authProvider';
  static const role = 'role';
  static const onboardingCompleted = 'onboardingCompleted';
  static const fcmToken = 'fcmToken';
  static const lastLoginAt = 'lastLoginAt';

  // subscriptions
  static const userId = 'userId';
  static const mobile = 'mobile';
  static const alternateMobile = 'alternateMobile';
  static const planType = 'planType';
  static const amount = 'amount';
  static const currency = 'currency';
  static const subscriptionStartDate = 'subscriptionStartDate';
  static const subscriptionEndDate = 'subscriptionEndDate';
  static const paymentStatus = 'paymentStatus';
  static const paymentMethod = 'paymentMethod';
  static const paymentReference = 'paymentReference';
  static const autoRenew = 'autoRenew';
  static const cancelledAt = 'cancelledAt';
  static const cancelReason = 'cancelReason';

  // service_requests
  static const requestId = 'requestId';
  static const category = 'category';
  static const issueTitle = 'issueTitle';
  static const description = 'description';
  static const location = 'location';
  static const contactPhone = 'contactPhone';
  static const notes = 'notes';
  static const priority = 'priority';
  static const scheduledDate = 'scheduledDate';
  static const timeSlot = 'timeSlot';
  static const status = 'status';
  static const assignedWorkerId = 'assignedWorkerId';
  static const assignedWorkerName = 'assignedWorkerName';
  static const aiAnalysis = 'aiAnalysis';
  static const imageUrls = 'imageUrls';
  static const subscriptionActive = 'subscriptionActive';
  static const completedAt = 'completedAt';
  static const cancelReason = 'cancelReason';

  // workers
  static const workerId = 'workerId';
  static const type = 'type';
  static const skills = 'skills';
  static const rating = 'rating';
  static const ratingCount = 'ratingCount';
  static const serviceAreas = 'serviceAreas';
  static const available = 'available';
  static const linkedUserId = 'linkedUserId';
  static const verified = 'verified';

  // payments
  static const paymentId = 'paymentId';
  static const subscriptionId = 'subscriptionId';
  static const method = 'method';
  static const gatewayReference = 'gatewayReference';
  static const idempotencyKey = 'idempotencyKey';
  static const proofImageUrl = 'proofImageUrl';
  static const verifiedBy = 'verifiedBy';
  static const verifiedAt = 'verifiedAt';
  static const failureReason = 'failureReason';

  // counters
  static const lastNumber = 'lastNumber';
}

/// Current schema version written to all new documents.
const int kSchemaVersion = 1;
