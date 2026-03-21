/// Service types available in HomeFix Pro
enum ServiceType { electrician, plumber }

/// Status of a service request
enum ServiceStatus { idle, requested, inProgress, technicianOnWay, completed }

/// Service request model
class ServiceRequestModel {
  final ServiceType serviceType;
  final ServiceStatus status;
  final DateTime? requestTime;
  final String? technicianName;

  const ServiceRequestModel({
    required this.serviceType,
    this.status = ServiceStatus.idle,
    this.requestTime,
    this.technicianName,
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
      case ServiceStatus.idle:
        return 'Ready to request';
      case ServiceStatus.requested:
        return 'Finding a technician...';
      case ServiceStatus.inProgress:
        return 'Service in progress';
      case ServiceStatus.technicianOnWay:
        return 'Technician is on the way!';
      case ServiceStatus.completed:
        return 'Service completed';
    }
  }

  /// Create a copy with updated fields
  ServiceRequestModel copyWith({
    ServiceType? serviceType,
    ServiceStatus? status,
    DateTime? requestTime,
    String? technicianName,
  }) {
    return ServiceRequestModel(
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      requestTime: requestTime ?? this.requestTime,
      technicianName: technicianName ?? this.technicianName,
    );
  }
}
