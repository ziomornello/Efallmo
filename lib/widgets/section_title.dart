import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/dimensions.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;
  final TextAlign textAlign;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.padding,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment:
            textAlign == TextAlign.left ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: textAlign,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              height: 1.1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: textAlign,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.subtleGray,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}