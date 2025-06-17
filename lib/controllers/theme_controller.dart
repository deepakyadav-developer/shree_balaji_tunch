import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> currentThemeMode = ThemeMode.light.obs;
  final String themeKey = 'theme_mode';

  @override
  void onInit() {
    super.onInit();
    loadThemeMode();

    // Force light theme on startup
    changeThemeMode(ThemeMode.light);
  }

  Future<void> loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeMode =
        prefs.getString(themeKey) ?? 'light'; // Default to 'light'

    switch (themeMode) {
      case 'dark':
        currentThemeMode.value = ThemeMode.dark;
        break;
      case 'system':
        currentThemeMode.value = ThemeMode.system;
        break;
      default:
        currentThemeMode.value = ThemeMode.light;
    }

    // Apply the theme immediately after loading
    Get.changeThemeMode(currentThemeMode.value);
  }

  Future<void> changeThemeMode(ThemeMode themeMode) async {
    currentThemeMode.value = themeMode;
    Get.changeThemeMode(themeMode);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeModeString;

    switch (themeMode) {
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
      default:
        themeModeString = 'light';
    }

    await prefs.setString(themeKey, themeModeString);
  }
}
