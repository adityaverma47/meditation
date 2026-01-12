import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controller/meditation_controller.dart';

class DeepMeditationScreen extends StatefulWidget {
  const DeepMeditationScreen({super.key});

  @override
  State<DeepMeditationScreen> createState() => _DeepMeditationScreenState();
}

class _DeepMeditationScreenState extends State<DeepMeditationScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.asset(
      'assets/videos/meditaton.mp4',
      videoPlayerOptions:  VideoPlayerOptions(mixWithOthers: true),
    );

    try {
      await _controller.initialize();
      await _controller.setLooping(false);
      await _controller.play();
      setState(() {
        _isInitialized = true;
        _isPlaying = true;
      });
      _controller.addListener(_onVideoTick);
    } catch (e) {
      print('Deep video init error: $e');
    }
  }

  void _onVideoTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoTick);
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _handleExit() async {
    final bool? shouldExit = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Exit Meditation?"),
        content: const Text("Are you sure you want to stop and go back?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("No", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    if (shouldExit == true) {
      print('User confirmed exit');

      // Pause video
      await _controller.pause();

      // Reset shared controller if it exists
      try {
        final ctrl = Get.find<MeditationController>();
        await ctrl.resetMeditation();
        print('Controller reset done');
      } catch (_) {
        print('No shared controller found - skipping reset');
      }

      // Use Get.back() to go back to meditation screen
      // This will work because we used Get.toNamed() instead of Get.offNamed()
      if (mounted) {
        Get.back();
        print('Deep screen popped → back to meditation screen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = _controller.value.position;
    final duration = _controller.value.duration;
    final maxMs = duration.inMilliseconds == 0 ? 1 : duration.inMilliseconds;
    final sliderValue = position.inMilliseconds.clamp(0, maxMs).toDouble();
    final remaining = duration - position;
    final remainingSafe = remaining.isNegative ? Duration.zero : remaining;

    return WillPopScope(
      onWillPop: () async {
        await _handleExit();
        return false; // Prevent direct pop - force confirmation
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_isInitialized && _controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: Colors.white)),

            Container(color: Colors.black45),

            SafeArea(
              child: Column(
                children: [
                  // Close (X) button
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 32),
                        onPressed: _handleExit,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Progress bar + timer
                  if (_isInitialized) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white30,
                              thumbColor: Colors.white,
                              overlayColor: Colors.white.withOpacity(0.2),
                            ),
                            child: Slider(
                              value: sliderValue,
                              min: 0,
                              max: maxMs.toDouble(),
                              onChanged: (value) {
                                final newPos = Duration(milliseconds: value.toInt());
                                _controller.seekTo(newPos);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                Text(
                                  '-${_formatDuration(remainingSafe)}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Play/Pause button
                  IconButton(
                    iconSize: 70,
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPlaying = !_isPlaying;
                        if (_isPlaying) {
                          _controller.play();
                        } else {
                          _controller.pause();
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}