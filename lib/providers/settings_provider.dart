import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool darkMode = false;
  bool autoPlay = false;
  double playbackSpeed = 1.0;
  List<String> preferredCategories = [];

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool("darkMode") ?? false;
    autoPlay = prefs.getBool("autoPlay") ?? false;
    playbackSpeed = prefs.getDouble("playbackSpeed") ?? 1.0;
    preferredCategories =
        prefs.getStringList("preferredCategories") ?? [];
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);
    notifyListeners();
  }

  Future<void> setAutoPlay(bool value) async {
    autoPlay = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("autoPlay", value);
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double value) async {
    playbackSpeed = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("playbackSpeed", value);
    notifyListeners();
  }

  Future<bool> setPreferredCategories(
    List<String> categories,
  ) async {
    if (categories.isEmpty) {
      return false;
    }
    final newCategories = List<String>.from(categories);
    final oldCategories = List<String>.from(preferredCategories);
    try {
      final userService = UserService();
      final success = await userService.updateUserPreferences(
        fields: newCategories,
      );
      if (!success) {
        preferredCategories = oldCategories;
        notifyListeners();
        return false;
      }
      preferredCategories = newCategories;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        "preferredCategories",
        preferredCategories,
      );
      notifyListeners();
      return true;
    } catch (_) {
      preferredCategories = oldCategories;
      notifyListeners();
      return false;
    }
  }
}