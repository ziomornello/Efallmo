import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/dimensions.dart';

class KpiChip extends StatelessWidget {
  final String value;
  final String label;

  const KpiChip({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.lightDarkBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              colors: [AppColors.primaryOrange, AppColors.primaryLightBlue],
            ).createShader(rect),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.subtleGray,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}