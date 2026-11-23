import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF7C3AED);
  static const Color accent = Color(0xFF0D9488);

  // Background and surfaces
  static const Color background = Color(0xFF060A16);
  static const Color surface = Color(0xFF111A2E);

  // Glass card (translucent white over the dark background)
  static const Color glassFill = Color(0x14FFFFFF); // ~8%
  static const Color glassBorder = Color(0x26FFFFFF); // ~15%

  // Glow colors used by the global background
  static const Color glowBlue = Color(0xFF2563EB);
  static const Color glowPurple = Color(0xFF7C3AED);

  // Gradient gradients for icon tiles
  static const List<Color> blueGradient = [Color(0xFF5B8CFF), Color(0xFF2563EB)];
  static const List<Color> purpleGradient = [Color(0xFF8B5CF6), Color(0xFF7C3AED)];

  // Text colors
  static const Color primaryText = Color(0xFFF1F5F9);
  static const Color secondaryText = Color(0xFF94A3B8);
  static const Color label = Color(0xFF7DB4FF);

  // Borders
  static const Color border = Color(0x26FFFFFF);

  // Status colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
}

/// Wrap the whole app with this (see MaterialApp.builder) so every screen
/// gets the same dark background with blue + purple glows.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  Widget _glow(Color color, double size) {
    //This widget prevents the child from receiving pointer interactions
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -100,
            child: _glow(AppColors.glowBlue, 420),
          ),
          Positioned(
            bottom: -140,
            right: -120,
            child: _glow(AppColors.glowPurple, 420),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    final radius12 = BorderRadius.circular(12);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: radius12,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      // Transparent so the global AppBackground shows through every screen
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      // App bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
        ),
      ),
      // Cards (glass look)
      cardTheme: CardThemeData(
        color: AppColors.glassFill,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      // Text fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.secondaryText),
        labelStyle: const TextStyle(color: AppColors.secondaryText),
        border: inputBorder(AppColors.border),
        enabledBorder: inputBorder(AppColors.border),
        focusedBorder: inputBorder(AppColors.primary, 1.5),
        errorBorder: inputBorder(AppColors.error),
        focusedErrorBorder: inputBorder(AppColors.error, 1.5),
      ),
      // Primary buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      // Secondary buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.glassFill,
          foregroundColor: AppColors.primaryText,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.glassBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.label),
      ),
      // Dialogs, sheets, snackbars
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(color: AppColors.primaryText),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radius12),
      ),
      // Typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          height: 1.1,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColors.primaryText,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryText,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: AppColors.primaryText),
        bodyMedium: TextStyle(fontSize: 14, height: 1.3, color: AppColors.primaryText),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.secondaryText),
      ),
      // Icons
      iconTheme: const IconThemeData(color: AppColors.primaryText),
      // Dividers
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    );
  }
}