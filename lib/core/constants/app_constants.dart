import 'package:flutter/widgets.dart';

/// Layout constants used across the app so spacing/radius stays consistent.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets screenV = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 100;

  static const BorderRadius card = BorderRadius.all(Radius.circular(16));
  static const BorderRadius button = BorderRadius.all(Radius.circular(16));
  static const BorderRadius field = BorderRadius.all(Radius.circular(14));
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
}

/// App-wide strings that are not tied to any single feature.
class AppStrings {
  AppStrings._();

  static const String appName = 'Healthy Mart';
  static const String currency = '\$';
}
