import 'package:get/get.dart';

import 'explore/explore_controller.dart';
import 'profile/profile_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ExploreController>(ExploreController());
    Get.put<ProfileController>(ProfileController());
  }
}
