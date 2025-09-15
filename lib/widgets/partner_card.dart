import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../utils/dimensions.dart';

class PartnerCard extends StatelessWidget {
  final String name;
  final String amount;
  final String? imageUrl;      // Large cover image
  final String? logoUrl;       // Optional small logo (fallback)
  final VoidCallback? onParticipate;

  const PartnerCard({
    super.key,
    required this.name,
    required this.amount,
    this.imageUrl,
    this.logoUrl,
    this.onParticipate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: _buildCoverImage(),
          ),

          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _amountTag(amount),
                    const Spacer(),
                    if (logoUrl != null && logoUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: logoUrl!,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                          placeholder: (c, u) => _logoFallback(size: 28),
                          errorWidget: (c, u, e) => _logoFallback(size: 28),
                        ),
                      )
                    else
                      _logoFallback(size: 28),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingMedium),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onParticipate ?? () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Partecipa'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => _imageSkeleton(),
              errorWidget: (context, url, error) => _imageFallback(),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.white.withOpacity(0.06),
        alignment: Alignment.center,
        child: logoUrl != null && logoUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: logoUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (c, u) => _logoFallback(size: 56),
                  errorWidget: (c, u, e) => _logoFallback(size: 56),
                ),
              )
            : _logoFallback(size: 56),
      ),
    );
  }

  Widget _imageSkeleton() {
    return Container(
      color: Colors.white.withOpacity(0.06),
      child: const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: Colors.white.withOpacity(0.06),
      alignment: Alignment.center,
      child: _logoFallback(size: 56),
    );
  }

  Widget _logoFallback({double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: const Icon(
        Icons.business,
        color: AppColors.subtleGray,
        size: 22,
      ),
    );
  }

  Widget _amountTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}