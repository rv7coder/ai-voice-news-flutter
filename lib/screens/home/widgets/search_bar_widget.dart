import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/speech_service.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});
  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final SpeechService speechService = SpeechService();
  bool isListening = false;

  @override
  void dispose() {
    speechService.stop();
    super.dispose();
  }

  Future<void> startVoiceSearch() async {
    if (isListening) {
      await speechService.stop();
      if (mounted) {
        setState(() {
          isListening = false;
        });
      }
      return;
    }
    setState(() {
      isListening = true;
    });
    await speechService.listen(
      onResult: (text) {
        if (!mounted) return;
        if (text.trim().isEmpty) return;
        speechService.stop();
        setState(() {
          isListening = false;
        });
        Navigator.pushNamed(
          context,
          AppRoutes.search,
          arguments: text,
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          isListening = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.search,
          );
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Search news, topics or keywords...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: startVoiceSearch,
                icon: Icon(
                  isListening
                      ? Icons.mic
                      : Icons.mic_none_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}