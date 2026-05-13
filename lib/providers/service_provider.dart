import 'package:flutter/material.dart';

import '../models/service_request_model.dart';
import '../services/ticket_workflow_service.dart';

/// Manages service request state for HomeFix Pro
class ServiceProvider extends ChangeNotifier {
  ServiceProvider({TicketWorkflowService? workflowService})
      : _workflowService = workflowService ?? TicketWorkflowService();

  final TicketWorkflowService _workflowService;

  ServiceRequestModel? _currentRequest;
  bool _isLoading = false;
  String? _lastError;

  ServiceRequestModel? get currentRequest => _currentRequest;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  bool get hasActiveRequest =>
      _currentRequest != null && _currentRequest!.status != TicketStatus.closed;

  Future<void> requestService(
    ServiceType type, {
    String? issueImageReference,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      var ticket = await _workflowService.createTicket(
        serviceType: type,
        issueImageReferences: issueImageReference == null || issueImageReference.isEmpty
            ? const []
            : [issueImageReference],
      );

      _currentRequest = ticket;
      notifyListeners();

      if (ticket.status == TicketStatus.pendingReview) {
        await Future.delayed(const Duration(milliseconds: 500));
        ticket = await _workflowService.transitionStatus(
          ticket: ticket,
          to: TicketStatus.assigned,
          role: TicketActorRole.reviewer,
        );
        _currentRequest = ticket.copyWith(
          technicianName: _pickTechnician(type),
        );
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 500));
        ticket = await _workflowService.transitionStatus(
          ticket: _currentRequest!,
          to: TicketStatus.accepted,
          role: TicketActorRole.technician,
        );
        _currentRequest = ticket;
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 500));
        _currentRequest = await _workflowService.transitionStatus(
          ticket: ticket,
          to: TicketStatus.onTheWay,
          role: TicketActorRole.technician,
        );
        notifyListeners();
      }
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(
    TicketStatus nextStatus, {
    required TicketActorRole role,
  }) async {
    final current = _currentRequest;
    if (current == null) return;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _currentRequest = await _workflowService.transitionStatus(
        ticket: current,
        to: nextStatus,
        role: role,
      );
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetRequest() {
    _currentRequest = null;
    _isLoading = false;
    _lastError = null;
    notifyListeners();
  }

  String _pickTechnician(ServiceType type) {
    final techNames = {
      ServiceType.electrician: ['Rajesh Kumar', 'Amit Sharma', 'Vikram Singh'],
      ServiceType.plumber: ['Suresh Patel', 'Mohan Das', 'Ravi Verma'],
    };
    final names = techNames[type] ?? ['Service Partner'];
    return names[DateTime.now().millisecond % names.length];
  }
}
