import 'package:flutter/material.dart';

/// Shared presentation style constants to keep spacing, radius, and typography
/// consistent across transaction feature pages. Inspired by BalanceSummaryCard
/// and TransactionListItem.
class TxStyles {
  // Spacing scale (multiples of 4)
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 24;
  static const double space2xl = 32;

  // Standard horizontal screen padding for pages
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: spaceLg);
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(spaceLg);

  // Section spacing
  static const SizedBox sectionGap = SizedBox(height: spaceLg);
  static const SizedBox itemGapSm = SizedBox(height: spaceSm);

  // Card radius
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16));

  // Section title style (weight + slight letter spacing)
  static TextStyle? sectionTitle(BuildContext context) {
    final base = Theme.of(context).textTheme.titleMedium;
    return base?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -.2);
  }

  // Subtle label style
  static TextStyle? subtleLabel(BuildContext context) {
    final base = Theme.of(context).textTheme.bodySmall;
    return base?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
  }

  // Large emphasized amount (e.g., AddTransaction input)
  static TextStyle largeAmount(BuildContext context) => const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        letterSpacing: -1,
      );
}
