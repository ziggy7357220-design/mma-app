// ============================================================
// Home screen — today's training, streak, XP, jump-to-workout.
// ============================================================

import 'package:flutter/material.dart';

import 'data/content.dart';
import 'models/models.dart';
import 'workout_details_screen.dart';
import 'motivation_wall_screen.dart';
import 'data/motivation.dart';
import 'state.dart';
import 'theme.dart';
import 'design_system.dart';
import 'widgets/app_card.dart';
import 'widgets/stat_card.dart';
import 'widgets/section_header.dart';
import 'widgets/workout_card.dart';
import 'widgets/quote_card.dart';
import 'widgets/primary_button.dart';
import 'widgets/secondary_button.dart';
import 'achievements_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onStartWorkout;
  final VoidCallback onNavigatePlan;

  const HomeScreen({
    super.key,
    required this.state,
    required this.onStartWorkout,
    required this.onNavigatePlan,
  });

  ScheduledDay? _today() {
    final now = DateTime.now();
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final todayKey = days[now.weekday - 1];
    for (final d in state.schedule) {
      if (d.day == todayKey) return d;
    }
    return state.schedule.isNotEmpty ? state.schedule.first : null;
  }

  Map<String, String> _generateGreeting() {
    final hour = DateTime.now().hour;

    final pool = {
      'morning': [
        'Good morning',
        'Morning',
        'Rise and grind',
        'Ready for the morning session?',
      ],
      'afternoon': [
        'Good afternoon',
        'Afternoon',
        'Keep the momentum going',
        'Time for some midday work',
      ],
      'evening': [
        'Good evening',
        'Evening',
        'Time to wind down with training',
        'Ending the day strong',
      ],
    };

    final key = hour < 12 ? 'morning' : hour < 18 ? 'afternoon' : 'evening';
    final options = pool[key]!;

    final seed = DateTime.now().day;
    final greeting = options[seed % options.length];

    return {'text': greeting};
  }

  @override
  Widget build(BuildContext context) {
    final today = _today();
    final isTrainingDay = today != null && today.type == 'training';

    final greeting = _generateGreeting();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.m, AppSpacing.xxl),
        children: [
          // --- Greeting ---
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting['text']!,
                      style: AppTypography.caption(context, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.profile.name} 👋',
                      style: AppTypography.display(context, size: 26),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to sharpen your skills?',
                      style: AppTypography.body(context, size: 14),
                    ),
                  ],
                ),
              ),
              _ProfileButton(),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // --- Today's Training ---
          SectionHeader(
            title: 'Today\'s Training',
          ),
          WorkoutCard(
            workout: today?.workout,
            isFeatured: true,
            onTap: onStartWorkout,
          ),

          const SizedBox(height: AppSpacing.xl),

          // --- Your Progress ---
          SectionHeader(
            title: 'Your Progress',
          ),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Streak',
                  value: '${state.currentStreak}',
                  subtext: 'days',
                  accentColor: AppTheme.accent,
                  icon: Icons.local_fire_department,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: StatCard(
                  label: 'Workouts',
                  value: '${state.workoutsCompleted}',
                  subtext: 'completed',
                  accentColor: AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Training Time',
                  value: _formatMinutes(state.totalTrainingMinutes),
                  subtext: 'total',
                  accentColor: AppTheme.infoBlue,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: _LevelCard(state: state),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // --- This Week ---
          SectionHeader(
            title: 'This Week',
            subtitle: 'Your training path',
          ),
          _WeeklyActivityView(state: state),

          const SizedBox(height: AppSpacing.xl),

          // --- Recent Training ---
          SectionHeader(
            title: 'Recent Training',
          ),
          ..._buildRecentWorkouts(),

          const SizedBox(height: AppSpacing.xl),

          // --- Achievements ---
          SectionHeader(
            title: 'Achievements',
            trailing: TextButton(
              onPressed: () => _navigateToAchievements(context),
              child: Text('View all', style: AppTypography.label(context)),
            ),
          ),
          _AchievementsCarousel(state: state),

          const SizedBox(height: AppSpacing.xl),

          // --- Quote of the Day ---
          QuoteCard(
            text: MotivationLibrary.getQuoteOfDay().text,
            author: MotivationLibrary.getQuoteOfDay().author,
            onTap: () => _navigateToQuotes(context),
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  List<Widget> _buildRecentWorkouts() {
    if (state.workoutsCompleted == 0) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.l),
            child: Text('No training recorded yet.', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ];
    }

    return state.profile.martialArts.take(2).expand((artId) {
      final ws = ContentLibrary.workouts.where((w) => w.martialArt == artId).toList();
      if (ws.isEmpty) return <Widget>[];
      return [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: WorkoutCard(
            workout: ws.first,
            onTap: () => _openWorkout(context, ws.first),
          ),
        ),
      ];
    }).toList();
  }

  void _navigateToAchievements(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AchievementsScreen(state: state),
    ));
  }

  void _navigateToQuotes(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MotivationWallScreen(state: state),
    ));
  }

  void _openWorkout(BuildContext context, Workout w) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => WorkoutDetailsScreen(
        workout: w,
        state: state,
      ),
    ));
  }
}

class _ProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border),
      ),
      child: Icon(Icons.person_outline, color: AppTheme.textPrimary, size: 24),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final AppState state;
  const _LevelCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final xpToNext = 100 - (state.xp % 100);
    final progress = (state.xp % 100) / 100;

    return AppCard(
      radius: AppRadius.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEVEL ${state.level}',
            style: AppTypography.label(context, color: AppTheme.accent),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.xp} XP',
            style: AppTypography.display(context, size: 24),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.small / 2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$xpToNext XP to Level ${state.level + 1}',
            style: AppTypography.caption(context),
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityView extends StatelessWidget {
  final AppState state;
  const _WeeklyActivityView({required this.state});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return AppCard(
      radius: AppRadius.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Activity', style: AppTypography.title(context, size: 16)),
              Text(
                '${state.schedule.where((d) => d.type == 'training').length} planned',
                style: AppTypography.caption(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.border,
                      border: Border.all(color: AppTheme.accent.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Icon(Icons.circle, size: 6, color: AppTheme.accent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(day, style: AppTypography.caption(context)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AchievementsCarousel extends StatelessWidget {
  final AppState state;
  const _AchievementsCarousel({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.unlockedAchievements.isEmpty) {
      return const Center(
        child: Text('No achievements yet!', style: TextStyle(color: Colors.grey)),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.unlockedAchievements.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.m),
        itemBuilder: (context, index) {
          final id = state.unlockedAchievements[index];
          final achievement = ContentLibrary.achievements.firstWhere((a) => a.id == id);
          return AppCard(
            radius: AppRadius.medium,
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Text(achievement.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        achievement.title,
                        style: AppTypography.title(context, size: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        achievement.description,
                        style: AppTypography.caption(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
