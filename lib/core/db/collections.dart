/// Firestore collection paths — NIVASA schema v2.
abstract final class DbCollections {
  static const users = 'users';
  static const addresses = 'addresses';
  static const serviceCategories = 'service_categories';
  static const serviceRequests = 'service_requests';
  static const requestAssignments = 'request_assignments';
  static const requestImages = 'request_images';
  static const chatMessages = 'chat_messages';
  static const statusHistory = 'status_history';
  static const workers = 'workers';
  static const workerLocationTracking = 'worker_location_tracking';
  static const reviews = 'reviews';
  static const payments = 'payments';
  static const invoices = 'invoices';
  static const subscriptions = 'subscriptions';
  static const membershipPlans = 'membership_plans';
  static const notifications = 'notifications';
  static const emergencyContacts = 'emergency_contacts';
  static const supportTickets = 'support_tickets';
  static const appConfig = 'app_config';
  static const counters = 'counters';
}

abstract final class DbDocuments {
  static const pricing = 'pricing';
  static const serviceTickets = 'service_tickets';
}

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
  static const defaultAddressId = 'defaultAddressId';
  static const authProvider = 'authProvider';
  static const role = 'role';
  static const onboardingCompleted = 'onboardingCompleted';
  static const fcmToken = 'fcmToken';
  static const lastLoginAt = 'lastLoginAt';

  // addresses
  static const addressId = 'addressId';
  static const label = 'label';
  static const houseNumber = 'houseNumber';
  static const street = 'street';
  static const city = 'city';
  static const state = 'state';
  static const pincode = 'pincode';
  static const latitude = 'latitude';
  static const longitude = 'longitude';
  static const isDefault = 'isDefault';

  // service_categories
  static const categoryId = 'categoryId';
  static const icon = 'icon';
  static const isActive = 'isActive';
  static const sortOrder = 'sortOrder';

  // service_requests
  static const requestId = 'requestId';
  static const userId = 'userId';
  static const title = 'title';
  static const description = 'description';
  static const addressIdRef = 'addressId';
  static const contactPhone = 'contactPhone';
  static const priority = 'priority';
  static const status = 'status';
  static const scheduledAt = 'scheduledAt';
  static const timeSlot = 'timeSlot';
  static const requestedAt = 'requestedAt';
  static const completedAt = 'completedAt';
  static const cancelledAt = 'cancelledAt';
  static const estimatedCost = 'estimatedCost';
  static const finalCost = 'finalCost';
  static const notes = 'notes';
  static const aiAnalysis = 'aiAnalysis';
  static const activeAssignmentId = 'activeAssignmentId';
  static const invoiceId = 'invoiceId';
  static const subscriptionId = 'subscriptionId';

  // request_assignments
  static const assignmentId = 'assignmentId';
  static const assignedAt = 'assignedAt';
  static const assignedBy = 'assignedBy';
  static const unassignedAt = 'unassignedAt';
  static const remarks = 'remarks';

  // request_images
  static const imageId = 'imageId';
  static const imageUrl = 'imageUrl';
  static const uploadedBy = 'uploadedBy';
  static const uploadedAt = 'uploadedAt';
  static const imageType = 'type';

  // chat_messages
  static const messageId = 'messageId';
  static const senderId = 'senderId';
  static const senderRole = 'senderRole';
  static const message = 'message';
  static const sentAt = 'sentAt';
  static const messageStatus = 'status';

  // status_history
  static const entryId = 'entryId';
  static const fromStatus = 'fromStatus';
  static const toStatus = 'toStatus';
  static const changedBy = 'changedBy';
  static const changedByRole = 'changedByRole';

  // workers
  static const workerId = 'workerId';
  static const linkedUserId = 'linkedUserId';
  static const profilePhoto = 'profilePhoto';
  static const experience = 'experience';
  static const aadhaarVerified = 'aadhaarVerified';
  static const backgroundVerified = 'backgroundVerified';
  static const skills = 'skills';
  static const serviceAreas = 'serviceAreas';
  static const currentLocation = 'currentLocation';
  static const totalJobsCompleted = 'totalJobsCompleted';
  static const avgResponseTimeMinutes = 'avgResponseTimeMinutes';
  static const joinedAt = 'joinedAt';
  static const available = 'available';
  static const rating = 'rating';
  static const ratingCount = 'ratingCount';
  static const type = 'type';

  // worker_location_tracking
  static const trackingId = 'trackingId';
  static const timestamp = 'timestamp';

  // reviews
  static const reviewId = 'reviewId';
  static const comment = 'comment';

  // payments
  static const paymentId = 'paymentId';
  static const amount = 'amount';
  static const currency = 'currency';
  static const paymentGateway = 'paymentGateway';
  static const gatewayTransactionId = 'gatewayTransactionId';
  static const paidAt = 'paidAt';
  static const invoiceUrl = 'invoiceUrl';
  static const idempotencyKey = 'idempotencyKey';
  static const proofImageUrl = 'proofImageUrl';
  static const verifiedBy = 'verifiedBy';
  static const verifiedAt = 'verifiedAt';

  // invoices
  static const subtotal = 'subtotal';
  static const tax = 'tax';
  static const discount = 'discount';
  static const total = 'total';
  static const pdfUrl = 'pdfUrl';
  static const generatedAt = 'generatedAt';

  // subscriptions
  static const planId = 'planId';
  static const planType = 'planType';
  static const startDate = 'startDate';
  static const endDate = 'endDate';
  static const autoRenew = 'autoRenew';
  static const mobile = 'mobile';
  static const alternateMobile = 'alternateMobile';
  static const address = 'address';

  // membership_plans
  static const price = 'price';
  static const billingCycle = 'billingCycle';
  static const benefits = 'benefits';

  // emergency_contacts
  static const contactId = 'contactId';
  static const relation = 'relation';

  // support_tickets
  static const ticketId = 'ticketId';
  static const subject = 'subject';
  static const assignedTo = 'assignedTo';

  // notifications
  static const notificationId = 'notificationId';
  static const body = 'body';
  static const data = 'data';
  static const read = 'read';
  static const expiresAt = 'expiresAt';

  // legacy subscription fields (v1 compat)
  static const subscriptionStartDate = 'subscriptionStartDate';
  static const subscriptionEndDate = 'subscriptionEndDate';
  static const paymentStatus = 'paymentStatus';
  static const paymentMethod = 'paymentMethod';
  static const paymentReference = 'paymentReference';
  static const cancelReason = 'cancelReason';

  // legacy service_request fields (v1 compat)
  static const category = 'category';
  static const issueTitle = 'issueTitle';
  static const location = 'location';
  static const scheduledDate = 'scheduledDate';
  static const assignedWorkerId = 'assignedWorkerId';
  static const assignedWorkerName = 'assignedWorkerName';
  static const imageUrls = 'imageUrls';
  static const subscriptionActive = 'subscriptionActive';

  static const lastNumber = 'lastNumber';
}

/// Current schema version — v2 production marketplace schema.
const int kSchemaVersion = 2;
