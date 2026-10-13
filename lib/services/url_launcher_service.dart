import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  static Future<bool> openArticle(String url) async {
    final cleanedUrl = url.trim();
    if (cleanedUrl.isEmpty) {
      return false;
    }

    Uri? uri;

    try {
      uri = Uri.parse(cleanedUrl);
    } catch (_) {
      return false;
    }

    if (!uri.hasScheme) {
      uri = Uri.parse("https://$cleanedUrl");
    }

    if (uri.scheme != "http" && uri.scheme != "https") {
      return false;
    }

    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}