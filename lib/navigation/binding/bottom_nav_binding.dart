import 'package:get/get.dart';
import '../bottom_nav_controller.dart';
import '../../meditation/binding/meditation_binding.dart';
import '../../wisdom/binding/wisdom_binding.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavController>(() => BottomNavController());
    // Initialize both meditation and wisdom controllers
    MeditationBinding().dependencies();
    WisdomBinding().dependencies();
  }
}
