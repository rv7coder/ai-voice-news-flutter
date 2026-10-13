import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/saved/saved_screen.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BookmarkProvider>().loadBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final locationParts = [
      provider.city,
      provider.state,
      provider.country,
    ].where((value) => value != null && value.trim().isNotEmpty).map((value) => value!.trim()).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 45,
            child: Icon(
              Icons.person,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              provider.userName?.trim().isNotEmpty == true
                  ? provider.userName!
                  : "Guest User",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (provider.userId != null)
            Center(
              child: Text(
                "User account",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 30),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category),
              title: const Text("Preferred Categories"),
              subtitle: Text(
                provider.selectedCategories.isEmpty
                    ? "-"
                    : provider.selectedCategories.join(", "),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Location"),
              subtitle: Text(
                locationParts.isEmpty
                    ? "Location not set"
                    : locationParts.join(", "),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text("Saved Articles"),
              subtitle: Consumer<BookmarkProvider>(
                builder: (_, bookmarkProvider, _) {
                  final count = bookmarkProvider.bookmarks.length;
                  if (count == 0) {
                    return const Text("No Saved Articles");
                  }
                  return Text("$count Articles Saved");
                },
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SavedScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // Logout will be implemented in the authentication phase.
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}