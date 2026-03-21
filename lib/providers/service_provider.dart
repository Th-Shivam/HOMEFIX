import 'package:flutter/material.dart';
import '../models/service_request_model.dart';
import '../services/mock_api_service.dart';

/// Manages service request state for HomeFix Pro
class ServiceProvider extends ChangeNotifier {
  ServiceRequestModel? _currentRequest;
  bool _isLoading = false;

  ServiceRequestModel? get currentRequest => _currentRequest;
  bool get isLoading => _isLoading;
  bool get hasActiveRequest =>
      _currentRequest != null &&
      _currentRequest!.status != ServiceStatus.idle &&
      _currentRequest!.status != ServiceStatus.completed;

  /// Request a service (mock) — transitions through stages
  Future<void> requestService(ServiceType type) async {
    _isLoading = true;
    _currentRequest = ServiceRequestModel(
      serviceType: type,
      status: ServiceStatus.requested,
      requestTime: DateTime.now(),
    );
    notifyListeners();

    // Stage 1: Finding technician
    await Future.delayed(const Duration(seconds: 2));
    _currentRequest = _currentRequest!.copyWith(
      status: ServiceStatus.inProgress,
    );
    notifyListeners();

    // Stage 2: Technician assigned and on the way
    final result = await MockApiService.requestService(type);
    _currentRequest = result;
    _isLoading = false;
    notifyListeners();
  }

  /// Mark service as completed
  void completeService() {
    if (_currentRequest != null) {
      _currentRequest = _currentRequest!.copyWith(
        status: ServiceStatus.completed,
      );
      notifyListeners();
    }
  }

  /// Reset service request
  void resetRequest() {
    _currentRequest = null;
    _isLoading = false;
    notifyListeners();
  }
}
