// ============================================================
// Achievements Screen — track milestones and rewards.
// ============================================================

import 'package:flutter/material.dart';
import 'models/models.dart';
import 'state.dart';
import 'theme.dart';
import 'data/content.dart';

class AchievementsScreen extends StatelessWidget {
  final AppState state;
  const AchievementsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final allAchievements = ContentLibrary.achievements;
    final unlocked = state.unlockedAchievements;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const _SectionHeader(title: 'Unlocked'),
          ...allAchievements.where((a) => unlocked.contains(a.id)).map((a) => _AchievementTile(
                achievement: a,
                isUnlocked: true,
              )),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Locked'),
          ...allAchievements.where((a) => !unlocked.contains(a.id)).map((a) => _AchievementTile(
                achievement: a,
                isUnlocked: false,
              )),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  const _AchievementTile({required this.achievement, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(
          achievement.icon,
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          achievement.name,
          style: TextStyle(
            color: isUnlocked ? AppTheme.textPrimary : AppTheme.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          achievement.description,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: isUnlocked
            ? Icon(Icons.check_circle, color: AppTheme.success)
            : Icon(Icons.lock_outline, color: AppTheme.textMuted),
      ),
    );
  }
}
