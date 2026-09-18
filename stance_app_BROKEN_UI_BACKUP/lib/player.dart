// ============================================================
// WorkoutPlayer — sequential exercise timer with prev / skip / pause.
// Ported from js/player.js. Durations are seconds.
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';

import 'models/models.dart';
import 'theme.dart';
import 'design_system.dart';
import 'widgets/app_card.dart';
import 'widgets/primary_button.dart';
import 'widgets/secondary_button.dart';

class WorkoutPlayer extends StatefulWidget {
  final CustomizedWorkout? customizedWorkout;
  final Workout workout;
  final Function(int actuallyTrainedSeconds) onComplete;

  const WorkoutPlayer({
    super.key,
    this.customizedWorkout,
    required this.workout,
    required this.onComplete,
  });

  @override
  State<WorkoutPlayer> createState() => _WorkoutPlayerState();
}

class _WorkoutPlayerState extends State<WorkoutPlayer> {
  late final List<ExerciseStep> _exercises;
  int _index = 0;
  int _timeLeft = 0;
  bool _running = true;
  Timer? _timer;

  int _actuallyTrainedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _exercises = widget.customizedWorkout?.modifiedExercises ?? widget.workout.exercises;
    _startExercise(0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise(int idx) {
    _timer?.cancel();
    _index = idx;
    _timeLeft = _exercises[idx].duration;
    _running = true;
    _tick();
  }

  void _tick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_running) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft -= 1;
          _actuallyTrainedSeconds += 1;
        } else {
          t.cancel();
          _advance();
        }
      });
    });
  }

  void _togglePause() {
    setState(() => _running = !_running);
  }

  void _skip() {
    _advance();
  }

  void _advance() {
    if (_index < _exercises.length - 1) {
      _startExercise(_index + 1);
    } else {
      _timer?.cancel();
      widget.onComplete(_actuallyTrainedSeconds);
    }
  }

  void _prev() {
    if (_index > 0) {
      _startExercise(_index - 1);
    }
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercises[_index];
    final totalDuration = _exercises.fold<int>(0, (acc, e) => acc + e.duration);
    final elapsed = _exercises.take(_index).fold<int>(0, (acc, e) => acc + e.duration) +
        (exercise.duration - _timeLeft);
    final progress = totalDuration == 0 ? 0.0 : elapsed / totalDuration;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          child: Column(
            children: [
              // --- Header ---
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.of(context).maybePop();
                    },
                    icon: Icon(Icons.close, color: AppTheme.textPrimary),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.workout.title,
                        style: AppTypography.title(context),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _togglePause,
                    icon: Icon(
                      _running ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: AppTheme.accent,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              // --- Overall Progress ---
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.small / 2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppTheme.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation(AppTheme.accent),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Exercise ${_index + 1} of ${_exercises.length}',
                style: AppTypography.caption(context),
              ),
              const Spacer(),
              // --- Exercise Area ---
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Column(
                  key: ValueKey(_index),
                  children: [
                    Text(
                      exercise.isRest ? 'REST' : exercise.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTypography.headline(context,
                        color: exercise.isRest ? AppTheme.success : AppTheme.accent,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _fmt(_timeLeft),
                      style: AppTypography.display(context, size: 96),
                    ),
                    const SizedBox(height: 24),
                    if (exercise.description != null)
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        child: Text(
                          exercise.description!,
                          textAlign: TextAlign.center,
                          style: AppTypography.body(context),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              // --- Controls ---
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Previous',
                      onPressed: _index > 0 ? _prev : () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: _index == _exercises.length - 1 ? 'Finish' : 'Skip',
                      onPressed: _skip,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round timer — fixed rounds with configurable work/rest intervals.
class RoundTimerScreen extends StatefulWidget {
  const RoundTimerScreen({super.key});

  @override
  State<RoundTimerScreen> createState() => _RoundTimerScreenState();
}

class _RoundTimerScreenState extends State<RoundTimerScreen> {
  int _rounds = 5;
  int _workSeconds = 180;
  int _restSeconds = 60;
  int _currentRound = 1;
  int _timeLeft = 0;
  bool _running = false;
  bool _isWork = true;
  Timer? _timer;

  void _start() {
    _currentRound = 1;
    _isWork = true;
    _timeLeft = _workSeconds;
    _running = true;
    _runTimer();
  }

  void _runTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_running) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft -= 1;
        } else {
          if (_isWork) {
            if (_currentRound >= _rounds) {
              t.cancel();
              _running = false;
              _showComplete();
              return;
            }
            _isWork = false;
            _timeLeft = _restSeconds;
          } else {
            _currentRound += 1;
            _isWork = true;
            _timeLeft = _workSeconds;
          }
        }
      });
    });
  }

  void _showComplete() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surfaceElevated,
        content: Text('Round timer complete! Great work.', style: TextStyle(color: AppTheme.textPrimary)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _pauseResume() {
    setState(() => _running = !_running);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _currentRound = 1;
      _isWork = true;
      _timeLeft = _workSeconds;
    });
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final ss = s % 60;
    return '${m.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Round Timer')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              if (!_running && _timeLeft == 0) ...[
                Text('Configure your rounds',
                    style: AppTypography.body(context)),
                const SizedBox(height: 16),
                _configRow('Rounds', _rounds, 1, 20,
                    onChange: (v) => setState(() => _rounds = v)),
                const SizedBox(height: 12),
                _configRow('Work (sec)', _workSeconds, 30, 600, step: 30,
                    onChange: (v) => setState(() => _workSeconds = v)),
                const SizedBox(height: 12),
                _configRow('Rest (sec)', _restSeconds, 15, 300, step: 15,
                    onChange: (v) => setState(() => _restSeconds = v)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: PrimaryButton(
                    label: 'Start',
                    onPressed: _start,
                  ),
                ),
              ] else ...[
                Text(
                  _isWork ? 'WORK' : 'REST',
                  style: AppTypography.label(context,
                      color: _isWork ? AppTheme.accent : AppTheme.success),
                ),
                const SizedBox(height: 12),
                Text('Round $_currentRound / $_rounds',
                    style: AppTypography.caption(context)),
                const SizedBox(height: 24),
                Text(_fmt(_timeLeft),
                    style: AppTypography.display(context, size: 96)),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Reset',
                        onPressed: _reset,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: _running ? 'Pause' : 'Resume',
                        onPressed: _pauseResume,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _configRow(String label, int value, int min, int max,
      {int step = 1, required ValueChanged<int> onChange}) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.body(context))),
          IconButton(
            onPressed: value > min ? () => onChange(value - step) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 56,
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: AppTypography.title(context, size: 18),
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChange(value + step) : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
