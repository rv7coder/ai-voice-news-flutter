import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/news_provider.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/category_list.dart';
import 'widgets/news_card.dart';
import 'widgets/bottom_navbar.dart';
import '../audio/mini_audio_player.dart';
import '../profile/profile_screen.dart';
import '../saved/saved_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  int newsTypeIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NewsProvider>().loadBothNews();
    });
  }

  void onNavigationTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SearchScreen(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SavedScreen(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );
        break;
    }
  }

  Future<void> _refreshNews() async {
    final provider = context.read<NewsProvider>();
    await provider.loadBothNews();
    if (!mounted) return;
    if (newsTypeIndex == 0) {
      provider.showGlobalNews();
    } else {
      provider.showLocationNews();
    }
  }

  Future<void> _changeCategory(String category) async {
    if (category == "⭐ Recommended") {
      await context.read<NewsProvider>().loadBothNews();
      if (!mounted) return;
      if (newsTypeIndex == 0) {
        context.read<NewsProvider>().showGlobalNews();
      } else {
        context.read<NewsProvider>().showLocationNews();
      }
      return;
    }
    await context.read<NewsProvider>().changeCategory(category);
    if (!mounted) return;
    if (newsTypeIndex == 1) {
      await context.read<NewsProvider>().loadLocationNews();
    }
  }

  Future<void> _changeNewsType(int index) async {
    setState(() {
      newsTypeIndex = index;
    });
    final provider = context.read<NewsProvider>();
    if (index == 0) {
      if (provider.globalNews.isEmpty) {
        await provider.loadNews();
      } else {
        provider.showGlobalNews();
      }
    } else {
      if (provider.locationNews.isEmpty) {
        await provider.loadLocationNews();
      } else {
        provider.showLocationNews();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<NewsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (provider.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Unable to load news",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _refreshNews,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Try Again"),
                      ),
                    ],
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _refreshNews,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: HomeAppBar(
                      userName: "Rudra",
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  const SliverToBoxAdapter(
                    child: SearchBarWidget(),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  SliverToBoxAdapter(
                    child: CategoryList(
                      onCategorySelected: _changeCategory,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment<int>(
                            value: 0,
                            icon: Icon(Icons.public),
                            label: Text("Global"),
                          ),
                          ButtonSegment<int>(
                            value: 1,
                            icon: Icon(Icons.location_on),
                            label: Text("Location"),
                          ),
                        ],
                        selected: {newsTypeIndex},
                        onSelectionChanged: (selection) {
                          _changeNewsType(selection.first);
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Text(
                        newsTypeIndex == 0
                            ? "Global News"
                            : "News Near You",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 15),
                  ),
                  if (provider.news.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            "No News Available",
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final article = provider.news[index];
                          return NewsCard(
                            article: article,
                            onListen: () {},
                          );
                        },
                        childCount: provider.news.length,
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 30),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniAudioPlayer(),
          BottomNavBar(
            currentIndex: currentIndex,
            onTap: onNavigationTapped,
          ),
        ],
      ),
    );
  }
}