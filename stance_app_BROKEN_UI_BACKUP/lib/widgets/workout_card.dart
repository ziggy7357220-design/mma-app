import 'package:flutter/material.dart';
import '../design_system.dart';
import '../theme.dart';
import '../models/models.dart';
import 'app_card.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;
  final bool isFeatured;
  final bool isCompleted;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
    this.isFeatured = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFeatured) {
      return _buildFeatured();
    }
    return _buildCompact();
  }

  Widget _buildFeatured() {
    return AppCard(
      radius: AppRadius.large,
      backgroundColor: AppTheme.surface,
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY\'S SESSION',
                style: AppTypography.label(context, color: AppTheme.accent),
              ),
              _Pill(text: workout.difficulty),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            workout.title,
            style: AppTypography.display(context, size: 28),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '${workout.martialArt.toUpperCase()} • ${workout.duration} min',
            style: AppTypography.body(context),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'START TRAINING',
              onPressed: () => onTap?.call(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact() {
    return AppCard(
      onTap: onTap,
      radius: AppRadius.medium,
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.play_circle_outline,
              color: isCompleted ? AppTheme.success : AppTheme.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.title,
                  style: AppTypography.title(context, size: 16),
                ),
                Text(
                  '${workout.martialArt} • ${workout.duration} min',
                  style: AppTypography.caption(context),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.border,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.label(context, size: 10),
      ),
    );
  }
}
