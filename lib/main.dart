import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meditation/meditation/deep/binding/deep_binding.dart';

import 'meditation/binding/meditation_binding.dart';
import 'meditation/deep/deep_mediation_screen.dart';
import 'meditation/meditaion_screen.dart';
import 'navigation/bottom_nav_screen.dart';
import 'navigation/binding/bottom_nav_binding.dart';
import 'wisdom/binding/wisdom_binding.dart';
import 'wisdom/wisdom_player_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meditation App',
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const BottomNavScreen(),
          binding: BottomNavBinding(),
        ),
        GetPage(
          name: '/meditation',
          page: () => const MeditaionScreen(),
          binding: MeditationBinding(),
        ),
        GetPage(
          name: '/wisdom',
          page: () => const BottomNavScreen(),
          binding: BottomNavBinding(),
        ),
        GetPage(
          name: '/deepMeditation',
          page: () => const DeepMeditationScreen(),
          binding: DeepMeditationBinding(),
        ),
        GetPage(
          name: '/wisdomPlayer',
          page: () => const WisdomPlayerScreen(),
          binding: WisdomBinding(),
          transition: Transition.downToUp,
          fullscreenDialog: true,
        ),
      ],
    );
  }
}
