import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class StepsSection extends StatelessWidget {
  const StepsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = const [
      _StepData(
        icon: Icons.search_rounded,
        title: 'Scegli un bonus',
        desc: 'Seleziona l\'offerta che preferisci tra quelle disponibili.',
      ),
      _StepData(
        icon: Icons.checklist_rounded,
        title: 'Segui i passaggi',
        desc: 'Apri l’app partner e completa le azioni richieste.',
      ),
      _StepData(
        icon: Icons.payments_rounded,
        title: 'Ricevi il premio',
        desc: 'Ottieni il tuo bonus in tempi rapidissimi.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          const Text(
            'Come funziona',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tre semplici passaggi per iniziare subito a guadagnare.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.subtleGray),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: steps.map((s) => _StepCard(data: s)).toList(),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final IconData icon;
  final String title;
  final String desc;
  const _StepData({required this.icon, required this.title, required this.desc});
}

class _StepCard extends StatelessWidget {
  final _StepData data;
  const _StepCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.06),
              child: Icon(data.icon, color: AppColors.brandBlue),
            ),
            const SizedBox(height: 14),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.subtleGray),
            ),
          ],
        ),
      ),
    );
  }
}