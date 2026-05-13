import 'dart:async';

import '../models/service_request_model.dart';
import 'ai/ai_analysis_service.dart';
import 'media_storage_service.dart';

typedef TicketNotificationHook = FutureOr<void> Function(
  ServiceRequestModel ticket,
  TicketStatus from,
  TicketStatus to,
);

class TicketWorkflowService {
  TicketWorkflowService({
    AiAnalysisService? aiAnalysisService,
    TicketMediaStorageService? mediaStorageService,
    TicketNotificationHook? notificationHook,
  })  : _aiAnalysisService = aiAnalysisService ?? const MockAiAnalysisService(),
        _mediaStorageService = mediaStorageService ??
            const MockSecureMediaStorageService(),
        _notificationHook = notificationHook ?? _defaultNotificationHook;

  final AiAnalysisService _aiAnalysisService;
  final TicketMediaStorageService _mediaStorageService;
  final TicketNotificationHook _notificationHook;
  static const int criticalUrgencyMinScore = 85;
  static const int highUrgencyMinScore = 65;
  static const int mediumUrgencyMinScore = 40;

  static const Map<TicketStatus, Set<TicketStatus>> allowedTransitions = {
    TicketStatus.requestRaised: {TicketStatus.aiAnalysis},
    TicketStatus.aiAnalysis: {TicketStatus.pendingReview},
    TicketStatus.pendingReview: {TicketStatus.assigned},
    TicketStatus.assigned: {TicketStatus.accepted},
    TicketStatus.accepted: {TicketStatus.onTheWay},
    TicketStatus.onTheWay: {TicketStatus.inProgress},
    TicketStatus.inProgress: {
      TicketStatus.waitingForParts,
      TicketStatus.completed,
    },
    TicketStatus.waitingForParts: {TicketStatus.inProgress},
    TicketStatus.completed: {TicketStatus.customerVerification},
    TicketStatus.customerVerification: {
      TicketStatus.closed,
      TicketStatus.reopened,
    },
    TicketStatus.reopened: {TicketStatus.assigned},
    TicketStatus.closed: {},
  };

  static const Map<TicketActorRole, Set<TicketStatus>> roleTargets = {
    TicketActorRole.system: {
      TicketStatus.aiAnalysis,
      TicketStatus.pendingReview,
      TicketStatus.customerVerification,
    },
    TicketActorRole.reviewer: {TicketStatus.assigned},
    TicketActorRole.technician: {
      TicketStatus.accepted,
      TicketStatus.onTheWay,
      TicketStatus.inProgress,
      TicketStatus.waitingForParts,
      TicketStatus.completed,
    },
    TicketActorRole.customer: {
      TicketStatus.closed,
      TicketStatus.reopened,
    },
  };

  static SeverityLevel severityFromUrgency(int urgency) {
    if (urgency > criticalUrgencyMinScore) return SeverityLevel.critical;
    if (urgency > highUrgencyMinScore) return SeverityLevel.high;
    if (urgency > mediumUrgencyMinScore) return SeverityLevel.medium;
    return SeverityLevel.low;
  }

  Future<ServiceRequestModel> createTicket({
    required ServiceType serviceType,
    required List<String> issueImageReferences,
  }) async {
    final now = DateTime.now();
    var ticket = ServiceRequestModel(
      serviceType: serviceType,
      status: TicketStatus.requestRaised,
      requestTime: now,
      statusTimestamps: {TicketStatus.requestRaised: now},
    );

    if (issueImageReferences.isNotEmpty) {
      final secureImages =
          await _mediaStorageService.storeIssueImages(issueImageReferences);
      ticket = ticket.copyWith(issueImages: secureImages);
    }
    return runAiPipeline(ticket);
  }

  Future<ServiceRequestModel> runAiPipeline(ServiceRequestModel ticket) async {
    var updated = await transitionStatus(
      ticket: ticket,
      to: TicketStatus.aiAnalysis,
      role: TicketActorRole.system,
    );

    final aiResult = await _aiAnalysisService.analyzeIssue(
      serviceType: updated.serviceType,
      secureImageUris: updated.issueImages,
    );

    updated = updated.copyWith(
      urgencyScore: aiResult.urgencyScore,
      severityLevel: severityFromUrgency(aiResult.urgencyScore),
      suggestedIssueCategory: aiResult.suggestedIssueCategory,
      aiConfidence: aiResult.confidenceScore,
      aiSummary: aiResult.summary,
      aiAnalyzedAt: DateTime.now(),
    );

    return transitionStatus(
      ticket: updated,
      to: TicketStatus.pendingReview,
      role: TicketActorRole.system,
    );
  }

  Future<ServiceRequestModel> autoDispatchToOnTheWay({
    required ServiceRequestModel ticket,
    required String technicianName,
  }) async {
    if (ticket.status != TicketStatus.pendingReview) {
      return ticket;
    }

    final assigned = (await transitionStatus(
      ticket: ticket,
      to: TicketStatus.assigned,
      role: TicketActorRole.reviewer,
    ))
        .copyWith(technicianName: technicianName);

    final accepted = await transitionStatus(
      ticket: assigned,
      to: TicketStatus.accepted,
      role: TicketActorRole.technician,
    );

    return transitionStatus(
      ticket: accepted,
      to: TicketStatus.onTheWay,
      role: TicketActorRole.technician,
    );
  }

  Future<ServiceRequestModel> completeAndSendForCustomerVerification(
    ServiceRequestModel ticket,
  ) async {
    final completed = await transitionStatus(
      ticket: ticket,
      to: TicketStatus.completed,
      role: TicketActorRole.technician,
    );
    return transitionStatus(
      ticket: completed,
      to: TicketStatus.customerVerification,
      role: TicketActorRole.system,
    );
  }

  Future<ServiceRequestModel> transitionStatus({
    required ServiceRequestModel ticket,
    required TicketStatus to,
    required TicketActorRole role,
  }) async {
    final from = ticket.status;
    if (!_canTransition(from, to)) {
      throw StateError('Invalid transition from ${from.label} to ${to.label}');
    }
    if (!(roleTargets[role]?.contains(to) ?? false)) {
      throw StateError('Role ${role.name} cannot move ticket to ${to.label}');
    }

    final timestamps = Map<TicketStatus, DateTime>.from(ticket.statusTimestamps)
      ..[to] = DateTime.now();
    final updated = ticket.copyWith(status: to, statusTimestamps: timestamps);
    await _notificationHook(updated, from, to);
    return updated;
  }

  bool _canTransition(TicketStatus from, TicketStatus to) {
    return allowedTransitions[from]?.contains(to) ?? false;
  }

  static Future<void> _defaultNotificationHook(
    ServiceRequestModel ticket,
    TicketStatus from,
    TicketStatus to,
  ) async {
    // Notification integration hook for push/SMS/email providers.
    await Future<void>.delayed(Duration.zero);
    // ignore: avoid_print
    print('Ticket ${ticket.serviceName}: ${from.wireValue} -> ${to.wireValue}');
  }
}
