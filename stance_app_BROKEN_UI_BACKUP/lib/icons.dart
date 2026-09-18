// ============================================================
// Icon helpers — wraps Material icons and emoji glyphs in
// consistent widgets.
// ============================================================

import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;

  const AppIcon(this.name, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      _glyphFor(name),
      style: TextStyle(fontSize: size, color: color),
    );
  }

  static String _glyphFor(String name) {
    switch (name) {
      case 'home':
        return '🏠';
      case 'plan':
        return '📅';
      case 'train':
        return '🥊';
      case 'learn':
        return '📚';
      case 'profile':
        return '👤';
      case 'play':
        return '▶';
      case 'pause':
        return '⏸';
      case 'skip':
        return '⏭';
      case 'prev':
        return '⏮';
      case 'finish':
        return '✓';
      case 'close':
        return '✕';
      case 'flame':
        return '🔥';
      case 'trophy':
        return '🏆';
      case 'bolt':
        return '⚡';
      case 'clock':
        return '⏱️';
      case 'target':
        return '🎯';
      default:
        return name;
    }
  }
}
