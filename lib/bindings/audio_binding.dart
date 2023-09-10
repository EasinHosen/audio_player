import 'package:get/get.dart';

import '../controllers/audio_controller.dart';

class AudioBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AudioController>(AudioController(), permanent: true);
  }
}
