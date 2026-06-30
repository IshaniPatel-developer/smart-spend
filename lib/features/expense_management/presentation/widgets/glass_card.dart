import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? color;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.color,
    this.borderRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color ?? AppTheme.glassCardFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppTheme.borderLight.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
