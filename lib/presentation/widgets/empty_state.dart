import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'primary_button.dart';

/// A friendly empty / error state with an illustration, message and CTA.
/// Used by empty cart, empty favorites and empty search results.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color accent;

  const EmptyState({
    super.key,
    this.icon = Icons.shopping_basket_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.accent = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Illustration(icon: icon, accent: accent),
            const SizedBox(height: 32),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final IconData icon;
  final Color accent;

  const _Illustration({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            top: 18,
            right: 26,
            child: _dot(14, accent.withValues(alpha: 0.25)),
          ),
          Positioned(
            bottom: 24,
            left: 20,
            child: _dot(10, accent.withValues(alpha: 0.35)),
          ),
          Positioned(
            top: 40,
            left: 30,
            child: _dot(6, accent.withValues(alpha: 0.5)),
          ),
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 52, color: accent),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
