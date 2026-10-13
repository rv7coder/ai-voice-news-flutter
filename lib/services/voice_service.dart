import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class VoiceService {
  Future<String?> getVoiceSummary({
    required String title,
    required String description,
    required String field,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null || userId.isEmpty) {
      return null;
    }
    final response = await ApiService.post(
      "/voice-summary",
      {
        "user_id": userId,
        "title": title,
        "description": description,
        "field": field,
      },
    );
    if (response.statusCode != 200) {
      print("Voice summary error: ${response.statusCode}");
      print(response.body);
      return null;
    }
    final data = jsonDecode(response.body);
    final audioUrl = data["audio_url"];
    if (audioUrl == null || audioUrl.toString().isEmpty) {
      return null;
    }
    return ApiService.getMediaUrl(
      audioUrl.toString(),
    );
  }
}