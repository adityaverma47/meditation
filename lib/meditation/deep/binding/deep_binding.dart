import 'package:get/get.dart';
// Agar deep screen ke liye alag controller chahiye to yahan banao
// Warna empty bhi chalega (kyunki StatefulWidget hai)

class DeepMeditationBinding extends Bindings {
  @override
  void dependencies() {
    // Agar deep screen mein bhi GetX controller use kar rahe ho to yahan daal do
    // Abhi ke liye empty rakho kyunki StatefulWidget hai
  }
}