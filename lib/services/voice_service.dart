import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    final summaryText = description.trim().isEmpty ? title : description;
    final response = await ApiService.post("/voice-summary", {
      "user_id": userId,
      "title": title,
      "description": summaryText,
      "field": field,
    });
    if (response.statusCode != 200) {
      debugPrint("Voice summary error: ${response.statusCode}");
      debugPrint(response.body);
      return null;
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final audioUrl = data["audio_url"];
    if (audioUrl == null || audioUrl.toString().isEmpty) {
      return null;
    }
    return ApiService.getMediaUrl(audioUrl.toString());
  }
}
