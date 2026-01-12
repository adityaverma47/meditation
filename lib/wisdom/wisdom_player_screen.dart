import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/wisdom_controller.dart';
import '../../navigation/bottom_nav_controller.dart';

class WisdomPlayerScreen extends GetView<WisdomController> {
  const WisdomPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.stopAudio();
        // Ensure we're on wisdom tab when going back
        try {
          final bottomNavController = Get.find<BottomNavController>();
          bottomNavController.changeTab(1);
        } catch (e) {
          // Bottom nav controller not found, continue anyway
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: SafeArea(
          child: Column(
            children: [
              // Top bar with close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        controller.stopAudio();
                        // Ensure we go back to wisdom tab in bottom nav
                        Get.back();
                      },
                    ),
                    const Text(
                      'Now Playing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Obx(() {
                  final currentItem = controller.wisdomItems.firstWhere(
                    (item) => item['title'] == controller.currentTitle.value,
                    orElse: () => controller.wisdomItems[0],
                  );
                  final color = currentItem['color'] as Color;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          
                          // Album Art / Circle
                          Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            height: MediaQuery.of(context).size.width * 0.75,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color,
                                  color.withOpacity(0.6),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                controller.currentTitle.value.isEmpty
                                    ? 'W'
                                    : controller.currentTitle.value[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Title
                          Text(
                            controller.currentTitle.value.isEmpty
                                ? 'Select a wisdom track'
                                : controller.currentTitle.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 8),
                          Text(
                            'Daily Wisdom',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Progress Bar
                          Obx(() {
                            final durSec =
                                controller.duration.value.inSeconds.toDouble();
                            final maxVal = durSec > 0 ? durSec : 1.0;

                            return Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 20,
                                    ),
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                                    thumbColor: Colors.white,
                                    overlayColor: Colors.white.withOpacity(0.1),
                                  ),
                                  child: Slider(
                                    value: controller.position.value.inSeconds
                                        .toDouble()
                                        .clamp(0.0, maxVal),
                                    max: maxVal,
                                    onChanged: (value) {
                                      controller.seekTo(
                                        Duration(seconds: value.toInt()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        controller.formatDuration(
                                          controller.position.value,
                                        ),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        controller.formatDuration(
                                          controller.duration.value,
                                        ),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),

                          const SizedBox(height: 40),

                          // Play/Pause Button
                          Obx(
                            () => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                iconSize: 80,
                                icon: Icon(
                                  controller.isPlaying.value
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: Colors.white,
                                ),
                                onPressed: controller.togglePlayPause,
                              ),
                            ),
                          ),

                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
