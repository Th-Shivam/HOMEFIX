/// Service types available in HomeFix Pro

enum ServiceType { electrician, plumber }

enum TicketStatus {
  requestRaised,
  aiAnalysis,
  pendingReview,
  assigned,
  accepted,
  onTheWay,
  inProgress,
  waitingForParts,
  completed,
  customerVerification,
  closed,
  reopened,
}

enum SeverityLevel { low, medium, high, critical }

enum TicketActorRole { customer, system, reviewer, technician }

/// Service request / ticket model
class ServiceRequestModel {
  final ServiceType serviceType;
  final TicketStatus status;
  final DateTime? requestTime;
  final String? technicianName;
  final int? urgencyScore;
  final SeverityLevel? severityLevel;
  final String? aiSummary;
  final double? aiConfidence;
  final String? suggestedIssueCategory;
  final List<String> issueImages;
  final DateTime? aiAnalyzedAt;
  final Map<TicketStatus, DateTime> statusTimestamps;

  const ServiceRequestModel({
    required this.serviceType,
    this.status = TicketStatus.requestRaised,
    this.requestTime,
    this.technicianName,
    this.urgencyScore,
    this.severityLevel,
    this.aiSummary,
    this.aiConfidence,
    this.suggestedIssueCategory,
    this.issueImages = const [],
    this.aiAnalyzedAt,
    this.statusTimestamps = const {},
  });

  /// Human-readable service name
  String get serviceName {
    switch (serviceType) {
      case ServiceType.electrician:
        return 'Electrician';
      case ServiceType.plumber:
        return 'Plumber';
    }
  }

  /// Status description for UI
  String get statusText {
    switch (status) {
      case TicketStatus.requestRaised:
        return 'Request raised';
      case TicketStatus.aiAnalysis:
        return 'AI analyzing issue';
      case TicketStatus.pendingReview:
        return 'Pending support review';
      case TicketStatus.assigned:
        return 'Technician assigned';
      case TicketStatus.accepted:
        return 'Technician accepted';
      case TicketStatus.onTheWay:
        return 'Technician is on the way';
      case TicketStatus.inProgress:
        return 'Service in progress';
      case TicketStatus.waitingForParts:
        return 'Waiting for parts';
      case TicketStatus.completed:
        return 'Work completed';
      case TicketStatus.customerVerification:
        return 'Awaiting your verification';
      case TicketStatus.closed:
        return 'Ticket closed';
      case TicketStatus.reopened:
        return 'Ticket reopened';
    }
  }

  ServiceRequestModel copyWith({
    ServiceType? serviceType,
    TicketStatus? status,
    DateTime? requestTime,
    String? technicianName,
    int? urgencyScore,
    SeverityLevel? severityLevel,
    String? aiSummary,
    double? aiConfidence,
    String? suggestedIssueCategory,
    List<String>? issueImages,
    DateTime? aiAnalyzedAt,
    Map<TicketStatus, DateTime>? statusTimestamps,
  }) {
    return ServiceRequestModel(
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      requestTime: requestTime ?? this.requestTime,
      technicianName: technicianName ?? this.technicianName,
      urgencyScore: urgencyScore ?? this.urgencyScore,
      severityLevel: severityLevel ?? this.severityLevel,
      aiSummary: aiSummary ?? this.aiSummary,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      suggestedIssueCategory: suggestedIssueCategory ?? this.suggestedIssueCategory,
      issueImages: issueImages ?? this.issueImages,
      aiAnalyzedAt: aiAnalyzedAt ?? this.aiAnalyzedAt,
      statusTimestamps: statusTimestamps ?? this.statusTimestamps,
    );
  }
}

extension TicketStatusX on TicketStatus {
  String get wireValue {
    switch (this) {
      case TicketStatus.requestRaised:
        return 'REQUEST_RAISED';
      case TicketStatus.aiAnalysis:
        return 'AI_ANALYSIS';
      case TicketStatus.pendingReview:
        return 'PENDING_REVIEW';
      case TicketStatus.assigned:
        return 'ASSIGNED';
      case TicketStatus.accepted:
        return 'ACCEPTED';
      case TicketStatus.onTheWay:
        return 'ON_THE_WAY';
      case TicketStatus.inProgress:
        return 'IN_PROGRESS';
      case TicketStatus.waitingForParts:
        return 'WAITING_FOR_PARTS';
      case TicketStatus.completed:
        return 'COMPLETED';
      case TicketStatus.customerVerification:
        return 'CUSTOMER_VERIFICATION';
      case TicketStatus.closed:
        return 'CLOSED';
      case TicketStatus.reopened:
        return 'REOPENED';
    }
  }

  String get label => wireValue.replaceAll('_', ' ');
}

extension SeverityLevelX on SeverityLevel {
  String get label {
    switch (this) {
      case SeverityLevel.low:
        return 'LOW';
      case SeverityLevel.medium:
        return 'MEDIUM';
      case SeverityLevel.high:
        return 'HIGH';
      case SeverityLevel.critical:
        return 'CRITICAL';
    }
  }
}
