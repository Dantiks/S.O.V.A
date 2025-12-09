import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finer/core/constants/app_constants.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeState {
  final AppThemeMode themeMode;
  final Color accentColor;

  ThemeState({
    required this.themeMode,
    required this.accentColor,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    Color? accentColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

class ThemeController extends StateNotifier<ThemeState> {
  final SharedPreferences _prefs;

  ThemeController(this._prefs)
      : super(ThemeState(
          themeMode: AppThemeMode.dark,
          accentColor: const Color(0xFF7A3DF2),
        )) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeModeString = _prefs.getString(AppConstants.themeKey);
    final accentColorValue = _prefs.getInt(AppConstants.accentColorKey);

    state = ThemeState(
      themeMode: _parseThemeMode(themeModeString),
      accentColor: accentColorValue != null
          ? Color(accentColorValue)
          : const Color(0xFF7A3DF2),
    );
  }

  AppThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.dark;
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _prefs.setString(AppConstants.themeKey, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setAccentColor(Color color) async {
    await _prefs.setInt(AppConstants.accentColorKey, color.value);
    state = state.copyWith(accentColor: color);
  }

  ThemeMode getEffectiveThemeMode() {
    switch (state.themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeController(prefs);
});
