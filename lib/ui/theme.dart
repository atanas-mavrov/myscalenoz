import 'package:flutter/material.dart';

/// Brand teal, as in the launcher icon.
const _teal = Color(0xFF2EAD8F);

/// Dark green text on teal: readable (about 7:1) and keeps buttons light.
const _ink = Color(0xFF00201A);

/// Material's generated palette darkens the brand color a lot (deep green
/// buttons, near-black dark mode); these overrides keep it bright.
ThemeData appTheme(Brightness brightness) {
  final base = ColorScheme.fromSeed(seedColor: _teal, brightness: brightness);
  final scheme = brightness == Brightness.light
      ? base.copyWith(
          primary: _teal,
          onPrimary: _ink,
          secondaryContainer: const Color(0xFFCDEFE5),
          onSecondaryContainer: _ink,
        )
      : base.copyWith(
          primary: const Color(0xFF4CC9A8),
          onPrimary: _ink,
          secondaryContainer: const Color(0xFF2F7D6B),
          onSecondaryContainer: Colors.white,
          surface: const Color(0xFF1A2421),
          surfaceContainerLow: const Color(0xFF22302C),
          surfaceContainer: const Color(0xFF263430),
          surfaceContainerHigh: const Color(0xFF2B3A35),
          surfaceContainerHighest: const Color(0xFF30403B),
        );
  return ThemeData(colorScheme: scheme);
}
