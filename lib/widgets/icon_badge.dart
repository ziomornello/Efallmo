import 'package:flutter/material.dart';
import '../utils/constants.dart';

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color? background;
  final Color? iconColor;
  final double size;

  const IconBadge({
    super.key,
    required this.icon,
    this.background,
    this.iconColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.primaryLightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor ?? Colors.white,
        size: size * 0.5,
      ),
    );
  }
}