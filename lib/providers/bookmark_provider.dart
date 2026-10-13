import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/bookmark_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final BookmarkService _service = BookmarkService();
  bool isLoading = false;
  String? error;
  List<NewsModel> bookmarks = [];
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
  void setError(String? value) {
    error = value;
    notifyListeners();
  }

  Future<void> loadBookmarks() async {
    try {
      setLoading(true);
      error = null;
      bookmarks = await _service.getBookmarks();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<bool> addBookmark({
    required String title,
    required String description,
    required String image,
    required String source,
    required String publishedAt,
    required String url,
    required String field,
  }) async {

    final success = await _service.saveBookmark(
      title: title,
      description: description,
      image: image,
      source: source,
      publishedAt: publishedAt,
      url: url,
      field: field,
    );
    if (success) {
      await loadBookmarks();
    }
    return success;
  }

  Future<bool> deleteBookmark(
    String bookmarkId,
  ) async {
    final success =
        await _service.deleteBookmark(bookmarkId);
    if (success) {
      await loadBookmarks();
    }
    return success;
  }
}