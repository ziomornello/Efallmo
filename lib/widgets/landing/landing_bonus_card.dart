import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/bonus.dart';
import '../../utils/constants.dart';
import '../../utils/dimensions.dart';
import '../../utils/date.dart';
import '../glass_container.dart';

class LandingBonusCard extends StatelessWidget {
  final Bonus bonus;

  const LandingBonusCard({super.key, required this.bonus});

  String _fmt(String? amount, String? type) {
    if (amount == null || amount.trim().isEmpty) return '—';
    final a = amount.trim();
    final t = (type ?? '').trim();
    if (t.isEmpty) return a;
    if (t == '€' || t == '\$' || t == '£') return '$a$t';
    return '$a $t';
  }

  Color _statusColor(String s) {
    final v = s.toUpperCase();
    if (v.contains('ATTIVA') || v.contains('ACTIVE')) return AppColors.successGreen;
    if (v.contains('SCAD') || v.contains('ENDED')) return Colors.redAccent;
    return AppColors.subtleGray;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = (bonus.imageUrl ?? bonus.companyLogoUrl) != null;
    final isExpired = AppDate.isExpired(bonus.expiryDateText);

    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        side: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasImage)
            Stack(
              children: [
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
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if ((bonus.status ?? '').isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _badge(
                      (bonus.status ?? '').toUpperCase(),
                      _statusColor(bonus.status ?? ''),
                    ),
                  ),
                if ((bonus.expiryDateText ?? '').trim().isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _badge(
                      isExpired ? 'SCADUTO' : 'Scade: ${bonus.expiryDateText!.trim()}',
                      isExpired ? Colors.redAccent : AppColors.brandOrange,
                    ),
                  ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Text(
                    bonus.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      height: 1.1,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                    ),
                  ),
                ),
              ],
            ),

          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _liquidChip(
                        label: 'Registrazione',
                        value: _fmt(bonus.registrationBonusAmount, bonus.registrationBonusType),
                        icon: Icons.description_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _liquidChip(
                        label: 'Invito',
                        value: _fmt(bonus.inviteBonusAmount, bonus.inviteBonusType),
                        icon: Icons.group_outlined,
                      ),
                    ),
                  ],
                ),
                if ((bonus.description ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    bonus.description!.trim(),
                    style: const TextStyle(
                      color: AppColors.subtleGray,
                      fontSize: 14,
                      height: 1.45,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _liquidChip({required String label, required String value, required IconData icon}) {
    return GlassContainer(
      borderRadius: 12,
      blur: 16,
      backgroundColor: Colors.black.withOpacity(0.25),
      borderGradient: const LinearGradient(
        colors: [AppColors.brandOrange, AppColors.brandBlue],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      color: AppColors.subtleGray,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
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
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.white.withOpacity(0.06),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, color: AppColors.subtleGray),
      ),
    );
  }
}