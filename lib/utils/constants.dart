import 'package:flutter/material.dart';

class AppColors {
  // Base
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color lightDarkBackground = Color(0xFF1A1A1A);

  // Brand colors
  static const Color brandOrange = Color(0xFFFF9C40); // #ff9c40
  static const Color brandBlue = Color(0xFF0F638C);   // #0f638c

  // Backwards-compat names
  static const Color primaryOrange = brandOrange;
  static const Color primaryLightBlue = brandBlue;
  static const Color primaryDarkBlue = brandBlue;

  // Accents
  static const Color accentPurple = brandBlue;
  static const Color accentPink = brandOrange;
  static const Color accentBlue = brandBlue;

  // Common
  static const Color white = Colors.white;
  static const Color subtleGray = Color(0xFFA1A1AA);
  static const Color successGreen = Color(0xFF10B981);

  // Gradients
  static const LinearGradient ctaGradient = LinearGradient(
    colors: [brandOrange, brandBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [brandBlue, brandOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppLinks {
  // Deep link used for Supabase Email Redirect
  static const String authCallback = 'efallmo://auth-callback';
}