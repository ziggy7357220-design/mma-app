// ============================================================
// Workout Details Screen — premium overview and entry point.
// Implements a hero header, session grouping, and interactive cards.
// ============================================================

import 'package:flutter/material.dart';

import 'models/models.dart';
import 'player.dart';
import 'state.dart';
import 'theme.dart';
import 'design_system.dart';
import 'workout_complete_screen.dart';
import 'widgets/app_card.dart';
import 'widgets/primary_button.dart';
import 'widgets/secondary_button.dart';
import 'widgets/section_header.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final Workout workout;
  final AppState state;

  const WorkoutDetailsScreen({
    super.key,
    required this.workout,
    required this.state,
  });

  void _startStandard(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => WorkoutPlayer(
        workout: workout,
        onComplete: (actualSeconds) async {
          final scheduledSeconds = workout.duration * 60;
          final ratio = scheduledSeconds == 0 ? 0.0 : actualSeconds / scheduledSeconds;
          final isMeaningful = ratio >= AppState.meaningfulCompletionThreshold;

          await state.recordSession(
            workoutId: workout.id,
            actualTrainedSeconds: actualSeconds,
            scheduledSeconds: scheduledSeconds,
          );

          if (context.mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => WorkoutCompleteScreen(
                workoutTitle: workout.title,
                trainedSeconds: actualSeconds,
                isMeaningful: isMeaningful,
                state: state,
              ),
            ));
          }
        },
      ),
    ));
  }

  void _startCustomized(BuildContext context, CustomizedWorkout customized) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => WorkoutPlayer(
        workout: workout,
        customizedWorkout: customized,
        onComplete: (actualSeconds) async {
          final scheduledSeconds = customized.totalDurationSeconds;
          final ratio = scheduledSeconds == 0 ? 0.0 : actualSeconds / scheduledSeconds;
          final isMeaningful = ratio >= AppState.meaningfulCompletionThreshold;

          await state.recordSession(
            workoutId: workout.id,
            actualTrainedSeconds: actualSeconds,
            scheduledSeconds: scheduledSeconds,
          );

          if (context.mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => WorkoutCompleteScreen(
                workoutTitle: workout.title,
                trainedSeconds: actualSeconds,
                isMeaningful: isMeaningful,
                state: state,
              ),
            ));
          }
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildHeroHeader(context),
              _buildWorkoutContent(context),
            ],
          ),
          bottomNavigationBar: _buildActionBar(context),
        );
      },
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.background,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accent.withOpacity(0.1),
                AppTheme.background,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.l, 80, AppSpacing.l, AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.martialArt.toUpperCase(),
                  style: AppTypography.label(context, color: AppTheme.accent),
                ),
                const SizedBox(height: 8),
                Text(
                  workout.title,
                  style: AppTypography.display(context, size: 32),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoPill(label: workout.difficulty),
                    const SizedBox(width: 8),
                    _InfoPill(label: '${workout.duration} min'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutContent(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.m, 120),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          SectionHeader(
            title: 'About this Session',
          ),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Text(
              workout.description,
              style: AppTypography.body(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'Session Details',
          ),
          Row(
            children: [
              Expanded(child: _DetailTile(label: 'Duration', value: '${workout.duration} min')),
              Expanded(child: _DetailTile(label: 'Exercises', value: '${workout.exercises.length}')),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(child: _DetailTile(label: 'Mode', value: 'Solo')),
              Expanded(child: _DetailTile(label: 'Equipment', value: 'None')),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'What you\'ll train',
          ),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              children: [
                ..._extractTrainingPoints().map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: AppTheme.accent, size: 18),
                      const SizedBox(width: 8),
                      Text(point, style: AppTypography.body(context)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'Exercises',
          ),
          ...workout.exercises.map((e) => _ExerciseCard(exercise: e, onTap: () => _showExerciseDetail(context, e))),
        ]),
      ),
    );
  }

  List<String> _extractTrainingPoints() {
    // In a real app, we'd have a 'focus_points' list in the workout model.
    // Here we'll generate a few based on the category/martial art.
    if (workout.category.toLowerCase().contains('footwork')) {
      return ['Pivot mechanics', 'Distance control', 'Angle creation', 'Balance'];
    }
    if (workout.martialArt == 'boxing') {
      return ['Hand speed', 'Guard maintenance', 'Hip rotation', 'Precision'];
    }
    return ['Technique refinement', 'Muscle memory', 'Intensity', 'Focus'];
  }

  Widget _buildActionBar(BuildContext context) {
    return BottomAppBar(
      color: AppTheme.surface,
      elevation: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
          child: Row(
            children: [
              _AudioToggle(
                icon: Icons.music_note,
                label: 'Music',
                isActive: state.musicEnabled,
                onToggled: state.toggleMusic,
              ),
              const SizedBox(width: AppSpacing.s),
              _AudioToggle(
                icon: Icons.volume_up,
                label: 'Voice',
                isActive: state.voiceEnabled,
                onToggled: state.toggleVoice,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: SecondaryButton(
                  label: 'Customize',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => WorkoutCustomizeScreen(
                      workout: workout,
                      onConfirm: (customized) => _startCustomized(context, customized),
                    ),
                  )),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: PrimaryButton(
                  label: 'Start',
                  onPressed: () => _startStandard(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseDetail(BuildContext context, ExerciseStep step) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.l, 32, AppSpacing.l, 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                step.name,
                style: AppTypography.display(context, size: 24),
              ),
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${step.duration}s ${step.isRest ? '(Rest)' : ''}',
                    style: AppTypography.caption(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              if (step.description != null) ...[
                Text(
                  'Instructions',
                  style: AppTypography.title(context, size: 16),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  step.description!,
                  style: AppTypography.body(context),
                ),
                const SizedBox(height: AppSpacing.l),
              ],
              if (step.technicalNotes != null) ...[
                AppCard(
                  backgroundColor: AppTheme.accent.withOpacity(0.1),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb, color: AppTheme.accent, size: 20),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coach\'s Tip',
                              style: AppTypography.label(context, color: AppTheme.accent),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step.technicalNotes!,
                              style: AppTypography.body(context, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  const _InfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.label(context, size: 10),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  const _DetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption(context)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.title(context, size: 16)),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseStep exercise;
  final VoidCallback onTap;
  const _ExerciseCard({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: exercise.isRest ? AppTheme.success.withOpacity(0.1) : AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(
                exercise.isRest ? Icons.timer : Icons.fitness_center,
                color: exercise.isRest ? AppTheme.success : AppTheme.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: AppTypography.title(context, size: 16),
                  ),
                  Text(
                    '${exercise.duration}s ${exercise.isRest ? '• Rest' : ''}',
                    style: AppTypography.caption(context),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _AudioToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onToggled;
  const _AudioToggle({required this.icon, required this.label, required this.isActive, required this.onToggled});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: IconButton(
        onPressed: onToggled,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.accent.withOpacity(0.2) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? AppTheme.accent : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}
