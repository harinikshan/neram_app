import 'dart:ui';

class AppColors {
  AppColors._();

  // Background
  static const Color backgroundDark = Color(0xFF060611);
  static const Color backgroundMid = Color(0xFF0E0E1F);
  static const Color backgroundLight = Color(0xFF161630);

  // Glass
  static const Color glassFill = Color(0x14FFFFFF); // white 8%
  static const Color glassBorder = Color(0x33FFFFFF); // white 20%
  static const Color glassHighlight = Color(0x0DFFFFFF); // white 5%

  // Accent
  static const Color accent = Color(0xFF00D4AA); // Teal-mint
  static const Color accentGlow = Color(0x3300D4AA);
  static const Color accentSecondary = Color(0xFF4D90FF); // Steel blue

  // Clock
  static const Color clockFace = Color(0xFF1A1A2E);
  static const Color clockFaceLight = Color(0xFF252540);
  static const Color clockDigit = Color(0xFFEEEEEE);
  static const Color clockDivider = Color(0xFF0A0A18);
  static const Color clockShadow = Color(0x80000000);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x99FFFFFF); // 60%
  static const Color textTertiary = Color(0x4DFFFFFF); // 30%

  // Status
  static const Color masterBadge = Color(0xFFFFB800);
  static const Color danger = Color(0xFFFF4757);
  static const Color success = Color(0xFF2ED573);

  // Gradient backgrounds
  static const List<Color> meshGradient = [
    Color(0xFF060611),
    Color(0xFF0A0D16),
    Color(0xFF0D111B),
    Color(0xFF080B14),
  ];
}
