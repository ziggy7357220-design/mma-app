// ============================================================
// Intro Screen — Value proposition and entry point.
// ============================================================

import 'package:flutter/material.dart';
import 'theme.dart';

class IntroScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const IntroScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Branding
            Text(
              'STANCE',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Precision. Discipline. Power.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            // Feature Highlights
            _buildFeature(
              icon: '🎯',
              title: 'Personalized Plans',
              desc: 'Custom workouts tailored to your goals and level.',
            ),
            const SizedBox(height: 24),
            _buildFeature(
              icon: '🥋',
              title: 'Martial Arts Library',
              desc: 'Comprehensive drills across multiple disciplines.',
            ),
            const SizedBox(height: 24),
            _buildFeature(
              icon: '📈',
              title: 'Track Progress',
              desc: 'Monitor your streak, XP, and skill evolution.',
            ),
            const SizedBox(height: 64),
            // Call to action
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'GET STARTED',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature({
    required String icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
