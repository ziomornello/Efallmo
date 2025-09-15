import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/bonus_provider.dart';

class HeroSection extends ConsumerWidget {
  final VoidCallback? onDiscover;

  const HeroSection({super.key, this.onDiscover});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNarrow = MediaQuery.of(context).size.width < 820;
    final regPotential = ref.watch(registrationPotentialProvider);

    String potentialText = '€ —';
    regPotential.when(
      data: (value) {
        potentialText = '€ $value';
      },
      loading: () {},
      error: (_, __) {},
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 20 : 28, vertical: isNarrow ? 40 : 72),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Guadagna con le migliori offerte',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isNarrow ? 32 : 46,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Segui le nostre guide passo‑passo e ricevi bonus reali in pochi minuti.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isNarrow ? 14 : 16,
                  color: Colors.white.withOpacity(0.95),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/auth'),
                    child: const Text('Inizia ora'),
                  ),
                  OutlinedButton(
                    onPressed: onDiscover,
                    child: const Text('Scopri come funziona'),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Kpi(value: potentialText, label: 'Solo registrandoti oggi'),
                  const _Kpi(value: '48h', label: 'Erogazione tipica'),
                  const _Kpi(value: '100%', label: 'Offerte verificate'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String value;
  final String label;
  const _Kpi({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}