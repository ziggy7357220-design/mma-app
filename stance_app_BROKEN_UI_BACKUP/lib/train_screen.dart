// ============================================================
// Train screen — structured martial arts library.
// Implements a single-screen discovery flow: Art -> Category -> Level -> Workout.
// ============================================================

import 'package:flutter/material.dart';

import 'combo.dart';
import 'data/content.dart';
import 'models/models.dart';
import 'workout_details_screen.dart';
import 'player.dart';
import 'state.dart';
import 'theme.dart';
import 'design_system.dart';
import 'widgets/app_card.dart';
import 'widgets/primary_button.dart';
import 'widgets/secondary_button.dart';
import 'widgets/section_header.dart';
import 'widgets/workout_card.dart';

class TrainScreen extends StatefulWidget {
  final AppState state;
  const TrainScreen({super.key, required this.state});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  MartialArt? _selectedArt;
  String? _selectedCategory;
  String? _selectedDifficulty;

  void _resetDiscovery() {
    setState(() {
      _selectedArt = null;
      _selectedCategory = null;
      _selectedDifficulty = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Train'),
        leading: (_selectedArt != null)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    if (_selectedDifficulty != null) {
                      _selectedDifficulty = null;
                    } else if (_selectedCategory != null) {
                      _selectedCategory = null;
                    } else {
                      _selectedArt = null;
                    }
                  });
                },
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.m, AppSpacing.xxl),
        children: [
          SectionHeader(
            title: 'Quick tools',
          ),
          Row(
            children: [
              Expanded(
                child: _ToolCard(
                  title: 'Round Timer',
                  icon: '⏱️',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => RoundTimerScreen(),
                  )),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: _ToolCard(
                  title: 'Combo Creator',
                  icon: '🥊',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ComboCreatorScreen(state: widget.state),
                  )),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildDiscoveryFlow(),
        ],
      ),
    );
  }

  Widget _buildDiscoveryFlow() {
    if (_selectedArt == null) {
      return _buildArtGrid();
    } else if (_selectedCategory == null) {
      return _buildCategoryList();
    } else if (_selectedDifficulty == null) {
      return _buildDifficultyList();
    } else {
      return _buildWorkoutList();
    }
  }

  Widget _buildArtGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Choose your discipline'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.m,
          crossAxisSpacing: AppSpacing.m,
          childAspectRatio: 1.3,
          children: ContentLibrary.martialArts.map((art) {
            return AppCard(
              onTap: () => setState(() => _selectedArt = art),
              radius: AppRadius.medium,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(art.icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    art.name,
                    style: AppTypography.title(context, size: 16),
                  ),
                  Text(
                    '${ContentLibrary.workouts.where((w) => w.martialArt == art.id).length} sessions',
                    style: AppTypography.caption(context),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    final art = _selectedArt!;
    final artTechniques = ContentLibrary.techniques[art.id] ?? [];
    final artWorkouts = ContentLibrary.workouts.where((w) => w.martialArt == art.id).toList();

    final categories = <String>{};
    for (final t in artTechniques) categories.add(t.category);
    for (final w in artWorkouts) categories.add(w.category);

    final sortedCategories = categories.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: '${art.name} — Categories'),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: sortedCategories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accent : AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(
                    color: isSelected ? AppTheme.accent : AppTheme.border,
                  ),
                ),
                child: Text(
                  cat,
                  style: AppTypography.label(context,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultyList() {
    final levels = ['Beginner', 'Intermediate', 'Advanced'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Select Difficulty'),
        ...levels.map((lvl) {
          final isSelected = _selectedDifficulty == lvl;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: AppCard(
              onTap: () => setState(() => _selectedDifficulty = lvl),
              radius: AppRadius.medium,
              backgroundColor: isSelected ? AppTheme.accent.withOpacity(0.1) : null,
              border: Border.all(
                color: isSelected ? AppTheme.accent : AppTheme.border,
                width: isSelected ? 2 : 1,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(lvl, style: AppTypography.title(context, size: 16)),
                  if (isSelected) Icon(Icons.check_circle, color: AppTheme.accent),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWorkoutList() {
    final art = _selectedArt!;
    final cat = _selectedCategory!;
    final diff = _selectedDifficulty!;

    final workouts = ContentLibrary.workouts.where((w) =>
      w.martialArt == art.id &&
      w.category == cat &&
      w.difficulty.toLowerCase() == diff.toLowerCase()
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Workouts'),
        workouts.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text('No workouts found for this level',
                      style: AppTypography.body(context, color: AppTheme.textMuted)),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: workouts.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
                itemBuilder: (context, index) {
                  final w = workouts[index];
                  return WorkoutCard(
                    workout: w,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => WorkoutDetailsScreen(
                        workout: w,
                        state: widget.state,
                      ),
                    )),
                  );
                },
              ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;
  const _ToolCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      radius: AppRadius.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: AppSpacing.s),
          Text(title, style: AppTypography.title(context, size: 15)),
        ],
      ),
    );
  }
}
