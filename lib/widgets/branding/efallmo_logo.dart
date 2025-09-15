import 'package:flutter/material.dart';

class EfallmoLogo extends StatelessWidget {
  final bool horizontal; // true: logo_orizzontale, false: logo_quadrato
  final double height;

  const EfallmoLogo({
    super.key,
    this.horizontal = true,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    final path = horizontal
        ? 'assets/images/logo_orizzontale.png'
        : 'assets/images/logo_quadrato.png';
    return SizedBox(
      height: height,
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) {
          return Text(
            'Efallmò',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: height * 0.55,
            ),
          );
        },
      ),
    );
  }
}