import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.textPrimary,
          surface: AppColors.surfaceCard,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.surfaceElevated,
          secondary: AppColors.statusBlue,
          onSecondary: AppColors.textPrimary,
          error: AppColors.statusRed,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
            side: const BorderSide(color: AppColors.surfaceBorder, width: 0.5),
          ),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: AppColors.textPrimary,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.surfaceBorder,
          thickness: 0.5,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceCard,
          border: OutlineInputBorder(
            borderRadius: AppRadius.listItem,
            borderSide:
                const BorderSide(color: AppColors.surfaceBorder, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.listItem,
            borderSide:
                const BorderSide(color: AppColors.surfaceBorder, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.listItem,
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          hintStyle:
              const TextStyle(color: AppColors.textTertiary, fontSize: 14),
          labelStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shape: CircleBorder(),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceCard,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceElevated,
          contentTextStyle:
              const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.listItem),
          behavior: SnackBarBehavior.floating,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: AppRadius.listItem),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape:
                RoundedRectangleBorder(borderRadius: AppRadius.listItem),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textTertiary),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.primaryLight
                  : AppColors.surfaceElevated),
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          iconColor: AppColors.textSecondary,
          textColor: AppColors.textPrimary,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceCard,
          selectedColor: AppColors.primaryLight,
          labelStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 0.5),
          shape: const StadiumBorder(),
        ),
      );
}
