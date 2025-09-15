import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/bonus.dart';
import '../utils/constants.dart';
import '../utils/dimensions.dart';
import '../utils/date.dart';
import 'glass_container.dart';

class BonusDetailCard extends StatelessWidget {
  final Bonus bonus;
  final UserBonusProgress? progress;
  final VoidCallback onStart;

  const BonusDetailCard({
    super.key,
    required this.bonus,
    this.progress,
    required this.onStart,
  });

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
    final progressPercentage = progress != null && bonus.totalSteps > 0
        ? (progress!.currentStep / bonus.totalSteps).clamp(0.0, 1.0)
        : 0.0;
    final isExpired = AppDate.isExpired(bonus.expiryDateText);

    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        side: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasImage)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _badge(
                      label: (bonus.status ?? 'ATTIVA').toUpperCase(),
                      color: _statusColor(bonus.status ?? 'ATTIVA'),
                    ),
                  ),
                  if ((bonus.expiryDateText ?? '').trim().isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _badge(
                        label: isExpired ? 'SCADUTO' : 'Scade: ${bonus.expiryDateText!.trim()}',
                        color: isExpired ? Colors.redAccent : AppColors.brandOrange,
                      ),
                    ),
                ],
              ),

            const SizedBox(height: AppDimensions.paddingMedium),

            Text(
              bonus.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _highlightTile(
                    'Registrazione',
                    _fmt(bonus.registrationBonusAmount, bonus.registrationBonusType),
                    Icons.description_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _highlightTile(
                    'Invito',
                    _fmt(bonus.inviteBonusAmount, bonus.inviteBonusType),
                    Icons.group_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingMedium),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if ((bonus.depositRequired ?? '').trim().isNotEmpty)
                  _tag('Deposito', bonus.depositRequired!.trim()),
                if ((bonus.status ?? '').trim().isNotEmpty)
                  _tag(
                    bonus.status!.trim(),
                    '',
                    color: _statusColor(bonus.status!),
                  ),
                if (bonus.estimatedTime.trim().isNotEmpty)
                  _tag('Tempo stimato', bonus.estimatedTime.trim()),
              ],
            ),

            if ((bonus.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: AppDimensions.paddingMedium),
              Text(
                bonus.description!.trim(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.subtleGray,
                  height: 1.45,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (progress != null) ...[
              const SizedBox(height: AppDimensions.paddingMedium),
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
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progressPercentage,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress!.completed ? AppColors.successGreen : AppColors.brandBlue,
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.paddingLarge),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
                child: const Text('Inizia ora!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _highlightTile(String label, String value, IconData icon) {
    return GlassContainer(
      borderRadius: 14,
      blur: 16,
      backgroundColor: Colors.black.withOpacity(0.25),
      borderGradient: const LinearGradient(
        colors: [AppColors.brandOrange, AppColors.brandBlue],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, String value, {Color? color}) {
    final showValue = value.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          if (showValue) ...[
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                color: color ?? Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
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