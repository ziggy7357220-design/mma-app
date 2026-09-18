// ============================================================
// Workout Complete Screen — reward and summary experience.
// ============================================================

import 'package:flutter/material.dart';

import 'state.dart';
import 'theme.dart';
import 'design_system.dart';
import 'widgets/app_card.dart';
import 'widgets/primary_button.dart';

class WorkoutCompleteScreen extends StatefulWidget {
  final String workoutTitle;
  final int trainedSeconds;
  final bool isMeaningful;
  final AppState state;

  const WorkoutCompleteScreen({
    super.key,
    required this.workoutTitle,
    required this.trainedSeconds,
    required this.isMeaningful,
    required this.state,
  });

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  double _progress = 0.0;
  int _animatedXp = 0;
  int _animatedStreak = 0;

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  void _startAnimations() async {
    // Progress bar animation
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 20));
      if (mounted) setState(() => _progress = i / 100);
    }

    // Numbers count up
    for (int i = 0; i <= widget.state.xp; i += (widget.state.xp ~/ 10).clamp(1, 100)) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) setState(() => _animatedXp = i);
    }
    setState(() => _animatedXp = widget.state.xp);

    for (int i = 0; i <= widget.state.currentStreak; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) setState(() => _animatedStreak = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isMeaningful) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: AppTheme.textMuted, size: 64),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'Session not counted',
                    style: AppTypography.headline(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Complete 30% or more to record this session.',
                    style: AppTypography.body(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Continue',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.l),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Icon(Icons.check_circle, color: AppTheme.success, size: 100),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'SESSION COMPLETE',
                style: AppTypography.label(context, color: AppTheme.accent),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                widget.workoutTitle,
                style: AppTypography.display(context, size: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  children: [
                    Text(
                      '${(widget.trainedSeconds ~/ 60)}m ${widget.trainedSeconds % 60}s',
                      style: AppTypography.display(context, size: 48),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'trained today',
                      style: AppTypography.caption(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        children: [
                          Text('+50 XP', style: AppTypography.title(context, color: AppTheme.accent)),
                          Text('Earned', style: AppTypography.caption(context)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        children: [
                          Text('🔥 $_animatedStreak', style: AppTypography.title(context, color: AppTheme.accent)),
                          Text('Streak', style: AppTypography.caption(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total XP', style: AppTypography.caption(context)),
                        Text('$_animatedXp', style: AppTypography.title(context)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.small / 2),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 8,
                        backgroundColor: AppTheme.border,
                        valueColor: AlwaysStoppedAnimation(AppTheme.accent),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
