import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          Divider(color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          const Text(
            'Efallmò — Guadagna testando app finanziarie',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© $year Efallmò — Tutti i diritti riservati',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.subtleGray),
          ),
        ],
      ),
    );
  }
}