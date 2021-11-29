import 'package:get/get.dart';

import '/core/util/logger.dart';
import 'request_error_handler.dart';

abstract class BaseController extends SuperController with RequestErrorHandler {
  dynamic arguments;

  late Map<String, String?> parameters;

  @override
  void onInit() {
    super.onInit();

    initParams();

    registerBusEvent();

    append(() => loadData);
  }

  /// 初始化页面参数
  void initParams() {
    arguments = Get.arguments;
    parameters = Get.parameters;
  }

  void registerBusEvent() {}

  Future<dynamic> loadData();

  @override
  void onResumed() {
    logger.d('${toString()} - onResumed: ');
  }

  @override
  void onPaused() {
    logger.d('${toString()} - onPaused: ');
  }

  @override
  void onInactive() {
    logger.d('${toString()} - onInactive: ');
  }

  @override
  void onDetached() {
    logger.d('${toString()} - onDetached: ');
  }

  /// Controller 被销毁时的回调，释放资源
  @override
  void onClose() {
    super.onClose();
  }
}
