import 'package:flutter/material.dart';
import '../../widgets/cta_banner.dart';

class CtaSection extends StatelessWidget {
  final VoidCallback onPressed;
  const CtaSection({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: CtaBanner(
        title: 'Inizia ora e unisciti alla community',
        subtitle: 'Registrati gratis: bastano pochi secondi.',
        buttonText: 'Crea un account',
        onPressed: onPressed,
      ),
    );
  }
}