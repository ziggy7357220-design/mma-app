// ============================================================
// Learn screen — martial arts library → techniques.
// ============================================================

import 'package:flutter/material.dart';

import 'data/content.dart';
import 'models/models.dart';
import 'state.dart';
import 'theme.dart';

class LearnScreen extends StatefulWidget {
  final AppState state;
  const LearnScreen({super.key, required this.state});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String? _selectedArt;

  @override
  Widget build(BuildContext context) {
    if (_selectedArt == null) return _buildArtList();
    return _buildArtDetail(_selectedArt!);
  }

  Widget _buildArtList() {
    final arts = ContentLibrary.martialArts;
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Choose a martial art to explore techniques.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: arts.map((a) {
              final learnedCount = widget.state.learnedTechniques
                  .where((t) => ContentLibrary.techniquesForArt(a.id)
                      .any((tech) => tech.id == t))
                  .length;
              final total = ContentLibrary.techniquesForArt(a.id).length;
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _selectedArt = a.id),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.icon, style: const TextStyle(fontSize: 28)),
                      const Spacer(),
                      Text(a.name,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          )),
                      Text('$learnedCount / $total learned',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildArtDetail(String artId) {
    final arts = ContentLibrary.martialArts;
    final art = arts.firstWhere((a) => a.id == artId, orElse: () => arts.first);
    final techs = ContentLibrary.techniquesForArt(artId);

    return Scaffold(
      appBar: AppBar(
        title: Text(art.name),
        leading: IconButton(
          onPressed: () => setState(() => _selectedArt = null),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: techs.map((t) {
          final learned = widget.state.learnedTechniques.contains(t.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TechniqueTile(
              technique: t,
              learned: learned,
              onTap: () => _openTechnique(t),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openTechnique(Technique t) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TechniqueDetailScreen(
        technique: t,
        learned: widget.state.learnedTechniques.contains(t.id),
        onLearned: () => widget.state.markTechniqueLearned(t.id),
      ),
    ));
  }
}

class _TechniqueTile extends StatelessWidget {
  final Technique technique;
  final bool learned;
  final VoidCallback onTap;
  const _TechniqueTile({required this.technique, required this.learned, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: learned ? AppTheme.success.withOpacity(0.4) : AppTheme.border,
            width: learned ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (learned ? AppTheme.success : AppTheme.accent).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                learned ? Icons.check_circle : Icons.school,
                color: learned ? AppTheme.success : AppTheme.accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(technique.name,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      )),
                  Text(
                    '${technique.category} • +${technique.xp} XP',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class TechniqueDetailScreen extends StatelessWidget {
  final Technique technique;
  final bool learned;
  final VoidCallback onLearned;

  const TechniqueDetailScreen({
    super.key,
    required this.technique,
    required this.learned,
    required this.onLearned,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(technique.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(technique.category.toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    )),
                const SizedBox(height: 8),
                Text(technique.name,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    )),
                const SizedBox(height: 12),
                Text(technique.description,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle(title: 'Steps'),
          ...technique.steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StepRow(index: entry.key + 1, text: entry.value),
            );
          }),
          const SizedBox(height: 20),
          const _SectionTitle(title: 'Common Mistakes'),
          ...technique.mistakes.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _BulletRow(text: m, color: AppTheme.danger),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: learned ? null : () {
                onLearned();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.surfaceElevated,
                    content: Text('+${technique.xp} XP — technique marked as learned',
                        style: TextStyle(color: AppTheme.textPrimary)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(learned ? Icons.check_circle : Icons.school),
              label: Text(learned ? 'Already learned' : 'Mark as Learned'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

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

class _StepRow extends StatelessWidget {
  final int index;
  final String text;
  const _StepRow({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text('$index',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700,
                )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  height: 1.4,
                )),
          ),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  final Color color;
  const _BulletRow({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 10),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: Text(text,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  height: 1.4,
                )),
          ),
        ],
      ),
    );
  }
}
