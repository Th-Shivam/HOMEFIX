// lib/widgets/subscription_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';

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
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF1A1A24).withOpacity(0.6) 
                    : const Color(0xFF0E0E12).withOpacity(0.4),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFBBC00).withOpacity(0.5)
                      : Colors.white.withOpacity(0.05),
                  width: isSelected ? 1.0 : 0.5,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        planName,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          letterSpacing: 2.4,
                          color: isSelected ? const Color(0xFFFBBC00) : const Color(0xFFA3A19E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isBestValue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBBC00).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFBBC00).withOpacity(0.3)),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 8,
                              letterSpacing: 1.5,
                              color: Color(0xFFFBBC00),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${price.toInt()}',
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 48,
                          fontWeight: FontWeight.w200,
                          color: Color(0xFFFBF8F4),
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/$duration',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: const Color(0xFFA3A19E).withOpacity(0.6),
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: const Color(0xFFA3A19E).withOpacity(0.8),
                      height: 1.6,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildFeature('Unlimited concierge requests', true),
                  const SizedBox(height: 16),
                  _buildFeature('Priority estate scheduling', isBestValue),
                  const SizedBox(height: 16),
                  _buildFeature('24/7 dedicated support', isBestValue),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String text, bool isIncluded) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          isIncluded ? Icons.check : Icons.close,
          size: 14,
          color: isIncluded ? const Color(0xFFFBBC00) : const Color(0xFFA3A19E).withOpacity(0.3),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: isIncluded ? const Color(0xE6FBF8F4) : const Color(0xFFA3A19E).withOpacity(0.4),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}
