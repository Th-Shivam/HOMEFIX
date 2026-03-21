import 'package:flutter/material.dart';
import '../core/constants.dart';

/// A visually rich card displaying a service (Electrician / Plumber)
class ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const ServiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [AppConstants.primaryBlue, AppConstants.primaryLight]
                : [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppConstants.primaryBlue.withAlpha(100)
                : AppConstants.grey300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppConstants.primaryBlue.withAlpha(50)
                  : Colors.black.withAlpha(15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withAlpha(50)
                    : AppConstants.primaryBlue.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isActive ? Colors.white : AppConstants.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppConstants.grey800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isActive
                    ? Colors.white.withAlpha(200)
                    : AppConstants.grey600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  isActive ? 'Call Now' : 'View Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppConstants.primaryBlue,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: isActive ? Colors.white : AppConstants.primaryBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
