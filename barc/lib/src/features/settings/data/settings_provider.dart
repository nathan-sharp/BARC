import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final String fontFamily;
  final double textScale;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.fontFamily = 'Default',
    this.textScale = 1.0,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? fontFamily,
    double? textScale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontFamily: fontFamily ?? this.fontFamily,
      textScale: textScale ?? this.textScale,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _themeModeKey = 'barc_theme_mode';
  static const _fontFamilyKey = 'barc_font_family';
  static const _textScaleKey = 'barc_text_scale';

  late final SharedPreferences _prefs;

  @override
  AppSettings build() {
    // We start with default state until SharedPreferences loads.
    // However, riverpod allows us to load this synchronously if we override it with
    // a ProviderScope, or we can just initialize it asynchronously.
    // For simplicity, we'll expose a FutureProvider to initialize and then use this Notifier.
    return const AppSettings();
  }

  void setPrefs(SharedPreferences prefs) {
    _prefs = prefs;
    final themeIndex = _prefs.getInt(_themeModeKey);
    final font = _prefs.getString(_fontFamilyKey);
    final scale = _prefs.getDouble(_textScaleKey);
    
    state = AppSettings(
      themeMode: themeIndex != null ? ThemeMode.values[themeIndex] : ThemeMode.system,
      fontFamily: font ?? 'Default',
      textScale: scale ?? 1.0,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setInt(_themeModeKey, mode.index);
  }

  void setFontFamily(String font) {
    state = state.copyWith(fontFamily: font);
    _prefs.setString(_fontFamilyKey, font);
  }

  void setTextScale(double scale) {
    state = state.copyWith(textScale: scale);
    _prefs.setDouble(_textScaleKey, scale);
  }
}

final settingsNotifierProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

// We need a provider that loads SharedPreferences first
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  ref.read(settingsNotifierProvider.notifier).setPrefs(prefs);
  return prefs;
});
