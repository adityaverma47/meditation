import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'controller/meditation_controller.dart';

class MeditaionScreen extends GetView<MeditationController> {
  const MeditaionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final isReady = controller.isVideoReady.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Video background
            if (isReady && controller.videoCtrl.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.videoCtrl.value.size.width,
                  height: controller.videoCtrl.value.size.height,
                  child: VideoPlayer(controller.videoCtrl),
                ),
              )
            else
              Container(color: Colors.black),

            // Dark overlay
            Container(color: Colors.black54),

            // Start screen (only before play)
            if (!controller.isStarted.value)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Relax your mind and body\nFocus on the moment",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: controller.startMeditation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 50,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Text(
                            "Let's Boom",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            // No pause/play button after start - video auto 10 sec baad stop + navigate
          ],
        );
      }),
    );
  }
}