import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/core/widget/clickable.dart';
import '/core/widget/divider.dart';
import '/router/router.dart';

void showAlertDialog(
  String title, {
  String? content,
  String confirmText = '确认',
  VoidCallback? onConfirm,
  String cancelText = '取消',
  VoidCallback? onCancel,
  bool useThinDivider = false,
}) {
  Get.dialog(
    SafeArea(
      child: Builder(builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 12),
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500)),
              ),
              if (content != null)
                Padding(
                  padding:
                      EdgeInsets.fromLTRB(30, 0, 30, useThinDivider ? 10 : 20),
                  child: Text(content),
                ),
              if (content == null && !useThinDivider) const SizedBox(height: 8),
              // 没有内容时，添加和底部分割线的间隔
              if (!useThinDivider)
                const DefaultDivider(1, color: Color(0xCCE6E6E6)),
              OptionButtonGroup(
                confirmText: confirmText,
                onConfirm: onConfirm,
                cancelText: cancelText,
                onCancel: onCancel,
                height: useThinDivider ? 60 : 50,
                dividerHeight: useThinDivider ? 20 : 50,
              ),
            ],
          ),
        );
      }),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 150),
    transitionCurve: Curves.easeOut,
  );
}

void showInputDialog(String title,
    {String hintText = '请输入',
    String defaultText = '',
    String confirmText = '确认',
    Function? onConfirm,
    String cancelText = '取消',
    VoidCallback? onCancel}) {
  var controller = TextEditingController();
  if (defaultText.isNotEmpty) {
    controller.text = defaultText;
  }

  Get.dialog(
    SafeArea(
      child: Builder(
        builder: (context) => Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                child: TextFormField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.black87,
                  cursorWidth: 0.8,
                  decoration: InputDecoration(
                      counterText: "",
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[350]!),
                      ),
                      hintStyle: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w300),
                      hintText: hintText),
                  onChanged: (text) {},
                ),
              ),
              const DefaultDivider(1, color: Color(0xCCE6E6E6)),
              OptionButtonGroup(
                  confirmText: confirmText,
                  onConfirm: () {
                    if (onConfirm != null) {
                      onConfirm(controller.text);
                    }
                  },
                  cancelText: cancelText,
                  onCancel: onCancel),
            ],
          ),
        ),
      ),
    ),
  );
}

typedef OnSelectedCallBack = void Function(int index, String value);

void showBottomSheetListDialog(
    List<String> choices, OnSelectedCallBack onSelected,
    {String? title, String cancelText = '取消'}) {
  Get.bottomSheet(
    IntrinsicHeight(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            if (title != null)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  )),
            ...choices
                .mapIndexed((index, choice) => Clickable(
                      onPressed: () {
                        XRouter.pop();
                        onSelected(index, choice);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(choice,
                                style: TextStyle(
                                    color: Colors.grey[850], fontSize: 16)),
                          ),
                          const DefaultDivider(0.3),
                        ],
                      ),
                    ))
                .toList(),
            Container(
              height: 10,
              color: Colors.grey[200],
            ),
            Padding(
              padding:
                  EdgeInsets.fromLTRB(0, 20, 0, Platform.isAndroid ? 20 : 40),
              child: Clickable(
                  onPressed: () {
                    XRouter.pop();
                  },
                  child: Text(
                    cancelText,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  )),
            ),
          ],
        ),
      ),
    ),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    )),
    clipBehavior: Clip.hardEdge,
  );
}

class OptionButtonGroup extends StatelessWidget {
  final String confirmText;
  final VoidCallback? onConfirm;
  final String cancelText;
  final VoidCallback? onCancel;

  final double height;
  final double dividerHeight;

  const OptionButtonGroup({
    Key? key,
    this.confirmText = '确认',
    this.onConfirm,
    this.cancelText = '取消',
    this.onCancel,
    this.height = 50,
    this.dividerHeight = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Clickable(
                onPressed: () {
                  onCancel?.call();
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: height,
                  alignment: Alignment.center,
                  child: Text(cancelText,
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w400)),
                )),
          ),
          SizedBox(
              height: dividerHeight,
              child: const DefaultVerticalDivider(1, color: Color(0xCCE6E6E6))),
          Expanded(
            child: Clickable(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
                child: Container(
                    height: height,
                    alignment: Alignment.center,
                    child: Text(confirmText,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold)))),
          ),
        ],
      ),
    );
  }
}
