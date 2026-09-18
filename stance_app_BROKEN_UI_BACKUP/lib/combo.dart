// ============================================================
// Combo Creator — build and manage striking combinations.
// ============================================================

import 'package:flutter/material.dart';
import 'models/models.dart';
import 'state.dart';
import 'workout_details_screen.dart';
import 'theme.dart';
import 'data/content.dart';

class ComboCreatorScreen extends StatefulWidget {
  final AppState state;
  const ComboCreatorScreen({super.key, required this.state});

  @override
  State<ComboCreatorScreen> createState() => _ComboCreatorScreenState();
}

class _ComboCreatorScreenState extends State<ComboCreatorScreen> {
  bool _isEditing = false;
  String _currentComboId = '';
  late TextEditingController _nameController;
  late TextEditingController _folderController;
  List<String> _selectedStrikes = [];
  int _presetCount = 4;

  final List<int> _presetCounts = [4, 8, 12, 18, 24];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'New Combo');
    _folderController = TextEditingController(text: 'General');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _folderController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _isEditing = false;
      _currentComboId = '';
      _nameController.text = 'New Combo';
      _folderController.text = 'General';
      _selectedStrikes = [];
      _presetCount = 4;
    });
  }

  void _loadCombo(Combo combo) {
    setState(() {
      _isEditing = true;
      _currentComboId = combo.id;
      _nameController.text = combo.name;
      _folderController.text = combo.folder;
      _selectedStrikes = List.from(combo.strikes);
      _presetCount = combo.presetCount;
    });
  }

  void _practiceCombo(Combo combo) {
    final workout = Workout(
      id: 'practice_${combo.id}',
      title: 'Practice: ${combo.name}',
      description: 'Custom practice session for the combination: ${combo.name}',
      martialArt: 'general',
      category: 'Combo',
      difficulty: 'Beginner',
      duration: 1, // Minimal duration for a custom practice session
      exercises: [
        ExerciseStep(
          name: 'Perform Combo',
          duration: 60,
          description: 'Execute the following sequence: ${combo.strikes.join(' → ')}',
          isRest: false,
        ),
      ],
      equipment: [],
      xp: 10,
    );

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => WorkoutDetailsScreen(
        workout: workout,
        state: widget.state,
      ),
    ));
  }

  void _saveCombo() {
    final name = _nameController.text.trim();
    final folder = _folderController.text.trim();
    if (name.isEmpty || _selectedStrikes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a name and at least one strike.')),
      );
      return;
    }

    final combo = Combo(
      id: _isEditing ? _currentComboId : DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      strikes: _selectedStrikes,
      createdAt: DateTime.now(),
      folder: folder,
      presetCount: _presetCount,
    );

    if (_isEditing) {
      // Replace existing
      widget.state.combos.removeWhere((c) => c.id == combo.id);
    }
    widget.state.combos.add(combo);
    widget.state.save(); // Trigger state persistence

    setState(() => _resetForm());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Combo saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Combo' : 'Create Combo'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete, color: AppTheme.danger),
              onPressed: () {
                setState(() {
                  widget.state.combos.removeWhere((c) => c.id == _currentComboId);
                  widget.state.save();
                  _resetForm();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildComboLibrary(),
          ),
          Divider(color: AppTheme.border),
          _buildEditorPanel(),
        ],
      ),
    );
  }

  Widget _buildComboLibrary() {
    final folders = widget.state.combos.map((c) => c.folder).toSet().toList()..sort();

    if (folders.isEmpty) {
      return Center(
        child: Text('No saved combos yet. Start building one below!',
            style: TextStyle(color: AppTheme.textMuted)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: folders.map((folder) {
        final combosInFolder = widget.state.combos.where((c) => c.folder == folder).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(folder,
                  style: TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
            ...combosInFolder.map((combo) => ListTile(
                  title: Text(combo.name,
                      style: TextStyle(color: AppTheme.textPrimary)),
                  subtitle: Text(combo.strikes.join(' → '),
                      style: TextStyle(color: AppTheme.textSecondary)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.play_arrow, color: AppTheme.accent, size: 20),
                        onPressed: () => _practiceCombo(combo),
                      ),
                      Icon(Icons.chevron_right, color: AppTheme.textMuted),
                    ],
                  ),
                  onTap: () => _loadCombo(combo),
                )),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEditorPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Combo Name',
                      labelStyle: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _folderController,
                    style: TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Folder',
                      labelStyle: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Preset Count',
                style: TextStyle(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _presetCounts.map((count) {
                return ChoiceChip(
                  label: Text(count.toString()),
                  selected: _presetCount == count,
                  onSelected: (v) {
                    if (v) setState(() => _presetCount = count);
                  },
                  selectedColor: AppTheme.accent.withOpacity(0.3),
                  checkmarkColor: AppTheme.accent,
                  labelStyle: TextStyle(
                    color: _presetCount == count ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Sequence',
                style: TextStyle(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            const SizedBox(height: 8),
            _buildSequenceList(),
            const SizedBox(height: 16),
            _buildStrikePicker(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveCombo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                ),
                child: Text(_isEditing ? 'UPDATE COMBO' : 'SAVE COMBO'),
              ),
            ),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _resetForm,
                  child: Text('Discard Changes',
                      style: TextStyle(color: AppTheme.textMuted)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSequenceList() {
    if (_selectedStrikes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Center(
          child: Text('No strikes added yet.',
              style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${_selectedStrikes.length} / $_presetCount strikes',
            style: TextStyle(
              color: _selectedStrikes.length <= _presetCount
                  ? AppTheme.textSecondary
                  : AppTheme.danger,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedStrikes.asMap().entries.map((entry) {
            final idx = entry.key;
            final strike = entry.value;
            return Chip(
              label: Text(strike,
                  style: TextStyle(color: AppTheme.textPrimary)),
              backgroundColor: AppTheme.surfaceElevated,
              side: BorderSide(color: AppTheme.border),
              onDeleted: () => setState(() => _selectedStrikes.removeAt(idx)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStrikePicker() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: ContentLibrary.strikes.map((strike) {
        final canAdd = _selectedStrikes.length < _presetCount;
        return InkWell(
          onTap: canAdd ? () => setState(() => _selectedStrikes.add(strike)) : null,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: canAdd ? AppTheme.surface : AppTheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(strike,
                style: TextStyle(
                    color: canAdd ? AppTheme.textSecondary : AppTheme.textMuted, fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }
}
