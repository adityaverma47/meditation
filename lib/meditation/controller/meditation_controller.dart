import 'dart:async';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class MeditationController extends GetxController {
  late VideoPlayerController videoCtrl;

  RxBool isVideoReady = false.obs;
  RxBool isStarted = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      videoCtrl = VideoPlayerController.asset(
        'assets/videos/meditaton.mp4',
        videoPlayerOptions:  VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await videoCtrl.initialize();
      isVideoReady.value = true;
      print('Video ready - duration: ${videoCtrl.value.duration}');
    } catch (e) {
      print('Video init error: $e');
    }
  }

  Future<void> startMeditation() async {
    if (!isVideoReady.value) {
      print('Video not ready');
      return;
    }

    print('Starting meditation...');
    isStarted.value = true;

    try {
      await videoCtrl.seekTo(Duration.zero);
      await videoCtrl.play();
      print('Video playing');

      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 10), () async {
        print('10 seconds over → stopping video & navigating');

        await videoCtrl.pause();
        await videoCtrl.seekTo(Duration.zero);

        isStarted.value = false;

        // Use toNamed instead of offNamed to keep meditation screen in stack
        Get.toNamed('/deepMeditation');
        print('Navigated to /deepMeditation');
        // Don't dispose video - keep it alive for when user comes back
      });
    } catch (e) {
      print('Start error: $e');
      isStarted.value = false;
    }
  }

  Future<void> resetMeditation() async {
    print('Resetting meditation...');
    _timer?.cancel();
    try {
      // Check if video controller is still initialized
      if (videoCtrl.value.isInitialized) {
        await videoCtrl.pause();
        await videoCtrl.seekTo(Duration.zero);
      } else {
        // Reinitialize video if it was disposed
        print('Video not initialized, reinitializing...');
        await _initVideo();
      }
    } catch (e) {
      print('Reset error: $e');
      // If video controller has issues, reinitialize
      try {
        await _initVideo();
      } catch (e2) {
        print('Reinit error: $e2');
      }
    }
    isStarted.value = false;
  }

  @override
  void onClose() {
    print('onClose → cleaning up video');
    _timer?.cancel();
    videoCtrl.pause();
    videoCtrl.dispose();
    super.onClose();
  }
}