import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFFBA68C8); // Soft Purple
  static const Color accentColor = Color(0xFFFFCCBC); // Light Pink
  static const Color backgroundColor = Color(0xFFF5F0FF); // Light Lavender
  static const Color cardBackgroundColor = Color(0xFFFFFFFF); // White

  // Text Colors
  static const Color primaryTextColor = Color(0xFF6A1B9A); // Dark Purple
  static const Color secondaryTextColor = Color(0xFF757575); // Gray

  // Button Colors
  static const Color buttonColor = Color(0xFF8E24AA); // Vibrant Purple

  // Status Colors
  static const Color openStatusColor = Color(0xFF4CAF50); // Green
  static const Color closedStatusColor = Color(0xFFBDBDBD); // Gray
}

// Light Theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.backgroundColor,
  cardColor: AppColors.cardBackgroundColor,

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.primaryTextColor, fontSize: 18),
    bodyMedium: TextStyle(color: AppColors.secondaryTextColor, fontSize: 16),
    labelLarge: TextStyle(color: AppColors.primaryColor, fontSize: 14),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryColor,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(AppColors.buttonColor),
      foregroundColor: MaterialStatePropertyAll(Colors.white),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
    ),
  ),

  chipTheme: const ChipThemeData(
    backgroundColor: AppColors.closedStatusColor,
    selectedColor: AppColors.openStatusColor,
    labelStyle: TextStyle(color: Colors.white),
  ),

  buttonTheme: const ButtonThemeData(
    buttonColor: AppColors.buttonColor,
    textTheme: ButtonTextTheme.primary,
  ),
);