import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareArticle({
    required String title,
    required String description,
    required String url,
  }) async {
    await Share.share(
      "$title\n\n"
      "$description\n\n"
      "Read more:\n$url",
    );
  }
}