import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/news_model.dart';
import '../../providers/audio_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../services/url_launcher_service.dart';
import '../../services/share_service.dart';

class NewsDetailsScreen extends StatefulWidget {
  final NewsModel article;
  const NewsDetailsScreen({super.key, required this.article});

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  bool isSaving = false;

  NewsModel get article => widget.article;

  String getTimeAgo() {
    try {
      return timeago.format(DateTime.parse(article.publishedAt));
    } catch (_) {
      return article.publishedAt;
    }
  }

  bool get isSaved {
    final provider = context.read<BookmarkProvider>();
    return provider.bookmarks.any((item) => item.url == article.url);
  }

  Future<void> toggleBookmark() async {
    if (isSaving) return;
    setState(() {
      isSaving = true;
    });
    final bookmarkProvider = context.read<BookmarkProvider>();
    final existingBookmark = bookmarkProvider.bookmarks
        .where((item) => item.url == article.url)
        .toList();
    bool success;
    if (existingBookmark.isNotEmpty) {
      success = await bookmarkProvider.deleteBookmark(
        existingBookmark.first.url,
      );
    } else {
      success = await bookmarkProvider.addBookmark(
        title: article.title,
        description: article.description,
        image: article.image,
        source: article.source,
        publishedAt: article.publishedAt,
        url: article.url,
        field: article.field,
      );
    }
    if (!mounted) return;
    setState(() {
      isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? existingBookmark.isNotEmpty
                    ? "Article removed from saved articles."
                    : "Article saved successfully."
              : "Unable to update saved article.",
        ),
      ),
    );
  }

  Future<void> listenToArticle() async {
    final audioProvider = context.read<AudioProvider>();
    if (audioProvider.isLoading) return;
    final success = await audioProvider.playArticleSummary(
      articleKey: article.url,
      title: article.title,
      description: article.description,
      field: article.field,
    );
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to generate voice summary.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            actions: [
              Consumer<BookmarkProvider>(
                builder: (context, provider, child) {
                  final saved = provider.bookmarks.any(
                    (item) => item.url == article.url,
                  );
                  return IconButton(
                    onPressed: isSaving ? null : toggleBookmark,
                    icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                  );
                },
              ),
              IconButton(
                onPressed: () async {
                  await ShareService.shareArticle(
                    title: article.title,
                    description: article.description,
                    url: article.url,
                  );
                },
                icon: const Icon(Icons.share_outlined),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: article.image.isNotEmpty
                  ? Image.network(
                      article.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.article, size: 80),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.article, size: 80),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(label: Text(article.field)),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          article.source,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getTimeAgo(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    article.description,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Consumer<AudioProvider>(
                    builder: (context, audioProvider, child) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: listenToArticle,
                              icon: audioProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      audioProvider.isPlaying &&
                                              audioProvider.isCurrentArticle(
                                                article.url,
                                              )
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                              label: Text(
                                audioProvider.isPlaying &&
                                        audioProvider.isCurrentArticle(
                                          article.url,
                                        )
                                    ? "Pause"
                                    : "Listen Summary",
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.speed),
                              const SizedBox(width: 10),
                              const Text("Playback Speed"),
                              const Spacer(),
                              DropdownButton<double>(
                                value: audioProvider.playbackSpeed,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(
                                    value: 0.75,
                                    child: Text("0.75x"),
                                  ),
                                  DropdownMenuItem(
                                    value: 1.0,
                                    child: Text("1.0x"),
                                  ),
                                  DropdownMenuItem(
                                    value: 1.25,
                                    child: Text("1.25x"),
                                  ),
                                  DropdownMenuItem(
                                    value: 1.5,
                                    child: Text("1.5x"),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    audioProvider.setPlaybackSpeed(value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final success = await UrlLauncherService.openArticle(
                          article.url,
                        );
                        if (!context.mounted) return;
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Unable to open article."),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text("Read Original Article"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ShareService.shareArticle(
                          title: article.title,
                          description: article.description,
                          url: article.url,
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text("Share Article"),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
