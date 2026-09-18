import 'package:flutter/material.dart';
import '../design_system.dart';
import '../theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? backgroundColor;
  final BorderSide? border;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = AppRadius.medium,
    this.backgroundColor,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.m),
      child: child,
    );

    if (onTap == null) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.surface,
          borderRadius: BorderRadius.circular(radius),
          border: border ?? Border.all(color: AppTheme.border),
        ),
        child: content,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.surface,
          borderRadius: BorderRadius.circular(radius),
          border: border ?? Border.all(color: AppTheme.border),
        ),
        child: content,
      ),
    );
  }
}
