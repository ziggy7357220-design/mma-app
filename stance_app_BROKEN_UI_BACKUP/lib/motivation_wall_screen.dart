// ============================================================
// Motivation Wall — a visual space for progress and inspiration.
// ============================================================

import 'package:flutter/material.dart';
import 'state.dart';
import 'theme.dart';
import 'data/content.dart';
import 'data/motivation.dart';

class MotivationWallScreen extends StatelessWidget {
  final AppState state;
  const MotivationWallScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final String quoteText = state.favoriteQuotes.isNotEmpty
        ? state.favoriteQuotes.last
        : MotivationLibrary.quotes.first.text;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.surface, AppTheme.surfaceElevated],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('✨', style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 24),
                Text(
                  quoteText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 48),
                _StatRow(label: 'Current Level', value: 'L${state.level}'),
                _StatRow(label: 'Total XP', value: '${state.xp}'),
                _StatRow(label: 'Streak', value: '${state.currentStreak} Days'),
                _StatRow(label: 'Training Time', value: '${state.totalTrainingMinutes} Min'),
                const SizedBox(height: 48),
                Text('Top Achievements',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    )),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: state.unlockedAchievements.map((id) {
                    final ach = ContentLibrary.achievements.firstWhere(
                      (a) => a.id == id,
                      orElse: () => ContentLibrary.achievements.first,
                    );
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(ach.icon, style: const TextStyle(fontSize: 24)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 64),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('BACK TO JOURNEY'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          Text(value, style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
