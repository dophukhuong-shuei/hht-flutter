import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors - Pink (matching React Native)
  static const Color primary = Color(0xFFc02941); // '#c02941'
  static const Color primaryLight = Color(0xFFf05577); // '#f05577'
  static const Color primaryDark = Color(0xFF8c0032); // '#8c0032'
  static const Color lighter = Color(0xFFF3F3F3); // '#F3F3F3'
  
  // Accent Colors
  static const Color greenDark = Color(0xFF207868);
  static const Color btnGreen = Color(0xFF4CAF50);
  static const Color btnRed = Color(0xFFF44336);
  
  // Text Colors
  static const Color black = Color(0xFF000000);
  static const Color blackText = Color(0xFF212121);
  static const Color textPlaceholder = Color(0xFF9E9E9E);
  static const Color textError = Color(0xFFD32F2F);
  static const Color textBlueDark = Color(0xFF1565C0);
  
  // Background Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFF9E9E9E);
  static const Color headerColor = Color(0xFFF5F5F5);
  
  // Menu Colors
  static const List<Color> menuColors = [
    Color(0xFFd3455b), // 入荷
    Color(0xFF2c88d9), // 棚上げ
    Color(0xFF207868), // ピッキング
    Color(0xFFa5c9c2), // 事前セット
    Color(0xFFbd34d1), // 棚移動
    Color(0xFFac6363), // 棚卸
    Color(0xFFc3cfd9), // ログアウト
  ];

  // Additional colors from React Native
  static const Color orange_light = Color(0xFFfae6d8);
  static const Color Settings_Colors_3 = Color(0xFFfd9627);
  static const Color btn_red = Color(0xFFd3455b);
  static const Color btn_blue = Color(0xFF2c88d9);
  static const Color btn_brown = Color(0xFF8B4513);
  static const Color borderTable = Color(0xFFc3cfd9);
  static const Color text_warning = Color(0xFFFFA500);
  static const Color text_placeholder = Color(0xFF666666);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary, // Pink primary
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.greenDark,
        error: AppColors.textError,
        surface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.headerColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        titleTextStyle: GoogleFonts.notoSans(
          color: AppColors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: GoogleFonts.notoSansTextTheme(),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lighter, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lighter, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2), // Pink focus
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.textError, width: 2),
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight, // Pink button
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

