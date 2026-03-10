import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Color tintColor;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double borderOpacity;
  final bool hasBorder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.blur = AppConstants.glassBlur,
    this.opacity = 0.08,
    this.borderRadius = AppConstants.glassBorderRadius,
    this.tintColor = Colors.white,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderOpacity = 0.15,
    this.hasBorder = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tintColor.withValues(alpha: opacity + 0.04),
                  tintColor.withValues(alpha: opacity),
                  tintColor.withValues(alpha: opacity - 0.02),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: hasBorder
                  ? Border.all(
                      color: tintColor.withValues(alpha: borderOpacity),
                      width: AppConstants.glassBorderWidth,
                    )
                  : null,
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null || onLongPress != null) {
      card = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: card,
      );
    }

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}
