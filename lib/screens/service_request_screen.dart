import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/service_request_model.dart';
import '../providers/service_provider.dart';
import '../services/ticket_workflow_service.dart';
import '../widgets/gradient_button.dart';

/// AI-powered service request ticket screen
class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({super.key});

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final TextEditingController _issueImageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.88, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _issueImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();
    final currentRequest = serviceProvider.currentRequest;
    final routeArg = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Service'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppConstants.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            serviceProvider.resetRequest();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: currentRequest == null
            ? _buildServiceSelection(serviceProvider, routeArg)
            : _buildTicketProgress(serviceProvider, currentRequest),
      ),
    );
  }

  Widget _buildServiceSelection(ServiceProvider provider, String? preselected) {
    final inputDecoration = InputDecoration(
      hintText: 'Optional issue image URL/path',
      filled: true,
      fillColor: Colors.white,
      prefixIcon: const Icon(Icons.image_outlined),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppConstants.primaryBlue.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 44,
              color: AppConstants.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Raise AI-Powered Ticket',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppConstants.surfaceDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload an issue image (optional) to trigger AI analysis and smarter prioritization.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppConstants.grey600),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _issueImageController,
            decoration: inputDecoration,
          ),
          const SizedBox(height: 20),
          _buildServiceButton(
            icon: Icons.electrical_services_rounded,
            title: 'Call Electrician',
            subtitle: 'Wiring, switches, appliance repair',
            color: const Color(0xFFFF6D00),
            isPreselected: preselected == 'electrician',
            onTap: () => provider.requestService(
              ServiceType.electrician,
              issueImageReference: _issueImageController.text.trim(),
            ),
          ),
          const SizedBox(height: 16),
          _buildServiceButton(
            icon: Icons.plumbing_rounded,
            title: 'Call Plumber',
            subtitle: 'Pipes, faucets, drainage & leaks',
            color: AppConstants.primaryBlue,
            isPreselected: preselected == 'plumber',
            onTap: () => provider.requestService(
              ServiceType.plumber,
              issueImageReference: _issueImageController.text.trim(),
            ),
          ),
          if (provider.isLoading) ...[
            const SizedBox(height: 18),
            const CircularProgressIndicator(),
          ],
          if (provider.lastError != null) ...[
            const SizedBox(height: 18),
            Text(
              provider.lastError!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTicketProgress(ServiceProvider provider, ServiceRequestModel ticket) {
    final trackerStatuses = _buildTrackerStatuses(ticket);
    final currentIndex = trackerStatuses.indexOf(ticket.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Center(
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryBlue.withAlpha(24),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.confirmation_number_rounded,
                    color: AppConstants.primaryBlue,
                    size: 46,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              ticket.statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppConstants.surfaceDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${ticket.serviceName} ticket • ${ticket.status.wireValue}',
              style: const TextStyle(
                fontSize: 13,
                color: AppConstants.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _buildAiAnalysisCard(ticket),
          const SizedBox(height: 16),
          _buildTimelineCard(ticket),
          const SizedBox(height: 16),
          _buildProgressTracker(trackerStatuses, currentIndex),
          const SizedBox(height: 18),
          _buildActions(provider, ticket),
          const SizedBox(height: 24),
          if (provider.isLoading) const Center(child: CircularProgressIndicator()),
          if (provider.lastError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                provider.lastError!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAiAnalysisCard(ServiceRequestModel ticket) {
    if (ticket.aiSummary == null) {
      return _buildCard(
        child: const Text(
          'No AI insights yet. Add an issue image during ticket creation to run AI analysis.',
          style: TextStyle(color: AppConstants.grey600),
        ),
      );
    }

    final severity = ticket.severityLevel;
    final urgency = ticket.urgencyScore ?? 0;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppConstants.primaryBlue),
              SizedBox(width: 8),
              Text(
                'AI Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.surfaceDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _badge('Urgency: $urgency', _urgencyColor(urgency)),
              if (severity != null) _badge('Severity: ${severity.label}', _severityColor(severity)),
              if (ticket.aiConfidence != null)
                _badge('Confidence: ${(ticket.aiConfidence! * 100).toStringAsFixed(0)}%', AppConstants.primaryBlue),
            ],
          ),
          const SizedBox(height: 10),
          if (ticket.suggestedIssueCategory != null)
            Text(
              'Suggested category: ${ticket.suggestedIssueCategory}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 6),
          Text(ticket.aiSummary!, style: const TextStyle(color: AppConstants.grey800)),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(ServiceRequestModel ticket) {
    final entries = ticket.statusTimestamps.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ticket Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppConstants.surfaceDark,
            ),
          ),
          const SizedBox(height: 12),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppConstants.successGreen,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.key.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    _formatDate(entry.value),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTracker(List<TicketStatus> statuses, int currentIndex) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lifecycle Tracker',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppConstants.surfaceDark,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final status = statuses[index];
                final isDone = index <= currentIndex;
                return Container(
                  width: 150,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDone ? AppConstants.successGreen.withAlpha(16) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDone ? AppConstants.successGreen : AppConstants.grey300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: isDone ? AppConstants.successGreen : AppConstants.grey600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        status.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ServiceProvider provider, ServiceRequestModel ticket) {
    switch (ticket.status) {
      case TicketStatus.onTheWay:
        return GradientButton(
          text: 'Start Work',
          icon: Icons.play_arrow_rounded,
          onPressed: () => provider.updateStatus(
            TicketStatus.inProgress,
            role: TicketActorRole.technician,
          ),
        );
      case TicketStatus.inProgress:
        return Column(
          children: [
            GradientButton(
              text: 'Waiting For Parts',
              icon: Icons.build_circle_outlined,
              onPressed: () => provider.updateStatus(
                TicketStatus.waitingForParts,
                role: TicketActorRole.technician,
              ),
            ),
            const SizedBox(height: 10),
            GradientButton(
              text: 'Complete Work',
              icon: Icons.task_alt_rounded,
              onPressed: provider.completeAndRequestVerification,
            ),
          ],
        );
      case TicketStatus.waitingForParts:
        return GradientButton(
          text: 'Resume Work',
          icon: Icons.refresh_rounded,
          onPressed: () => provider.updateStatus(
            TicketStatus.inProgress,
            role: TicketActorRole.technician,
          ),
        );
      case TicketStatus.customerVerification:
        return Column(
          children: [
            GradientButton(
              text: 'Close Ticket',
              icon: Icons.verified_rounded,
              onPressed: () => provider.updateStatus(
                TicketStatus.closed,
                role: TicketActorRole.customer,
              ),
            ),
            const SizedBox(height: 10),
            GradientButton(
              text: 'Reopen Ticket',
              icon: Icons.replay_rounded,
              onPressed: () => provider.updateStatus(
                TicketStatus.reopened,
                role: TicketActorRole.customer,
              ),
            ),
          ],
        );
      case TicketStatus.reopened:
        return GradientButton(
          text: 'Reassign Technician',
          icon: Icons.assignment_turned_in_rounded,
          onPressed: () => provider.updateStatus(
            TicketStatus.assigned,
            role: TicketActorRole.reviewer,
          ),
        );
      case TicketStatus.closed:
        return GradientButton(
          text: 'Back to Home',
          icon: Icons.home_rounded,
          onPressed: () {
            provider.resetRequest();
            Navigator.pop(context);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildServiceButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isPreselected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPreselected ? color : AppConstants.grey300,
            width: isPreselected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPreselected ? color.withAlpha(30) : Colors.black.withAlpha(8),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.surfaceDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppConstants.grey600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: color.withAlpha(150),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  List<TicketStatus> _buildTrackerStatuses(ServiceRequestModel ticket) {
    final stages = <TicketStatus>[
      TicketStatus.requestRaised,
      TicketStatus.aiAnalysis,
      TicketStatus.pendingReview,
      TicketStatus.assigned,
      TicketStatus.accepted,
      TicketStatus.onTheWay,
      TicketStatus.inProgress,
      TicketStatus.completed,
      TicketStatus.customerVerification,
      TicketStatus.closed,
    ];

    // Optional states are shown only if they happened (or are current) while
    // preserving the fixed baseline lifecycle ordering above.
    if (ticket.statusTimestamps.containsKey(TicketStatus.waitingForParts) ||
        ticket.status == TicketStatus.waitingForParts) {
      final completedIndex = stages.indexOf(TicketStatus.completed);
      if (completedIndex != -1) {
        stages.insert(completedIndex, TicketStatus.waitingForParts);
      }
    }
    if (ticket.statusTimestamps.containsKey(TicketStatus.reopened) ||
        ticket.status == TicketStatus.reopened) {
      final assignedIndex = stages.indexOf(TicketStatus.assigned);
      if (assignedIndex != -1 && !stages.contains(TicketStatus.reopened)) {
        stages.insert(assignedIndex, TicketStatus.reopened);
      }
    }
    return stages;
  }

  Color _urgencyColor(int urgency) {
    if (urgency > TicketWorkflowService.criticalUrgencyMinScore) {
      return Colors.red.shade700;
    }
    if (urgency > TicketWorkflowService.highUrgencyMinScore) {
      return Colors.deepOrange;
    }
    if (urgency > TicketWorkflowService.mediumUrgencyMinScore) {
      return Colors.amber.shade700;
    }
    return AppConstants.successGreen;
  }

  Color _severityColor(SeverityLevel level) {
    switch (level) {
      case SeverityLevel.low:
        return AppConstants.successGreen;
      case SeverityLevel.medium:
        return Colors.amber.shade700;
      case SeverityLevel.high:
        return Colors.deepOrange;
      case SeverityLevel.critical:
        return Colors.red.shade700;
    }
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}
