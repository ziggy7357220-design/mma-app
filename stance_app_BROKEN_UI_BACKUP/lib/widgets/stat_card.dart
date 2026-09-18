import 'package:flutter/material.dart';
import '../design_system.dart';
import '../theme.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtext;
  final Color? accentColor;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtext,
    this.accentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      radius: AppRadius.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, color: accentColor ?? AppTheme.accent, size: 20),
          if (icon == null) const SizedBox(height: 20),
          const SizedBox(height: AppSpacing.s),
          Text(
            label.toUpperCase(),
            style: AppTypography.label(context, color: AppTheme.textMuted),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            value,
            style: AppTypography.display(context,
              color: accentColor ?? AppTheme.textPrimary,
              size: 28
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 2),
            Text(
              subtext!,
              style: AppTypography.caption(context),
            ),
          ],
        ],
      ),
    );
  }
}
