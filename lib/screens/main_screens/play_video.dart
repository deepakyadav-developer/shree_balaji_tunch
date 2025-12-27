import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../constant/APP_INFO.dart';

class ShortsPlayer extends StatefulWidget {
  final String? url;

  const ShortsPlayer({Key? key, this.url}) : super(key: key);

  @override
  State<ShortsPlayer> createState() => _ShortsPlayerState();
}

class _ShortsPlayerState extends State<ShortsPlayer> {
  late VideoPlayerController videoPlayerController;
  bool isPlaying = true;
  bool isInitialized = false;
  bool isBuffering = false;
  double videoProgress = 0.0;
  String position = "00:00";
  String duration = "00:00";

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url ?? ''),
    )..addListener(() {
        final bool playing = videoPlayerController.value.isPlaying;
        final bool buffering = videoPlayerController.value.isBuffering;

        if (isPlaying != playing || isBuffering != buffering) {
          setState(() {
            isPlaying = playing;
            isBuffering = buffering;
          });
        }

        // Update video progress
        if (videoPlayerController.value.isInitialized) {
          final Duration position = videoPlayerController.value.position;
          final Duration totalDuration = videoPlayerController.value.duration;

          setState(() {
            videoProgress = position.inMilliseconds /
                (totalDuration.inMilliseconds == 0
                    ? 1
                    : totalDuration.inMilliseconds);

            this.position = _formatDuration(position);
            this.duration = _formatDuration(totalDuration);
          });
        }
      });

    await videoPlayerController.initialize();

    setState(() {
      isInitialized = true;
    });

    await videoPlayerController.play();
    videoPlayerController.setVolume(1);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  void _playPause() {
    setState(() {
      if (videoPlayerController.value.isPlaying) {
        videoPlayerController.pause();
      } else {
        videoPlayerController.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: goldColor,
            ),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player
          Center(
            child: AspectRatio(
              aspectRatio: videoPlayerController.value.aspectRatio,
              child: Container(
                color: Colors.black,
                child: isInitialized
                    ? VideoPlayer(videoPlayerController)
                    : Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(goldColor),
                        ),
                      ),
              ),
            ),
          ),

          // Play/Pause on tap
          GestureDetector(
            onTap: isInitialized ? _playPause : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.transparent,
            ),
          ),

          // Controls overlay
          if (isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress bar
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        activeTrackColor: goldColor,
                        inactiveTrackColor: Colors.grey[800],
                        thumbColor: goldColor,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: videoProgress,
                        onChanged: (value) {
                          final newPosition = value *
                              videoPlayerController
                                  .value.duration.inMilliseconds;
                          videoPlayerController.seekTo(
                              Duration(milliseconds: newPosition.round()));
                        },
                      ),
                    ),

                    // Duration and controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Duration
                        Text(
                          "$position / $duration",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),

                        // Play/Pause button
                        IconButton(
                          onPressed: _playPause,
                          icon: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: bgColor.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: goldColor,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Buffering indicator
          if (isBuffering)
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(goldColor),
                  strokeWidth: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
