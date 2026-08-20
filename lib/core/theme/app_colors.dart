import 'package:flutter/material.dart';

/// Central color palette for the Fresh Grocery app.
///
/// The palette is built around a fresh, vivid grocery green with neutral
/// greys for text and surfaces. Keeping every color in one place makes it
/// trivial to re-theme the whole app.
class AppColors {
  AppColors._();

  // --- Brand ---
  static const Color primary = Color(0xFF53B175);
  static const Color primaryDark = Color(0xFF3E8E5A);
  static const Color primaryLight = Color(0xFFEAF6EE);
  static const Color accent = Color(0xFF2B8C4E);

  // --- Semantic ---
  static const Color success = Color(0xFF53B175);
  static const Color error = Color(0xFFE0413B);
  static const Color warning = Color(0xFFF3A712);
  static const Color info = Color(0xFF4A90E2);

  // --- Neutrals ---
  static const Color textPrimary = Color(0xFF1E222B);
  static const Color textSecondary = Color(0xFF7C7C7C);
  static const Color textTertiary = Color(0xFFB1B1B1);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF7F8FA);
  static const Color card = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE2E2E2);
  static const Color divider = Color(0xFFEDEDED);
  static const Color shimmer = Color(0xFFF0F0F0);

  // --- Discount / badges ---
  static const Color discount = Color(0xFF2B8C4E);
  static const Color discountBg = Color(0xFFE7F4EC);

  // --- Fixed helpers ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Soft, food-friendly tints used behind product / category illustrations.
  static const List<Color> tileTints = [
    Color(0xFFFFF3E0),
    Color(0xFFE8F5E9),
    Color(0xFFFCE4EC),
    Color(0xFFE3F2FD),
    Color(0xFFFFF8E1),
    Color(0xFFF3E5F5),
    Color(0xFFE0F2F1),
    Color(0xFFFBE9E7),
  ];
}
