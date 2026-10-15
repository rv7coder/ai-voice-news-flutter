import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/voice_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  String? _currentAudioUrl;
  String? _currentArticleKey;
  String? currentTitle;
  double playbackSpeed = 1.0;

  AudioProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    playbackSpeed = prefs.getDouble("playbackSpeed") ?? 1.0;
    await _player.setSpeed(playbackSpeed);
    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        isPlaying = false;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  bool get hasAudioLoaded {
    return _currentAudioUrl != null;
  }

  bool isCurrentArticle(String articleKey) {
    return _currentArticleKey == articleKey;
  }

  Future<bool> playArticleSummary({
    required String articleKey,
    required String title,
    required String description,
    required String field,
  }) async {
    if (isPlaying && isCurrentArticle(articleKey)) {
      await pauseAudio();
      return true;
    }
    if (!isPlaying && hasAudioLoaded && isCurrentArticle(articleKey)) {
      await resumeAudio();
      return true;
    }
    try {
      isLoading = true;
      currentTitle = title;
      notifyListeners();
      final audioUrl = await VoiceService().getVoiceSummary(
        title: title,
        description: description,
        field: field,
      );
      if (audioUrl == null || audioUrl.isEmpty) {
        currentTitle = null;
        isLoading = false;
        notifyListeners();
        return false;
      }
      await playAudio(articleKey: articleKey, audioUrl: audioUrl, title: title);
      return true;
    } catch (e) {
      debugPrint("Voice summary error: $e");
      isPlaying = false;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> playAudio({
    required String articleKey,
    required String audioUrl,
    required String title,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      playbackSpeed = prefs.getDouble("playbackSpeed") ?? 1.0;
      if (_currentArticleKey != articleKey || _currentAudioUrl != audioUrl) {
        await _player.setUrl(audioUrl);
        _currentArticleKey = articleKey;
        _currentAudioUrl = audioUrl;
      }
      await _player.setSpeed(playbackSpeed);
      currentTitle = title;
      await _player.play();
    } catch (e) {
      debugPrint("Audio playback error: $e");
      isPlaying = false;
      _currentAudioUrl = null;
      _currentArticleKey = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pauseAudio() async {
    await _player.pause();
    isPlaying = false;
    notifyListeners();
  }

  Future<void> resumeAudio() async {
    if (_currentAudioUrl == null) return;
    await _player.play();
    isPlaying = true;
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    playbackSpeed = speed;
    await _player.setSpeed(speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("playbackSpeed", speed);
    notifyListeners();
  }

  Future<void> closeAudio() async {
    await _player.stop();
    _currentAudioUrl = null;
    _currentArticleKey = null;
    currentTitle = null;
    isPlaying = false;
    isLoading = false;
    notifyListeners();
  }

  Future<void> stopAudio() async {
    await closeAudio();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
