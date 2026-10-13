import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';
import 'api_service.dart';

class BookmarkService {
  Future<bool> saveBookmark({
    required String title,
    required String description,
    required String image,
    required String source,
    required String publishedAt,
    required String url,
    required String field,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null) return false;
    final response = await ApiService.post(
      "/bookmark",
      {
        "user_id": userId,
        "title": title,
        "description": description,
        "image": image,
        "source": source,
        "publishedAt": publishedAt,
        "url": url,
        "field": field,
      },
    );
    return response.statusCode == 200;
  }

  Future<List<NewsModel>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null) {
      return [];
    }
    final response = await ApiService.get(
      "/bookmarks/$userId",
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List articles = data["bookmarks"];
      return articles
          .map(
            (e) => NewsModel.fromJson(e),
          )
          .toList();
    }
    throw Exception("Failed to load bookmarks.");
  }

  Future<bool> deleteBookmark(
    String bookmarkId,
  ) async {
    final response = await ApiService.delete(
      "/bookmark/$bookmarkId",
    );
    return response.statusCode == 200;
  }
}