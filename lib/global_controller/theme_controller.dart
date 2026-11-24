import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  // ====================================
  // STORAGE
  // ====================================

  final GetStorage _storage = GetStorage();

  static const String _themeKey = 'app_theme_mode';

  // ====================================
  // REACTIVE THEME STATE
  // ====================================

  final RxBool isDarkMode = false.obs;

  // ====================================
  // INITIALIZATION
  // ====================================

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  // ====================================
  // LOAD SAVED THEME
  // ====================================

  void loadTheme() {
    final String? savedTheme = _storage.read<String>(_themeKey);

    // Default theme is LIGHT.
    isDarkMode.value = savedTheme == 'dark';
  }

  // ====================================
  // CURRENT THEME MODE
  // ====================================

  ThemeMode get themeMode {
    return isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  }

  // ====================================
  // TOGGLE LIGHT / DARK
  // ====================================

  Future<void> toggleTheme() async {
    await setDarkMode(!isDarkMode.value);
  }

  // ====================================
  // SET DARK MODE
  // ====================================

  Future<void> setDarkMode(bool value) async {
    isDarkMode.value = value;

    await _storage.write(_themeKey, value ? 'dark' : 'light');

    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  // ====================================
  // ENABLE LIGHT MODE
  // ====================================

  Future<void> enableLightMode() async {
    await setDarkMode(false);
  }

  // ====================================
  // ENABLE DARK MODE
  // ====================================

  Future<void> enableDarkMode() async {
    await setDarkMode(true);
  }

  // ====================================
  // THEME HELPERS
  // ====================================

  bool get isLightMode => !isDarkMode.value;

  bool get isDark => isDarkMode.value;
}
