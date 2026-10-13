import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';
import 'api_service.dart';

class NewsService {
  Future<List<NewsModel>> getRecommendedNews() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null || userId.isEmpty) {
      return [];
    }
    final response = await ApiService.get(
      "/recommended-news/$userId",
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = data["articles"] as List? ?? [];
      return articles
          .map((e) => NewsModel.fromJson(e))
          .toList();
    }
    throw Exception("Unable to fetch recommended news");
  }

  Future<List<NewsModel>> getLocationNews() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null || userId.isEmpty) {
      throw Exception("User ID not found. Please complete onboarding.");
    }
    final response = await ApiService.get(
      "/location-news/$userId",
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = data["articles"] as List? ?? [];
      return articles
          .map((e) => NewsModel.fromJson(e))
          .toList();
    }
    throw Exception(
      "Unable to fetch location news (${response.statusCode})",
    );
  }

  Future<List<NewsModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null || userId.isEmpty) {
      throw Exception("User ID not found. Please complete onboarding.");
    }
    final response = await ApiService.get(
      "/notifications/$userId",
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = data["notifications"] as List? ?? [];
      return articles
          .map((e) => NewsModel.fromJson(e))
          .toList();
    }
    throw Exception(
      "Unable to fetch notifications (${response.statusCode})",
    );
  }

  Future<List<NewsModel>> searchNews(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null || userId.isEmpty) {
      throw Exception("User ID not found. Please complete onboarding.");
    }
    final response = await ApiService.post(
      "/search-news",
      {
        "user_id": userId,
        "query": query,
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = data["articles"] as List? ?? [];
      return articles
          .map((e) => NewsModel.fromJson(e))
          .toList();
    }
    throw Exception(
      "Failed to search news (${response.statusCode})",
    );
  }

  Future<List<NewsModel>> updateCategoryAndGetNews(
    String field,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null || userId.isEmpty) {
      throw Exception("User ID not found.");
    }
    final response = await ApiService.post(
      "/select-field",
      {
        "field": field,
        "country": prefs.getString("country") ?? "",
        "state": prefs.getString("state") ?? "",
        "city": prefs.getString("city") ?? "",
      },
    );
    if (response.statusCode != 200) {
      throw Exception(
        "Failed to update category (${response.statusCode})",
      );
    }
    final data = jsonDecode(response.body);
    final returnedUserId = data["user_id"];
    if (returnedUserId != null) {
      await prefs.setString("user_id", returnedUserId);
    }
    final newsResponse = await ApiService.get(
      "/recommended-news/${prefs.getString("user_id")}",
    );
    if (newsResponse.statusCode != 200) {
      throw Exception(
        "Failed to load recommended news (${newsResponse.statusCode})",
      );
    }
    final newsData = jsonDecode(newsResponse.body);
    final articles = newsData["articles"] as List? ?? [];
    return articles
        .map((e) => NewsModel.fromJson(e))
        .toList();
  }

  Future<List<NewsModel>> changeCategory(
    String field,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null || userId.isEmpty) {
      throw Exception("User ID not found.");
    }
    final response = await ApiService.put(
      "/user-preference/$userId",
      {
        "field": field,
      },
    );
    if (response.statusCode != 200) {
      throw Exception(
        "Failed to change category (${response.statusCode})",
      );
    }
    final newsResponse = await ApiService.get(
      "/recommended-news/$userId",
    );
    if (newsResponse.statusCode != 200) {
      throw Exception(
        "Failed to load news (${newsResponse.statusCode})",
      );
    }
    final data = jsonDecode(newsResponse.body);
    final articles = data["articles"] as List? ?? [];
    return articles
        .map((e) => NewsModel.fromJson(e))
        .toList();
  }
}