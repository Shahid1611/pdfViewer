import 'package:get/instance_manager.dart';

import '../home/homeController.dart';


class ControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
  }
}