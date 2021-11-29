import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '/core/util/event.dart';
import '/core/util/toast.dart';
import '/core/base/base_controller.dart';
import 'base_app_bar.dart';
import '/core/widget/loading/loading_dialog.dart';
import '/router/router.dart';

class BasePageWrapper extends StatefulWidget {
  final Widget? child;

  const BasePageWrapper({Key? key, this.child}) : super(key: key);

  @override
  _BasePageWrapperState createState() => _BasePageWrapperState();
}

class _BasePageWrapperState extends State<BasePageWrapper> {
  @override
  void initState() {
    registerRequestEvent();

    super.initState();
  }

  void registerRequestEvent() {
    XEvent.on<String>('RequestTokenExpired', (message) {
      XRouter.push(XRouter.loginPage);
      // ToastUtils.toast('身份已过期，请重新登录！');
    });

    XEvent.on<String>('RequestErrorMessage', (message) {
      // ToastUtils.toast(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}

abstract class BaseView<T extends BaseController> extends GetView<T> {
  const BaseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      buildContent(context),
      onLoading: const BaseLoadingPage(),
      onError: (message) => BaseErrorPage(message, onReload: () {
        controller.change(null, status: RxStatus.loading());
        controller.append(() => controller.loadData);
      }),
    );
  }

  NotifierBuilder buildContent(BuildContext context);
}

class BaseLoadingPage extends StatelessWidget {
  const BaseLoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseStatusContainer(
        child: LoadingDialog(
      content: Text('message_handling'.tr,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              ?.apply(color: Colors.white)),
      backgroundColor: Colors.black38,
      loadingView: const SpinKitCircle(color: Colors.white),
    ));
  }
}

class BaseErrorPage extends StatelessWidget {
  const BaseErrorPage(this.errorMessage, {Key? key, this.onReload})
      : super(key: key);

  final errorMessage;

  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    return BaseStatusContainer(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/ic_img_error.png', width: 50, height: 50),
        const SizedBox(height: 20),
        Text('$errorMessage'),
        const SizedBox(height: 20),
        if (onReload != null)
          ElevatedButton(onPressed: onReload, child: const Text('重新加载'))
      ],
    ));
  }
}

class BaseStatusContainer extends StatelessWidget {
  const BaseStatusContainer({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const BaseAppBar(),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: kToolbarHeight * 2),
          child: child,
        ));
  }
}
