// ============================================================
// Onboarding — 7-step flow.
// Mirrors js/onboarding.js but adapted for Material widgets.
// ============================================================

import 'package:flutter/material.dart';

import 'data/content.dart';
import 'data/plan.dart';
import 'models/models.dart';
import 'theme.dart';

class OnboardingScreen extends StatefulWidget {
  final void Function(UserProfile profile, List<ScheduledDay> schedule) onCompleted;
  const OnboardingScreen({super.key, required this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  // Profile fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _journeyController = TextEditingController();

  final Set<String> _arts = {};
  String _level = 'intermediate';
  final Set<String> _goals = {};
  int _sessionDuration = 30;
  int _daysPerWeek = 4;
  final Set<String> _availableDays = {};
  final Set<String> _equipment = {};

  static const int _totalSteps = 10;

  void _next() {
    if (_step == 0 && _nameController.text.trim().isEmpty) return;
    if (_step == 1) {
      if (_ageController.text.trim().isEmpty ||
          _heightController.text.trim().isEmpty ||
          _weightController.text.trim().isEmpty) return;
    }
    if (_step == 2 && _expController.text.trim().isEmpty) return;
    if (_step == 3 && _arts.isEmpty) return;
    if (_step == 4 && _level.isEmpty) return;
    if (_step == 5 && _goals.isEmpty) return;
    if (_step == 6) {} // always set
    if (_step == 7) {} // always set
    if (_step == 8 && _availableDays.isEmpty) return;
    if (_step == 9 && _equipment.isEmpty) return;

    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _finish() {
    final profile = UserProfile(
      name: _nameController.text.trim().isEmpty ? 'Athlete' : _nameController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 25,
      height: int.tryParse(_heightController.text) ?? 175,
      weight: int.tryParse(_weightController.text) ?? 75,
      experience: _expController.text.trim().isEmpty ? '1 year' : _expController.text.trim(),
      journeyStart: _journeyController.text.trim().isEmpty ? 'Just starting' : _journeyController.text.trim(),
      level: _level,
      martialArts: _arts.toList()..sort(),
      goals: _goals.toList()..sort(),
      sessionDuration: _sessionDuration,
      daysPerWeek: _daysPerWeek,
      availableDays: _availableDays.toList()..sort(),
      equipment: _equipment.toList(),
    );
    final schedule = PlanEngine.buildSchedule(profile, _equipment);
    widget.onCompleted(profile, schedule);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _expController.dispose();
    _journeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildStep(),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_step > 0)
                IconButton(
                  onPressed: _back,
                  icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                  padding: EdgeInsets.zero,
                ),
              const Spacer(),
              Text('Step ${_step + 1} / $_totalSteps',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_step + 1) / _totalSteps,
              minHeight: 6,
              backgroundColor: AppTheme.surfaceElevated,
              valueColor: AlwaysStoppedAnimation(AppTheme.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final canContinue = _canContinue();
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canContinue ? _next : null,
            child: Text(_step == _totalSteps - 1 ? 'Start Training' : 'Continue'),
          ),
        ),
      ),
    );
  }

  bool _canContinue() {
    switch (_step) {
      case 0: return _nameController.text.trim().isNotEmpty;
      case 1: return _ageController.text.trim().isNotEmpty &&
                    _heightController.text.trim().isNotEmpty &&
                    _weightController.text.trim().isNotEmpty;
      case 2: return _expController.text.trim().isNotEmpty;
      case 3: return _arts.isNotEmpty;
      case 4: return _level.isNotEmpty;
      case 5: return _goals.isNotEmpty;
      case 6: return true;
      case 7: return true;
      case 8: return _availableDays.isNotEmpty;
      case 9: return _equipment.isNotEmpty;
    }
    return false;
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildName();
      case 1: return _buildPersonalInfo();
      case 2: return _buildExperience();
      case 3: return _buildArts();
      case 4: return _buildLevel();
      case 5: return _buildGoals();
      case 6: return _buildSessionTime();
      case 7: return _buildDaysPerWeek();
      case 8: return _buildAvailableDays();
      case 9: return _buildEquipment();
    }
    return const SizedBox();
  }

  Widget _stepTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.6,
              )),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('What\'s your name?',
            'Let\'s personalize your training experience.'),
        TextField(
          controller: _nameController,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'e.g. Ayush',
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Physicals',
            'This helps us estimate calorie burn and set appropriate intensity.'),
        const SizedBox(height: 16),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Age',
            hintText: 'years',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _heightController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Height',
            hintText: 'cm',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Weight',
            hintText: 'kg',
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildExperience() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Your journey',
            'Tell us about your martial arts background.'),
        const SizedBox(height: 16),
        TextField(
          controller: _expController,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Training Experience',
            hintText: 'e.g. 2 years of Boxing',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _journeyController,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Journey Start Info',
            hintText: 'Why are you starting now?',
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildArts() {
    final arts = ContentLibrary.martialArts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('What do you train?',
            'Pick the disciplines you want to focus on. You can change these later.'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: arts.map((a) {
            final selected = _arts.contains(a.id);
            return _SelectionCard(
              title: a.name,
              icon: a.icon,
              color: Color(a.colorValue),
              selected: selected,
              onTap: () => setState(() {
                if (selected) {
                  _arts.remove(a.id);
                } else {
                  _arts.add(a.id);
                }
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('What\'s your level?',
            'We\'ll match the difficulty of your workouts to your experience.'),
        ...ContentLibrary.levels.map((l) {
          final selected = _level == l['id'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SelectionCard(
              title: l['title']!,
              subtitle: l['subtitle']!,
              selected: selected,
              onTap: () => setState(() => _level = l['id']!),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Your goals',
            'What do you want to get better at? Pick as many as you like.'),
        ...ContentLibrary.goals.map((g) {
          final selected = _goals.contains(g['id']);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SelectionCard(
              title: g['title']!,
              subtitle: g['subtitle']!,
              selected: selected,
              onTap: () => setState(() {
                if (selected) {
                  _goals.remove(g['id']);
                } else {
                  _goals.add(g['id']!);
                }
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSessionTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Session length',
            'How long do you want each session to be?'),
        ...ContentLibrary.durations.map((d) {
          final selected = _sessionDuration == (d['id'] as int);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SelectionCard(
              title: d['title'] as String,
              subtitle: d['subtitle'] as String,
              selected: selected,
              onTap: () => setState(() => _sessionDuration = d['id'] as int),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDaysPerWeek() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('How many days?',
            'How many days a week do you want to train?'),
        ...ContentLibrary.daysPerWeekOptions.map((d) {
          final selected = _daysPerWeek == (d['id'] as int);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SelectionCard(
              title: d['title'] as String,
              selected: selected,
              onTap: () => setState(() => _daysPerWeek = d['id'] as int),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAvailableDays() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Which days?',
            'Pick the days that work best for your schedule.'),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
          children: ContentLibrary.weekdays.map((d) {
            final selected = _availableDays.contains(d['id']);
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() {
                if (selected) {
                  _availableDays.remove(d['id']);
                } else {
                  _availableDays.add(d['id']!);
                }
              }),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? AppTheme.accent.withOpacity(0.15) : AppTheme.surface,
                  border: Border.all(
                    color: selected ? AppTheme.accent : AppTheme.border,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  d['short']!,
                  style: TextStyle(
                    color: selected ? AppTheme.accent : AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEquipment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Your equipment',
            'Pick the gear you have access to. We\'ll filter workouts to match.'),
        ...ContentLibrary.equipment.map((e) {
          final selected = _equipment.contains(e['id']);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SelectionCard(
              title: e['title']!,
              subtitle: e['subtitle']!,
              selected: selected,
              onTap: () => setState(() {
                if (selected) {
                  _equipment.remove(e['id']);
                } else {
                  _equipment.add(e['id']!);
                }
              }),
            ),
          );
        }),
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? icon;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withOpacity(0.12) : AppTheme.surface,
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Text(icon!, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: TextStyle(
                        color: selected ? AppTheme.accent : AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        )),
                  ],
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: AppTheme.accent, size: 22),
          ],
        ),
      ),
    );
  }
}
