import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/service_request_model.dart';
import '../providers/service_provider.dart';
import '../widgets/gradient_button.dart';

/// Service request screen with animated progress and technician-on-the-way UI
class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({super.key});

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Pulse animation for the progress indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Slide-in animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
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
        child: currentRequest == null || currentRequest.status == ServiceStatus.idle
            ? _buildServiceSelection(serviceProvider, routeArg)
            : _buildServiceProgress(serviceProvider, currentRequest),
      ),
    );
  }

  /// Initial screen — choose which service to call
  Widget _buildServiceSelection(ServiceProvider provider, String? preselected) {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppConstants.primaryBlue.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                size: 52,
                color: AppConstants.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Need a Professional?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppConstants.surfaceDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a service and we\'ll send a technician right away',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppConstants.grey600,
              ),
            ),
            const SizedBox(height: 40),

            // Call Electrician button
            _buildServiceButton(
              icon: Icons.electrical_services_rounded,
              title: 'Call Electrician',
              subtitle: 'Wiring, switches, appliance repair',
              color: const Color(0xFFFF6D00),
              isPreselected: preselected == 'electrician',
              onTap: () => provider.requestService(ServiceType.electrician),
            ),
            const SizedBox(height: 16),

            // Call Plumber button
            _buildServiceButton(
              icon: Icons.plumbing_rounded,
              title: 'Call Plumber',
              subtitle: 'Pipes, faucets, drainage & leaks',
              color: AppConstants.primaryBlue,
              isPreselected: preselected == 'plumber',
              onTap: () => provider.requestService(ServiceType.plumber),
            ),
            const SizedBox(height: 32),

            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.accentGold.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppConstants.accentGold.withAlpha(60)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppConstants.accentOrange, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Our technicians typically arrive within 30-45 minutes',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppConstants.grey800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Service-in-progress UI with animation
  Widget _buildServiceProgress(
      ServiceProvider provider, ServiceRequestModel request) {
    final isOnTheWay = request.status == ServiceStatus.technicianOnWay;
    final isInProgress = request.status == ServiceStatus.inProgress ||
        request.status == ServiceStatus.requested;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Animated icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isOnTheWay
                        ? AppConstants.successGreen.withAlpha(25)
                        : AppConstants.primaryBlue.withAlpha(25),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isOnTheWay
                                ? AppConstants.successGreen
                                : AppConstants.primaryBlue)
                            .withAlpha(30),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    isOnTheWay
                        ? Icons.directions_walk_rounded
                        : Icons.search_rounded,
                    size: 56,
                    color: isOnTheWay
                        ? AppConstants.successGreen
                        : AppConstants.primaryBlue,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Status text
          Text(
            request.statusText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppConstants.surfaceDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Service: ${request.serviceName}',
            style: const TextStyle(
              fontSize: 16,
              color: AppConstants.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),

          // Progress stages
          _buildProgressStage(
            'Service Requested',
            true,
            Icons.check_circle_rounded,
          ),
          _buildProgressConnector(true),
          _buildProgressStage(
            'Finding Technician',
            !isInProgress || isOnTheWay,
            isInProgress && !isOnTheWay
                ? Icons.hourglass_top_rounded
                : Icons.check_circle_rounded,
          ),
          _buildProgressConnector(!isInProgress || isOnTheWay),
          _buildProgressStage(
            'Technician On The Way',
            isOnTheWay,
            isOnTheWay
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
          ),

          // Technician info card
          if (isOnTheWay && request.technicianName != null) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
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
                      gradient: AppConstants.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        request.technicianName![0],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.technicianName!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.surfaceDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppConstants.accentGold, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '4.8 • ${request.serviceName}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppConstants.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppConstants.successGreen.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.call_rounded,
                      color: AppConstants.successGreen,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ETA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppConstants.successGreen.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppConstants.successGreen.withAlpha(50)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded,
                      color: AppConstants.successGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Estimated arrival: 30-45 minutes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.successGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),

          // Done / Back button
          if (isOnTheWay)
            GradientButton(
              text: 'Back to Home',
              icon: Icons.home_rounded,
              onPressed: () {
                provider.resetRequest();
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
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
              color: isPreselected
                  ? color.withAlpha(30)
                  : Colors.black.withAlpha(8),
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

  Widget _buildProgressStage(String label, bool isComplete, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: isComplete
                ? AppConstants.successGreen
                : AppConstants.grey300,
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isComplete ? FontWeight.w600 : FontWeight.w400,
              color: isComplete
                  ? AppConstants.surfaceDark
                  : AppConstants.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressConnector(bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(left: 45),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 3,
          height: 28,
          decoration: BoxDecoration(
            color: isActive
                ? AppConstants.successGreen
                : AppConstants.grey300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
