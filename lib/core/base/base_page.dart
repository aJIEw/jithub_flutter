import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '/core/base/base_controller.dart';
import '/core/util/event.dart';
import '/core/widget/loading/loading_dialog.dart';
import '/router/router.dart';
import 'base_app_bar.dart';

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
  const BaseView({Key? key, this.hasActionBar = true}) : super(key: key);

  final bool hasActionBar;

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      buildContent(context),
      onLoading: BaseLoadingPage(hasActionBar: hasActionBar),
      onError: (message) => BaseErrorPage(message, onReload: () {
        controller.change(null, status: RxStatus.loading());
        controller.append(() => controller.loadData);
      }, hasActionBar: hasActionBar),
    );
  }

  NotifierBuilder buildContent(BuildContext context);
}

class BaseLoadingPage extends StatelessWidget {
  const BaseLoadingPage({Key? key, this.hasActionBar = true}) : super(key: key);

  final bool hasActionBar;

  @override
  Widget build(BuildContext context) {
    return BaseStatusContainer(
        actionBar: hasActionBar ? const BaseAppBar() : null,
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
  const BaseErrorPage(this.errorMessage,
      {Key? key, this.onReload, this.hasActionBar = true})
      : super(key: key);

  final errorMessage;

  final VoidCallback? onReload;

  final bool hasActionBar;

  @override
  Widget build(BuildContext context) {
    return BaseStatusContainer(
        actionBar:
            hasActionBar ? BaseAppBar(title: 'error_page_title'.tr) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/ic_img_error.png',
                width: 50, height: 50),
            if (errorMessage != null && errorMessage != '')
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text('$errorMessage'),
              ),
            const SizedBox(height: 20),
            if (onReload != null)
              ElevatedButton(onPressed: onReload, child: Text('reload_button'.tr))
          ],
        ));
  }
}

class BaseStatusContainer extends StatelessWidget {
  const BaseStatusContainer({Key? key, required this.child, this.actionBar})
      : super(key: key);

  final Widget child;

  final PreferredSizeWidget? actionBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: actionBar,
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: actionBar != null ? kToolbarHeight * 2 : 0),
          child: child,
        ));
  }
}
