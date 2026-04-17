import 'package:get/get.dart';

import 'package:jithub_flutter/page/explore/explore_controller.dart';
import 'package:jithub_flutter/page/profile/profile_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExploreController>(() => ExploreController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
