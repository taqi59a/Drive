import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _load();
  }

  static const _key = 'locale_code';
  static const _supported = ['en', 'fr', 'nl', 'de', 'ar'];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    if (_supported.contains(code)) state = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}

const appSupportedLocales = [
  Locale('en'),
  Locale('fr'),
  Locale('nl'),
  Locale('de'),
  Locale('ar'),
];

const languageNames = {
  'en': '🇧🇪 English',
  'fr': '🇧🇪 Français',
  'nl': '🇧🇪 Nederlands',
  'de': '🇧🇪 Deutsch',
  'ar': '🇧🇪 العربية',
};
