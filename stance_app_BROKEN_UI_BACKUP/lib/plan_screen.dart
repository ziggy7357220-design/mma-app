// ============================================================
// Plan screen — weekly schedule, reschedule missed sessions.
// ============================================================

import 'package:flutter/material.dart';
import 'dart:math';

import 'data/plan.dart';
import 'workout_details_screen.dart';
import 'state.dart';
import 'theme.dart';
import 'design_system.dart';
import 'widgets/app_card.dart';
import 'widgets/section_header.dart';

class PlanScreen extends StatefulWidget {
  final AppState state;
  const PlanScreen({super.key, required this.state});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _reschedule() async {
    _refreshController.forward(from: 0.0);
    final newSchedule = PlanEngine.reschedule(
      widget.state.schedule,
      widget.state.profile,
      widget.state.profile.equipment.toSet(),
      random: Random(),
    );
    await widget.state.regenerateSchedule(newSchedule);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surfaceElevated,
        content: Text('Schedule refreshed', style: TextStyle(color: AppTheme.textPrimary)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Plan'),
        actions: [
          RotationTransition(
            turns: _refreshController,
            child: IconButton(
              onPressed: _reschedule,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reschedule',
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.m, AppSpacing.xxl),
        children: [
          SectionHeader(title: 'Your Path This Week'),
          ...widget.state.schedule.map((day) {
            final isToday = day.isToday;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: AppCard(
                radius: AppRadius.medium,
                backgroundColor: isToday ? AppTheme.accent.withOpacity(0.05) : null,
                border: Border.all(
                  color: isToday ? AppTheme.accent : AppTheme.border,
                  width: isToday ? 1.5 : 1,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          Text(
                            day.dayName.substring(0, 3).toUpperCase(),
                            style: AppTypography.label(context,
                              color: isToday ? AppTheme.accent : AppTheme.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isToday ? AppTheme.accent : AppTheme.border,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (day.type == 'training' && day.workout != null) ...[
                            Text(day.workout!.title,
                                style: AppTypography.title(context, size: 16)),
                            const SizedBox(height: 2),
                            Text(
                              '${day.duration ?? day.workout!.duration} min • ${day.workout!.difficulty}',
                              style: AppTypography.caption(context),
                            ),
                          ] else ...[
                            Text('Rest day',
                                style: AppTypography.title(context, size: 16)),
                            const SizedBox(height: 2),
                            Text('Recovery & mobility',
                                style: AppTypography.caption(context)),
                          ],
                        ],
                      ),
                    ),
                    if (day.type == 'training' && day.workout != null)
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => WorkoutDetailsScreen(
                              workout: day.workout!,
                              state: widget.state,
                            ),
                          ));
                        },
                        icon: Icon(Icons.play_circle_fill, color: AppTheme.accent, size: 36),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
