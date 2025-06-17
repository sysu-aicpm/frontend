import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const _themeKey = 'themeMode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      state = ThemeMode.values[themeIndex];
    }
  }

  Future<void> _saveTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
  }

  void toggleTheme(BuildContext context) {
    final currentBrightness = MediaQuery.of(context).platformBrightness;
    final isCurrentlyDark = (state == ThemeMode.dark) || (state == ThemeMode.system && currentBrightness == Brightness.dark);

    if (isCurrentlyDark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
    _saveTheme(state);
  }
} 