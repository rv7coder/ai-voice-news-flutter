import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    return await _speech.initialize();
  }

  Future<void> listen({
    required Function(String text) onResult,
    Function(String error)? onError,
  }) async {
    final available = await initialize();
    if (!available) {
      onError?.call("Speech recognition is not available.");
      return;
    }
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      localeId: "en_US",
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }
}