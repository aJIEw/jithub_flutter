import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

Future? _loadingDialog;

void showLoadingDialog({bool barrierDismissible = false}) async {
  if (_loadingDialog == null) {
    _loadingDialog = Get.dialog(
        LoadingDialog(
          content: Text('message_handling'.tr,
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.black38,
          loadingView: const SpinKitCircle(color: Colors.white),
        ),
        barrierDismissible: barrierDismissible);
    await _loadingDialog;
    _loadingDialog = null;
  }
}

void dismissLoadingDialog() {
  if (_loadingDialog != null) {
    Get.back();
  }
}

/// 加载框
class LoadingDialog extends Dialog {
  // loading 动画
  final Widget? loadingView;

  // 提示内容
  final Widget content;

  // 是否显示提示文字
  final bool showContent;

  // 圆角大小
  final double radius;

  // 背景颜色
  final Color backgroundColor;

  const LoadingDialog(
      {Key? key,
      this.loadingView,
      this.content = const Text("加载中..."),
      this.showContent = true,
      this.radius = 10,
      this.backgroundColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: SizedBox(
          width: showContent ? 120 : 80,
          height: showContent ? 120 : 80,
          child: Container(
            decoration: ShapeDecoration(
              color: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(radius),
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                loadingView == null
                    ? const CircularProgressIndicator()
                    : loadingView!,
                showContent
                    ? Padding(
                        padding: const EdgeInsets.only(
                          top: 16,
                        ),
                        child: content,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
