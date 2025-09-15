import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/testimonial_card.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          const Text(
            'Cosa dice la community',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Esperienze reali di chi ha già iniziato a guadagnare.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.subtleGray),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: const [
              SizedBox(
                width: 340,
                child: TestimonialCard(
                  quote: 'Ho completato 3 offerte e ricevuto i bonus in 48 ore.',
                  author: 'Giulia',
                  role: 'Studentessa',
                  accent: AppColors.primaryLightBlue,
                ),
              ),
              SizedBox(
                width: 340,
                child: TestimonialCard(
                  quote: 'Offerte semplici e pagamenti rapidi. Consigliato!',
                  author: 'Marco',
                  role: 'Impiegato',
                  accent: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}