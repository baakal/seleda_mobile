import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const seedColor = Colors.teal;
  final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
  );
}

ThemeData buildDarkTheme() {
  const seedColor = Colors.teal;
  final colorScheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark);
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
  );
}
