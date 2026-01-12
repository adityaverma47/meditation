import 'package:get/get.dart';

import '../controller/wisdom_controller.dart';

class WisdomBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<WisdomController>(() => WisdomController());
  }
}