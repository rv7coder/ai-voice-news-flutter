import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class UserService {
  Future<String?> saveUserPreference({
    required String userName,
    required List<String> fields,
    required String country,
    required String state,
    required String city,
  }) async {
    final response = await ApiService.post(
      "/select-field",
      {
        "user_name": userName,
        "fields": fields,
        "country": country,
        "state": state,
        "city": city,
      },
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userId = data["user_id"];
      final returnedUserName = data["user_name"];
      if (userId == null) {
        return null;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        "user_id",
        userId.toString(),
      );
      await prefs.setString(
        "user_name",
        returnedUserName?.toString() ?? userName,
      );
      await prefs.setStringList(
        "preferredCategories",
        fields,
      );
      await prefs.setString(
        "country",
        country,
      );
      await prefs.setString(
        "state",
        state,
      );
      await prefs.setString(
        "city",
        city,
      );
      return userId.toString();
    }
    return null;
  }

  Future<String?> saveSingleCategoryPreference({
    required String userName,
    required String field,
    required String country,
    required String state,
    required String city,
  }) async {
    return saveUserPreference(
      userName: userName,
      fields: [field],
      country: country,
      state: state,
      city: city,
    );
  }

  Future<bool> updateUserPreferences({
    required List<String> fields,
  }) async {
    if (fields.isEmpty) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null || userId.isEmpty) {
      return false;
    }
    final response = await ApiService.put(
      "/user-preference/$userId",
      {
        "fields": fields,
      },
    );
    if (response.statusCode == 200) {
      await prefs.setStringList(
        "preferredCategories",
        fields,
      );
      return true;
    }
    return false;
  }
}