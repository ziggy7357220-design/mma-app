import 'package:flutter/material.dart';
import '../design_system.dart';
import '../theme.dart';
import 'app_card.dart';

class QuoteCard extends StatelessWidget {
  final String text;
  final String author;
  final VoidCallback? onTap;

  const QuoteCard({
    super.key,
    required this.text,
    required this.author,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      radius: AppRadius.medium,
      backgroundColor: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INSIGHT',
                style: AppTypography.label(context, color: AppTheme.accent),
              ),
              Icon(Icons.format_quote, color: AppTheme.accent, size: 16),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            '"$text"',
            style: AppTypography.headline(context, size: 18, weight: FontWeight.w500),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '- $author',
            style: AppTypography.caption(context),
          ),
        ],
      ),
    );
  }
}
