import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Gradient? borderGradient;
  final double borderWidth;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 18,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor = const Color(0x40FFFFFF),
    this.borderGradient,
    this.borderWidth = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: br,
      child: Stack(
        children: [
          // Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(),
          ),
          // Background + fallback border (when no gradient border)
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: br,
              border: Border.all(
                width: borderGradient == null ? borderWidth : 0.0,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            padding: padding,
            child: child,
          ),
          // Gradient border stroke only (no fill)
          if (borderGradient != null)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GradientBorderPainter(
                    gradient: borderGradient!,
                    strokeWidth: borderWidth,
                    radius: borderRadius,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double strokeWidth;
  final double radius;

  _GradientBorderPainter({
    required this.gradient,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}