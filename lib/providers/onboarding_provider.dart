import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  List<String> selectedCategories = [];
  String? selectedCategory;
  String? country;
  String? state;
  String? city;
  String? userId;
  String? userName;

  OnboardingProvider() {
    loadSavedUserData();
  }

  Future<void> loadSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString("user_id");
    final savedUserName = prefs.getString("user_name");
    final savedCategories = prefs.getStringList("preferredCategories");
    final savedCountry = prefs.getString("country");
    final savedState = prefs.getString("state");
    final savedCity = prefs.getString("city");
    if (userId == null || userId!.isEmpty) {
      userId = savedUserId;
    }
    if (userName == null || userName!.isEmpty) {
      userName = savedUserName;
    }
    if (selectedCategories.isEmpty && savedCategories != null) {
      selectedCategories = List<String>.from(savedCategories);
    }
    if (country == null || country!.isEmpty) {
      country = savedCountry;
    }
    if (state == null || state!.isEmpty) {
      state = savedState;
    }
    if (city == null || city!.isEmpty) {
      city = savedCity;
    }
    selectedCategory = selectedCategories.isNotEmpty
        ? selectedCategories.first
        : null;
    notifyListeners();
  }

  Future<void> setCategories(List<String> categories) async {
    selectedCategories = List<String>.from(categories);
    selectedCategory = selectedCategories.isNotEmpty
        ? selectedCategories.first
        : null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "preferredCategories",
      selectedCategories,
    );
  }

  Future<void> toggleCategory(String category) async {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    selectedCategory = selectedCategories.isNotEmpty
        ? selectedCategories.first
        : null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "preferredCategories",
      selectedCategories,
    );
  }

  Future<void> setCategory(String category) async {
    selectedCategories = [category];
    selectedCategory = category;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "preferredCategories",
      selectedCategories,
    );
  }

  Future<void> setLocation({
    required String country,
    required String state,
    required String city,
  }) async {
    this.country = country;
    this.state = state;
    this.city = city;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("country", country);
    await prefs.setString("state", state);
    await prefs.setString("city", city);
  }

  Future<void> setUserName(String name) async {
    userName = name.trim();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (userName!.isNotEmpty) {
      await prefs.setString(
        "user_name",
        userName!,
      );
    }
  }

  Future<void> setUserId(String id) async {
    userId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "user_id",
      id,
    );
  }

  Future<void> clear() async {
    selectedCategories = [];
    selectedCategory = null;
    country = null;
    state = null;
    city = null;
    userId = null;
    userName = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user_id");
    await prefs.remove("user_name");
    await prefs.remove("preferredCategories");
    await prefs.remove("country");
    await prefs.remove("state");
    await prefs.remove("city");
  }
}