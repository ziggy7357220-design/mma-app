// ============================================================
// Profile screen — stats, achievements, settings, reset.
// ============================================================

import 'package:flutter/material.dart';

import 'data/content.dart';
import 'state.dart';
import 'theme.dart';
import 'achievements_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AppState state;
  const ProfileScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final arts = ContentLibrary.martialArts
        .where((a) => state.profile.martialArts.contains(a.id))
        .toList();
    final achievements = ContentLibrary.achievements;
    final unlocked = state.unlockedAchievements;
    final xpForNext = (state.level) * 100;
    final xpThisLevel = state.xp - ((state.level - 1) * 100);
    final progress = (xpThisLevel / 100).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Identity card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.accent, AppTheme.gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    state.profile.name.isNotEmpty
                        ? state.profile.name.substring(0, 1).toUpperCase()
                        : 'A',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(state.profile.name,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    )),
                Text('Level ${state.level} • ${_levelLabel(state.profile.level)}',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$xpThisLevel / 100 XP',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text('${xpForNext} XP to L${state.level + 1}',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppTheme.surfaceElevated,
                    valueColor: AlwaysStoppedAnimation(AppTheme.accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatBox(label: 'Streak', value: state.currentStreak.toString(), icon: '🔥')),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: 'Best', value: state.longestStreak.toString(), icon: '⚡')),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: 'Total XP', value: state.xp.toString(), icon: '⭐')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatBox(label: 'Workouts', value: state.workoutsCompleted.toString(), icon: '🥋')),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: 'Minutes', value: state.totalTrainingMinutes.toString(), icon: '⏱️')),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: 'Combos', value: state.combos.length.toString(), icon: '�')),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'My Disciplines'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: arts.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(a.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(a.name,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        )),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Achievements'),
          ...achievements.map((ach) {
            final got = unlocked.contains(ach.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: got ? AppTheme.accent.withOpacity(0.4) : AppTheme.border,
                    width: got ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(ach.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ach.name,
                              style: TextStyle(
                                color: got ? AppTheme.textPrimary : AppTheme.textMuted,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              )),
                          Text(ach.description,
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                    if (got)
                      Icon(Icons.check_circle, color: AppTheme.accent, size: 20)
                    else
                      Text('+${ach.xp} XP',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          )),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AchievementsScreen(state: state),
              )),
              child: Text('View All Achievements',
                  style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
          _ThemeToggle(state: state),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _confirmReset(context),
            icon: Icon(Icons.restart_alt, color: AppTheme.danger),
            label: Text('Reset All Data',
                style: TextStyle(color: AppTheme.danger)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.danger),
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Reset all data?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'This will erase your onboarding, XP, schedule, combos, and achievements. This cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Reset', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await state.resetAll();
    }
  }

  String _levelLabel(String level) {
    switch (level) {
      case 'beginner': return 'Beginner';
      case 'intermediate': return 'Intermediate';
      case 'advanced': return 'Advanced';
    }
    return level;
  }
}

class _ThemeToggle extends StatelessWidget {
  final AppState state;
  const _ThemeToggle({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ThemeMode>(
          value: state.themeMode,
          isExpanded: true,
          icon: Icon(Icons.palette, color: AppTheme.accent),
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
          items: const [
            DropdownMenuItem(value: ThemeMode.system, child: Text('System Mode')),
            DropdownMenuItem(value: ThemeMode.light, child: Text('Light Mode')),
            DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark Mode')),
          ],
          onChanged: (val) {
            if (val != null) state.setThemeMode(val);
          },
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _StatBox({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              )),
          Text(label,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                letterSpacing: 0.5,
              )),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

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
