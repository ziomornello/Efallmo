import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/bonus_provider.dart';
import 'landing_bonus_card.dart';

class PartnersSection extends ConsumerWidget {
  const PartnersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bonusesAsync = ref.watch(publicBonusesProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          const Text(
            'Bonus attivi',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Scegli un bonus e scopri quanto guadagni: registrazione e invito.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.subtleGray),
          ),
          const SizedBox(height: 20),

          bonusesAsync.when(
            data: (bonuses) {
              if (bonuses.isEmpty) {
                return const Text(
                  'Nessun bonus attivo al momento.',
                  style: TextStyle(color: AppColors.subtleGray),
                );
              }

              // Vertical cards (not a horizontal list)
              return Column(
                children: bonuses.map((b) => LandingBonusCard(bonus: b)).toList(),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandBlue),
              ),
            ),
            error: (err, st) => const Text(
              'Impossibile caricare i bonus in questo momento.',
              style: TextStyle(color: AppColors.subtleGray),
            ),
          ),
        ],
      ),
    );
  }
}