// ============================================================
// Workout Customize Screen — adjust session parameters.
// ============================================================

import 'package:flutter/material.dart';
import 'models/models.dart';
import 'theme.dart';

class WorkoutCustomizeScreen extends StatefulWidget {
  final Workout workout;
  final Function(CustomizedWorkout) onConfirm;

  const WorkoutCustomizeScreen({
    super.key,
    required this.workout,
    required this.onConfirm,
  });

  @override
  State<WorkoutCustomizeScreen> createState() => _WorkoutCustomizeScreenState();
}

class _WorkoutCustomizeScreenState extends State<WorkoutCustomizeScreen> {
  double _multiplier = 1.0;
  int _workOffset = 0;
  int _restOffset = 0;
  bool _warmup = true;
  bool _stretching = true;
  List<String> _activeEquipment = [];

  @override
  void initState() {
    super.initState();
    _activeEquipment = List.from(widget.workout.equipment);
  }

  void _save() {
    final customized = CustomizedWorkout(
      originalWorkout: widget.workout,
      durationMultiplier: _multiplier,
      workOffsetSeconds: _workOffset,
      restOffsetSeconds: _restOffset,
      includeWarmup: _warmup,
      includeStretching: _stretching,
      activeEquipment: _activeEquipment,
    );
    widget.onConfirm(customized);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Workout'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _SectionHeader(title: 'Timing'),
          _SettingTile(
            title: 'Duration Multiplier',
            subtitle: 'Adjust length of all exercises',
            options: [0.5, 1.0, 1.5],
            currentValue: _multiplier,
            onChanged: (v) => setState(() => _multiplier = v as double),
          ),
          const SizedBox(height: 16),
          _SettingTile(
            title: 'Work Offset',
            subtitle: 'Add/subtract seconds per step',
            options: [-10, 0, 10],
            currentValue: _workOffset,
            onChanged: (v) => setState(() => _workOffset = v as int),
          ),
          const SizedBox(height: 16),
          _SettingTile(
            title: 'Rest Offset',
            subtitle: 'Adjust duration of rest periods',
            options: [-5, 0, 5],
            currentValue: _restOffset,
            onChanged: (v) => setState(() => _restOffset = v as int),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Session Structure'),
          SwitchListTile(
            title: Text('Include Warm-up', style: TextStyle(color: AppTheme.textPrimary)),
            subtitle: Text('Add 5 min mobility work', style: TextStyle(color: AppTheme.textSecondary)),
            value: _warmup,
            onChanged: (v) => setState(() => _warmup = v),
            activeColor: AppTheme.accent,
          ),
          SwitchListTile(
            title: Text('Include Stretching', style: TextStyle(color: AppTheme.textPrimary)),
            subtitle: Text('Add 5 min cooldown', style: TextStyle(color: AppTheme.textSecondary)),
            value: _stretching,
            onChanged: (v) => setState(() => _stretching = v),
            activeColor: AppTheme.accent,
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Equipment'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.workout.equipment.map((eq) {
              final isSelected = _activeEquipment.contains(eq);
              return FilterChip(
                label: Text(eq),
                selected: isSelected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _activeEquipment.add(eq);
                    } else {
                      _activeEquipment.remove(eq);
                    }
                  });
                },
                selectedColor: AppTheme.accent.withOpacity(0.3),
                checkmarkColor: AppTheme.accent,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('CONFIRM & START', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
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

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<dynamic> options;
  final dynamic currentValue;
  final ValueChanged<dynamic> onChanged;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: options.map((opt) {
              final isSelected = opt == currentValue;
              return ChoiceChip(
                label: Text(opt.toString()),
                selected: isSelected,
                onSelected: (v) {
                  if (v) onChanged(opt);
                },
                selectedColor: AppTheme.accent.withOpacity(0.3),
                checkmarkColor: AppTheme.accent,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
