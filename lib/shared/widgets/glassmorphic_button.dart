import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GlassmorphicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? accentColor;
  final EdgeInsets padding;
  final double borderRadius;
  final bool isSmall;

  const GlassmorphicButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.borderRadius = 16,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.accent;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: color.withValues(alpha: 0.2),
            highlightColor: color.withValues(alpha: 0.1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.15),
                  ],
                ),
                border: Border.all(
                  color: color.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
              padding: isSmall
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                  : padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
