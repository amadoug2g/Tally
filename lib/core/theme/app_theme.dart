import 'package:flutter/material.dart';

/// iOS Human Interface Guidelines system colors and tokens
class TallyColors {
  TallyColors._();

  // Bucket palette — iOS system colors
  static const Color life = Color(0xFF34C759);   // systemGreen
  static const Color buffer = Color(0xFF007AFF); // systemBlue
  static const Color vault = Color(0xFFAF52DE);  // systemPurple
  static const Color bills = Color(0xFFFF9F0A);  // systemOrange
  static const Color income = Color(0xFF5AC8FA); // systemTeal

  // iOS system backgrounds (light)
  static const Color systemBackground = Color(0xFFFFFFFF);
  static const Color secondarySystemBackground = Color(0xFFF2F2F7);
  static const Color groupedBackground = Color(0xFFF2F2F7);
  static const Color secondaryGroupedBackground = Color(0xFFFFFFFF);
  static const Color tertiaryGroupedBackground = Color(0xFFF2F2F7);

  // iOS label hierarchy
  static const Color label = Color(0xFF000000);
  static const Color secondaryLabel = Color(0x993C3C43);   // 60 %
  static const Color tertiaryLabel = Color(0x4D3C3C43);    // 30 %
  static const Color quaternaryLabel = Color(0x2E3C3C43);  // 18 %

  // iOS system colors
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemOrange = Color(0xFFFF9F0A);

  // Separators
  static const Color separator = Color(0xFFC6C6C8);
  static const Color fill = Color(0x1C787880); // quaternarySystemFill
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: TallyColors.groupedBackground,
        colorScheme: const ColorScheme.light(
          primary: TallyColors.systemBlue,
          surface: TallyColors.systemBackground,
          onSurface: TallyColors.label,
        ),
        cardTheme: CardThemeData(
          color: TallyColors.systemBackground,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: TallyColors.groupedBackground,
          scrolledUnderElevation: 0,
          elevation: 0,
          foregroundColor: TallyColors.label,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: TallyColors.label,
            letterSpacing: -0.4,
          ),
          iconTheme: IconThemeData(color: TallyColors.systemBlue),
          actionsIconTheme: IconThemeData(color: TallyColors.systemBlue),
        ),
        textTheme: const TextTheme(
          // Large Title
          headlineLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.37,
            color: TallyColors.label,
          ),
          // Title 1
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.36,
            color: TallyColors.label,
          ),
          // Title 2
          headlineSmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.35,
            color: TallyColors.label,
          ),
          // Title 3
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.45,
            color: TallyColors.label,
          ),
          // Headline
          titleMedium: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: TallyColors.label,
          ),
          // Subheadline
          titleSmall: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.24,
            color: TallyColors.label,
          ),
          // Body
          bodyLarge: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.normal,
            letterSpacing: -0.4,
            color: TallyColors.label,
          ),
          // Callout
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            letterSpacing: -0.32,
            color: TallyColors.label,
          ),
          // Footnote
          bodySmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            letterSpacing: -0.08,
            color: TallyColors.secondaryLabel,
          ),
          // Caption 1
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            letterSpacing: 0,
            color: TallyColors.secondaryLabel,
          ),
          // Caption 2
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.07,
            color: TallyColors.secondaryLabel,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: TallyColors.separator,
          thickness: 0.5,
          indent: 16,
          endIndent: 0,
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: TallyColors.systemBackground,
          minVerticalPadding: 11,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        iconTheme: const IconThemeData(color: TallyColors.systemBlue),
      );

  // Keep backward compat alias
  static ThemeData get dark => light;
}
