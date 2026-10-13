import '../models/news_model.dart';
import '../services/news_service.dart';
import 'base_provider.dart';

class NewsProvider extends BaseProvider {
  final NewsService _service = NewsService();
  List<NewsModel> news = [];
  List<NewsModel> globalNews = [];
  List<NewsModel> locationNews = [];
  List<NewsModel> searchResults = [];
  bool isSearching = false;
  String? searchError;

  Future<void> loadNews() async {
    setLoading(true);
    setError(null);
    try {
      globalNews = await _service.getRecommendedNews();
      news = globalNews;
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadLocationNews() async {
    setLoading(true);
    setError(null);
    try {
      locationNews = await _service.getLocationNews();
      news = locationNews;
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadBothNews() async {
    setLoading(true);
    setError(null);
    try {
      final results = await Future.wait([
        _service.getRecommendedNews(),
        _service.getLocationNews(),
      ]);
      globalNews = results[0];
      locationNews = results[1];
      news = globalNews;
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> searchNews(String query) async {
    isSearching = true;
    searchError = null;
    searchResults = [];
    notifyListeners();
    try {
      searchResults = await _service.searchNews(query);
    } catch (e) {
      searchError = e.toString();
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    searchResults = [];
    searchError = null;
    notifyListeners();
  }

  Future<void> changeCategory(String field) async {
    setLoading(true);
    setError(null);
    try {
      final results = await _service.changeCategory(field);
      globalNews = results;
      news = results;
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  void showGlobalNews() {
    news = globalNews;
    notifyListeners();
  }

  void showLocationNews() {
    news = locationNews;
    notifyListeners();
  }
}