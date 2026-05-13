import 'package:flutter_test/flutter_test.dart';
import 'package:homefix_pro/models/service_request_model.dart';
import 'package:homefix_pro/services/ticket_workflow_service.dart';

void main() {
  group('TicketWorkflowService', () {
    test('maps urgency score to severity by defined thresholds', () {
      expect(TicketWorkflowService.severityFromUrgency(20), SeverityLevel.low);
      expect(TicketWorkflowService.severityFromUrgency(50), SeverityLevel.medium);
      expect(TicketWorkflowService.severityFromUrgency(70), SeverityLevel.high);
      expect(TicketWorkflowService.severityFromUrgency(90), SeverityLevel.critical);
    });

    test('rejects invalid lifecycle transition', () async {
      final service = TicketWorkflowService();
      final ticket = ServiceRequestModel(
        serviceType: ServiceType.electrician,
        status: TicketStatus.requestRaised,
        statusTimestamps: {TicketStatus.requestRaised: DateTime.now()},
      );

      expect(
        () => service.transitionStatus(
          ticket: ticket,
          to: TicketStatus.completed,
          role: TicketActorRole.technician,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
