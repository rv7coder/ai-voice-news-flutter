import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/news_provider.dart';
import '../../services/speech_service.dart';
import '../home/widgets/news_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final SpeechService speechService = SpeechService();
  bool isListening = false;

  @override
  void dispose() {
    speechService.stop();
    searchController.dispose();
    super.dispose();
  }

  Future<void> performSearch() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    await context.read<NewsProvider>().searchNews(query);
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
        setState(() {
          searchController.text = text;
          searchController.selection = TextSelection.fromPosition(
            TextPosition(
              offset: searchController.text.length,
            ),
          );
        });
        if (text.trim().isNotEmpty) {
          performSearch();
        }
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
    if (mounted) {
      setState(() {
        isListening = speechService.isListening;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search News"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) {
                performSearch();
              },
              decoration: InputDecoration(
                hintText: "Search news...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          searchController.clear();
                          context.read<NewsProvider>().clearSearch();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            if (isListening) ...[
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mic,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text("Listening..."),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<NewsProvider>(
                builder: (context, provider, child) {
                  if (provider.isSearching) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (provider.searchError != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Unable to search news.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Please try another keyword.",
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: performSearch,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Try Again"),
                          ),
                        ],
                      ),
                    );
                  }
                  if (provider.searchResults.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 70,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No news found",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Try searching with another keyword.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, index) {
                      final article = provider.searchResults[index];
                      return NewsCard(
                        article: article,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}