import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/audio_provider.dart';

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        if (!provider.hasAudioLoaded) {
          return const SizedBox.shrink();
        }
        return Material(
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: provider.isPlaying
                      ? "Pause"
                      : "Play",
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (provider.isPlaying) {
                            await provider.pauseAudio();
                          } else {
                            await provider.resumeAudio();
                          }
                        },
                  icon: Icon(
                    provider.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.currentTitle ?? "AI Voice Summary",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DropdownButton<double>(
                  value: provider.playbackSpeed,
                  underline: const SizedBox.shrink(),
                  isDense: true,
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
                      provider.setPlaybackSpeed(value);
                    }
                  },
                ),
                IconButton(
                  tooltip: "Close",
                  onPressed: provider.closeAudio,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}