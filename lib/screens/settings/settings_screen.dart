import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/audio_provider.dart';
import '../../core/constants/categories.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Set<String> selectedCategories = {};
  bool savingCategories = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    selectedCategories = settings.preferredCategories.toSet();
  }

  Future<void> saveCategories(SettingsProvider settings) async {
    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one category."),
        ),
      );
      return;
    }
    setState(() {
      savingCategories = true;
    });
    final success = await settings.setPreferredCategories(
      selectedCategories.toList(),
    );
    if (!mounted) return;
    setState(() {
      savingCategories = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Preferred categories updated successfully."
              : "Unable to update preferred categories.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          const ListTile(
            title: Text(
              "Preferred Categories",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Select the categories you want to see in your news feed.",
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: newsCategories.map((category) {
                final isSelected =
                    selectedCategories.contains(category.name);
                return FilterChip(
                  selected: isSelected,
                  avatar: Text(category.icon),
                  label: Text(category.name),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedCategories.add(category.name);
                      } else {
                        selectedCategories.remove(category.name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: savingCategories
                    ? null
                    : () => saveCategories(settings),
                icon: savingCategories
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  savingCategories
                      ? "Saving..."
                      : "Save Categories",
                ),
              ),
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text(
              "Appearance",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            value: settings.darkMode,
            title: const Text("Dark Mode"),
            secondary: const Icon(
              Icons.dark_mode,
            ),
            onChanged: (value) {
              settings.setDarkMode(value);
            },
          ),
          const Divider(),
          const ListTile(
            title: Text(
              "Voice Playback",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.speed),
              title: const Text("Playback Speed"),
              trailing: DropdownButton<double>(
                value: settings.playbackSpeed,
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
                onChanged: (value) async {
                  if (value != null) {
                    await settings.setPlaybackSpeed(value);
                    if (!context.mounted) return;
                    await context
                        .read<AudioProvider>()
                        .setPlaybackSpeed(value);
                  }
                },
              ),
            ),
          ),
          SwitchListTile(
            value: settings.autoPlay,
            title: const Text(
              "Auto Play Voice Summary",
            ),
            secondary: const Icon(
              Icons.play_circle_fill,
            ),
            onChanged: (value) {
              settings.setAutoPlay(value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.delete_outline,
            ),
            title: const Text(
              "Clear Audio Cache",
            ),
            onTap: () {},
          ),
          const Divider(),
          const AboutListTile(
            applicationName: "AI Voice News",
            applicationVersion: "1.0.0",
            applicationLegalese:
                "© 2026 AI Voice News",
          ),
        ],
      ),
    );
  }
}