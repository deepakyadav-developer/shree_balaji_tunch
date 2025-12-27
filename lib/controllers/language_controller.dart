import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class LanguageController extends GetxController {
  final RxString currentLanguage = 'en_US'.obs;
  final String languageKey = 'selected_language';

  @override
  void onInit() {
    super.onInit();
    loadSavedLanguage();
  }

  Future<void> loadSavedLanguage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedLanguage = prefs.getString(languageKey);

      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        currentLanguage.value = savedLanguage;
        updateLocale(savedLanguage);
        print("Loaded language: $savedLanguage"); // Debug print
      } else {
        print(
            "No saved language found, using default: ${currentLanguage.value}"); // Debug print
      }
    } catch (e) {
      print("Error loading language: $e"); // Debug print
    }
  }

  void changeLanguage(String languageCode) async {
    try {
      currentLanguage.value = languageCode;
      updateLocale(languageCode);
      await saveLanguage(languageCode);
      print("Changed language to: $languageCode"); // Debug print
    } catch (e) {
      print("Error changing language: $e"); // Debug print
    }
  }

  void updateLocale(String languageCode) {
    Locale locale;
    switch (languageCode) {
      case 'hi_IN':
        locale = Locale('hi', 'IN');
        break;
      case 'bho_IN':
        locale = Locale('bho', 'IN');
        break;
      default:
        locale = Locale('en', 'US');
    }
    Get.updateLocale(locale);
  }

  Future<void> saveLanguage(String languageCode) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(languageKey, languageCode);
      print("Saved language: $languageCode"); // Debug print
    } catch (e) {
      print("Error saving language: $e"); // Debug print
    }
  }
}
