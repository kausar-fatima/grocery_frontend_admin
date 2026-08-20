import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Renders a product/category illustration.
///
/// Today [image] is an emoji shown on a soft tinted background — clean,
/// reliable and asset-free. If [image] is ever a URL/asset path the switch
/// here is the only place that needs to change.
class FoodAvatar extends StatelessWidget {
  final String image;
  final double size;
  final Color? background;
  final double radius;
  final EdgeInsets padding;

  const FoodAvatar({
    super.key,
    required this.image,
    this.size = 64,
    this.background,
    this.radius = 16,
    this.padding = const EdgeInsets.all(8),
  });

  bool get _isEmoji => !image.startsWith('http') && !image.startsWith('assets');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: _isEmoji
          ? FittedBox(
              fit: BoxFit.contain,
              child: Text(image, style: const TextStyle(fontSize: 40)),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(radius - 4),
              child: Image.network(image, fit: BoxFit.cover),
            ),
    );
  }
}
