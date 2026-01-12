// wisdom_controller.dart
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import '../../navigation/bottom_nav_controller.dart';

class WisdomController extends GetxController {
  final List<Map<String, dynamic>> wisdomItems = [
    {
      'title': 'Inner Peace',
      'color': Colors.blue[700],
      'audioPath': 'assets/audios/meditation.mp3',
    },
    {
      'title': 'Gratitude',
      'color': Colors.green[700],
      'audioPath': 'assets/audios/meditation.mp3',
    },
    {
      'title': 'Mindfulness',
      'color': Colors.purple[700],
      'audioPath': 'assets/audios/meditation.mp3',
    },
    {
      'title': 'Positive Energy',
      'color': Colors.orange[700],
      'audioPath': 'assets/audios/meditation.mp3',
    },
  ];

  RxBool isPlaying = false.obs;
  Rx<Duration> position = Duration.zero.obs;
  Rx<Duration> duration = Duration.zero.obs;
  RxString currentTitle = ''.obs;

  AudioPlayer? _audioPlayer;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();
  }

  Future<void> playWisdom(int index) async {
    final item = wisdomItems[index];
    currentTitle.value = item['title'];

    try {
      // Stop any previous playback
      await _audioPlayer?.stop();
      isPlaying.value = false;

      // Load new audio
      await _audioPlayer!.setAsset(item['audioPath']);
      duration.value = _audioPlayer!.duration ?? Duration.zero;

      // Start playing
      await _audioPlayer!.play();
      isPlaying.value = true;

      // Listen to position changes
      _audioPlayer!.positionStream.listen((pos) {
        position.value = pos;
      });

      // Listen to completion
      _audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          isPlaying.value = false;
          position.value = Duration.zero;
        }
      });
    } catch (e) {
      print('Audio error: $e');
      Get.snackbar('Error', 'Failed to play audio');
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await _audioPlayer?.pause();
      isPlaying.value = false;
    } else {
      await _audioPlayer?.play();
      isPlaying.value = true;
    }
  }

  Future<void> seekTo(Duration newPosition) async {
    await _audioPlayer?.seek(newPosition);
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer?.stop();
      isPlaying.value = false;
      position.value = Duration.zero;
      currentTitle.value = '';
    } catch (e) {
      print('Stop audio error: $e');
    }
  }

  Future<void> openWisdom(int index) async {
    // Ensure bottom nav is on wisdom tab (index 1)
    try {
      final bottomNavController = Get.find<BottomNavController>();
      bottomNavController.changeTab(1);
    } catch (e) {
      // Bottom nav controller not found, continue anyway
    }
    
    await playWisdom(index);
    Get.toNamed('/wisdomPlayer');
  }

  @override
  void onClose() {
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    super.onClose();
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}