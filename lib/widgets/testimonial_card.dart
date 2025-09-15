import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/dimensions.dart';

class TestimonialCard extends StatelessWidget {
  final String quote;
  final String author;
  final String role;
  final Color accent;

  const TestimonialCard({
    super.key,
    required this.quote,
    required this.author,
    required this.role,
    this.accent = AppColors.primaryLightBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightDarkBackground,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.star_rounded,
                    color: accent,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              '“$quote”',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accent.withOpacity(0.2),
                  child: Text(
                    author.isNotEmpty ? author[0] : '?',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(
                        color: AppColors.subtleGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}