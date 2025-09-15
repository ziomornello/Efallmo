import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/bonus.dart';
import '../utils/constants.dart';
import '../utils/dimensions.dart';

class BonusCard extends StatelessWidget {
  final Bonus bonus;
  final UserBonusProgress? progress;
  final VoidCallback? onTap;

  const BonusCard({
    super.key,
    required this.bonus,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercentage =
        progress != null && bonus.totalSteps > 0 ? (progress!.currentStep / bonus.totalSteps).clamp(0.0, 1.0) : 0.0;

    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        side: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if ((bonus.imageUrl ?? bonus.companyLogoUrl) != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: bonus.imageUrl ?? bonus.companyLogoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _imageSkeleton(),
                    errorWidget: (context, url, error) => _imageFallback(),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bonus.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (bonus.description != null && bonus.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      bonus.description!.trim(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.subtleGray,
                        height: 1.45,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  if (progress != null) ...[
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progress!.completed
                              ? 'Completato!'
                              : 'Progresso: ${progress!.currentStep}/${bonus.totalSteps}',
                          style: TextStyle(
                            fontSize: 12,
                            color: progress!.completed ? AppColors.successGreen : AppColors.subtleGray,
                            fontWeight: progress!.completed ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progressPercentage,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress!.completed ? AppColors.successGreen : AppColors.brandBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSkeleton() {
    return Container(
      color: Colors.white.withOpacity(0.06),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: Colors.white.withOpacity(0.06),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: AppColors.subtleGray),
    );
  }
}