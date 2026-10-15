import 'package:flutter/material.dart';
import '../../../models/news_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../news/news_details_screen.dart';
import '../../../services/bookmark_service.dart';
import 'package:provider/provider.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/bookmark_provider.dart';

class NewsCard extends StatelessWidget {
  final NewsModel article;
  final VoidCallback? onListen;
  final bool isSavedScreen;
  const NewsCard({
    super.key,
    required this.article,
    this.onListen,
    this.isSavedScreen = false,
  });
  String getTimeAgo() {
    try {
      final date = DateTime.parse(article.publishedAt);
      return timeago.format(date);
    } catch (e) {
      return article.publishedAt;
    }
  }
  Widget _buildPlaceholder() {
    return Container(
      color: getCategoryColor().withOpacity(0.08),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              getCategoryIcon(),
              size: 70,
              color: getCategoryColor(),
            ),
            const SizedBox(height: 12),
            Text(
              "${article.field} News",
              style: TextStyle(
                color: getCategoryColor(),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  IconData getCategoryIcon() {
  switch (article.field.toLowerCase()) {
    case "technology":
      return Icons.computer;
    case "business":
      return Icons.business_center;
    case "sports":
      return Icons.sports_soccer;
    case "health":
      return Icons.health_and_safety;
    case "entertainment":
      return Icons.movie;
    case "travel":
      return Icons.flight_takeoff;
    case "culture":
      return Icons.account_balance;
    case "arts":
      return Icons.palette;
    case "earth":
      return Icons.public;
    case "live":
      return Icons.live_tv;
    default:
      return Icons.article;
  }
}
Color getCategoryColor() {
  switch (article.field.toLowerCase()) {
    case "technology":
      return Colors.blue;
    case "business":
      return Colors.green;
    case "sports":
      return Colors.orange;
    case "health":
      return Colors.red;
    case "entertainment":
      return Colors.purple;
    case "travel":
      return Colors.teal;
    case "culture":
      return Colors.brown;
    case "arts":
      return Colors.pink;
    case "earth":
      return Colors.indigo;
    case "live":
      return Colors.deepOrange;
    default:
      return Colors.grey;
  }
}

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          SizedBox(
            height: 220,
            width: double.infinity,
            child: article.image.isNotEmpty
                ? Image.network(
                    article.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _buildPlaceholder();
                    },
                  )
                : _buildPlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                /// CATEGORY + SOURCE
                Row(
                  children: [
                    Chip(
                      label: Text(article.field),
                    ),
                    const Spacer(),
                    Text(
                      article.source,
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                /// TITLE
                Text(
                  article.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                /// DESCRIPTION
                Text(
                  article.description.isEmpty
                      ? "No description available for this article."
                      : article.description,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    height: 1.5,
                    color: colors.onSurface.withValues(alpha: 0.85),
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 15),
                /// TIME
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        getTimeAgo(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                /// BUTTONS
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: [
                    Consumer<AudioProvider>(
                      builder: (context, audioProvider, child) {
                        final isCurrent = audioProvider.isCurrentArticle(
                          article.url,
                        );
                        final isBusy = audioProvider.isLoading && isCurrent;
                        return TextButton.icon(
                          onPressed: audioProvider.isLoading
                              ? null
                              : () async {
                                  if (onListen != null) {
                                    onListen!();
                                    return;
                                  }
                                  final success =
                                      await audioProvider.playArticleSummary(
                                    articleKey: article.url,
                                    title: article.title,
                                    description: article.description,
                                    field: article.field,
                                  );
                                  if (!context.mounted) return;
                                  if (!success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Unable to generate voice summary.",
                                        ),
                                      ),
                                    );
                                  }
                                },
                          icon: Icon(
                            isBusy
                                ? Icons.hourglass_top
                                : isCurrent && audioProvider.isPlaying
                                    ? Icons.pause
                                    : Icons.volume_up_outlined,
                          ),
                          label: Text(
                            isBusy
                                ? "Loading..."
                                : isCurrent && audioProvider.isPlaying
                                    ? "Pause"
                                    : "Listen...",
                          ),
                        );
                      },
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        if (isSavedScreen) {
                          if (article.bookmarkId == null) return;
                          final success =
                              await BookmarkService().deleteBookmark(
                            article.bookmarkId!,
                          );
                          if (!context.mounted) return;
                          if (success) {
                            context
                                .read<BookmarkProvider>()
                                .loadBookmarks();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Bookmark removed"),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to remove bookmark"),
                              ),
                            );
                          }
                        } else {
                          final success =
                              await BookmarkService().saveBookmark(
                            title: article.title,
                            description: article.description,
                            image: article.image,
                            source: article.source,
                            publishedAt: article.publishedAt,
                            url: article.url,
                            field: article.field,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? "Article saved successfully"
                                    : "Failed to save article",
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        isSavedScreen
                            ? Icons.delete_outline
                            : Icons.bookmark_border,
                      ),
                      label: Text(
                        isSavedScreen
                            ? "Remove"
                            : "Save",
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context, MaterialPageRoute(
                            builder: (_) => NewsDetailsScreen(article: article),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.open_in_new,
                      ),
                      label: const Text("Read"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}