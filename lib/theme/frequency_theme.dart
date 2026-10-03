import 'package:flutter/material.dart';

abstract final class FrequencyPalette {
  static const background = Color(0xFF111315);
  static const surface = Color(0xFF1B1E20);
  static const elevated = Color(0xFF25292C);
  static const text = Color(0xFFF4F2E9);
  static const muted = Color(0xFFADB1A9);
  static const accent = Color(0xFFD6EF36);
  static const amber = Color(0xFFFFB23F);
  static const border = Color(0xFF41484B);
  static const selected = Color(0xFF303719);
  static const error = Color(0xFFFF9691);
  static const success = Color(0xFFA8D978);
}

abstract final class FrequencyTheme {
  static ThemeData dark({String? fontFamily}) {
    const p = FrequencyPalette.background;
    final scheme = const ColorScheme.dark(
      primary: FrequencyPalette.accent, onPrimary: p,
      secondary: FrequencyPalette.amber, onSecondary: p,
      surface: FrequencyPalette.surface, onSurface: FrequencyPalette.text,
      error: FrequencyPalette.error, onError: p,
      outline: FrequencyPalette.border,
    );
    return ThemeData(
      useMaterial3: true, fontFamily: fontFamily, visualDensity: VisualDensity.standard,
      colorScheme: scheme, scaffoldBackgroundColor: p,
      canvasColor: FrequencyPalette.surface,
      dividerColor: FrequencyPalette.border,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, height: 1.6, color: FrequencyPalette.text),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: FrequencyPalette.text),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: FrequencyPalette.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: FrequencyPalette.border)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: FrequencyPalette.accent, width: 2)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48), foregroundColor: p,
        backgroundColor: FrequencyPalette.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).copyWith(side: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.focused)
          ? const BorderSide(color: FrequencyPalette.text, width: 2) : BorderSide.none))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48), foregroundColor: FrequencyPalette.accent,
        side: const BorderSide(color: FrequencyPalette.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).copyWith(side: WidgetStateProperty.resolveWith((states) => BorderSide(
        color: states.contains(WidgetState.focused) ? FrequencyPalette.accent : FrequencyPalette.border,
        width: states.contains(WidgetState.focused) ? 2 : 1,
      )))),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
        minimumSize: const Size(48, 48), foregroundColor: FrequencyPalette.accent,
      ).copyWith(side: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.focused)
          ? const BorderSide(color: FrequencyPalette.accent, width: 2) : BorderSide.none))),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(
        minimumSize: const Size(48, 48), foregroundColor: FrequencyPalette.accent,
      ).copyWith(side: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.focused)
          ? const BorderSide(color: FrequencyPalette.accent, width: 2) : BorderSide.none))),
      chipTheme: ChipThemeData(
        labelStyle: const TextStyle(color: FrequencyPalette.text, fontSize: 14, height: 1.5, fontWeight: FontWeight.w600),
        checkmarkColor: FrequencyPalette.accent,
        selectedColor: FrequencyPalette.selected,
        side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
          color: states.contains(WidgetState.focused) ? FrequencyPalette.accent : FrequencyPalette.border,
          width: states.contains(WidgetState.focused) ? 2 : 1,
        )),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: p, foregroundColor: FrequencyPalette.text, elevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: FrequencyPalette.elevated,
        contentTextStyle: TextStyle(color: FrequencyPalette.text, fontSize: 14),
      ),
    );
  }
}
