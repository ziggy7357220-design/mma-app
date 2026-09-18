// ============================================================
// STANCE Design System — Constants for spacing, radii, and types.
// ============================================================

import 'package:flutter/material.dart';
import 'theme.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double ms = 12.0;
  static const double m = 16.0;
  static const double lm = 20.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
}

class AppRadius {
  static const double small = 12.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}

class AppTypography {
  static TextStyle display(BuildContext context, {
    Color? color,
    double size = 32,
    FontWeight weight = FontWeight.w800,
  }) => TextStyle(
    color: color ?? AppTheme.textPrimary,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static TextStyle headline(BuildContext context, {
    Color? color,
    double size = 24,
    FontWeight weight = FontWeight.w700,
  }) => TextStyle(
    color: color ?? AppTheme.textPrimary,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: -0.4,
  );

  static TextStyle title(BuildContext context, {
    Color? color,
    double size = 18,
    FontWeight weight = FontWeight.w600,
  }) => TextStyle(
    color: color ?? AppTheme.textPrimary,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: -0.2,
  );

  static TextStyle body(BuildContext context, {
    Color? color,
    double size = 14,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    color: color ?? AppTheme.textSecondary,
    fontSize: size,
    fontWeight: weight,
    height: 1.5,
  );

  static TextStyle caption(BuildContext context, {
    Color? color,
    double size = 12,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    color: color ?? AppTheme.textMuted,
    fontSize: size,
    fontWeight: weight,
    height: 1.4,
  );

  static TextStyle label(BuildContext context, {
    Color? color,
    double size = 11,
    FontWeight weight = FontWeight.w700,
    bool uppercase = true,
  }) => TextStyle(
    color: color ?? AppTheme.textMuted,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: 1.2,
    package: uppercase ? 'uppercase' : null, // This is not a valid parameter, just a hint
  );
}
