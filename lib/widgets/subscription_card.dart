import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Premium subscription plan card with optional "Best Value" badge
class SubscriptionCard extends StatelessWidget {
  final String planName;
  final double price;
  final String duration;
  final String description;
  final bool isBestValue;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionCard({
    super.key,
    required this.planName,
    required this.price,
    required this.duration,
    required this.description,
    required this.onTap,
    this.isBestValue = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isBestValue
              ? const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isBestValue ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppConstants.accentOrange
                : isBestValue
                    ? Colors.transparent
                    : AppConstants.grey300,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isBestValue
                  ? AppConstants.primaryBlue.withAlpha(60)
                  : Colors.black.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan name
                Text(
                  planName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: isBestValue
                        ? Colors.white.withAlpha(200)
                        : AppConstants.grey600,
                  ),
                ),
                const SizedBox(height: 8),
                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${AppConstants.currencySymbol}${price.toInt()}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: isBestValue ? Colors.white : AppConstants.primaryBlue,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '/$duration',
                        style: TextStyle(
                          fontSize: 16,
                          color: isBestValue
                              ? Colors.white.withAlpha(180)
                              : AppConstants.grey600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isBestValue
                        ? Colors.white.withAlpha(220)
                        : AppConstants.grey600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Features
                _buildFeature('Unlimited service calls', isBestValue),
                const SizedBox(height: 6),
                _buildFeature('Priority technician assignment', isBestValue),
                const SizedBox(height: 6),
                _buildFeature('24/7 support', isBestValue),
                if (isBestValue) ...[
                  const SizedBox(height: 6),
                  _buildFeature('Save ₹${(AppConstants.monthlyPrice * 12 - AppConstants.yearlyPrice).toInt()}', true),
                ],
              ],
            ),
            // Best Value badge
            if (isBestValue)
              Positioned(
                top: -12,
                right: -8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppConstants.accentGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.accentOrange.withAlpha(100),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'BEST VALUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text, bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: isDark ? AppConstants.accentGold : AppConstants.successGreen,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withAlpha(230) : AppConstants.grey800,
          ),
        ),
      ],
    );
  }
}
