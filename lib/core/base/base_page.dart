import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/base/base_app_bar.dart';
import 'package:jithub_flutter/core/base/base_controller.dart';
import 'package:jithub_flutter/core/util/event.dart';
import 'package:jithub_flutter/core/widget/loading/loading_dialog.dart';
import 'package:jithub_flutter/router/router.dart';
import 'package:jithub_flutter/util/app_utils.dart';

class BasePageWrapper extends StatefulWidget {
  final Widget? child;

  const BasePageWrapper({super.key, this.child});

  @override
  State<BasePageWrapper> createState() => _BasePageWrapperState();
}

class _BasePageWrapperState extends State<BasePageWrapper> {
  @override
  void initState() {
    registerRequestEvent();

    super.initState();
  }

  void registerRequestEvent() {
    XEvent.on<String>('RequestTokenExpired', (message) {
      AppUtils.redirectToLoginSafeTab(context, clearUserProfile: true);
      XRouter.push(XRouter.loginPage);
      // ToastUtils.toast('身份已过期，请重新登录！');
    });

    XEvent.on<String>('RequestErrorMessage', (message) {
      // ToastUtils.toast(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}

abstract class BaseView<T extends BaseController> extends GetView<T> {
  const BaseView({super.key, this.hasActionBar = true});

  final bool hasActionBar;

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      buildContent(context),
      onLoading: BaseLoadingPage(hasActionBar: hasActionBar),
      onError: (message) => BaseErrorPage(
        message,
        onReload: () {
          controller.reloadData();
        },
        hasActionBar: hasActionBar,
      ),
    );
  }

  NotifierBuilder buildContent(BuildContext context);
}

class BaseLoadingPage extends StatelessWidget {
  const BaseLoadingPage({super.key, this.hasActionBar = true});

  final bool hasActionBar;

  @override
  Widget build(BuildContext context) {
    return BaseStatusContainer(
      actionBar: hasActionBar ? const BaseAppBar() : null,
      child: LoadingDialog(
        content: Text(
          'message_handling'.tr,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.apply(color: Colors.white),
        ),
        dialogBackgroundColor: Colors.black38,
        loadingView: const SpinKitCircle(color: Colors.white),
      ),
    );
  }
}

class BaseErrorPage extends StatelessWidget {
  const BaseErrorPage(
    this.errorMessage, {
    super.key,
    this.onReload,
    this.hasActionBar = true,
  });

  final String? errorMessage;

  final VoidCallback? onReload;

  final bool hasActionBar;

  @override
  Widget build(BuildContext context) {
    return BaseStatusContainer(
      actionBar: hasActionBar ? BaseAppBar(title: 'error_page_title'.tr) : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/ic_img_error.png', width: 50, height: 50),
          if (errorMessage?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text('$errorMessage'),
            ),
          const SizedBox(height: 20),
          if (onReload != null)
            ElevatedButton(
              onPressed: onReload,
              child: Text('reload_button'.tr),
            ),
        ],
      ),
    );
  }
}

class BaseStatusContainer extends StatelessWidget {
  const BaseStatusContainer({super.key, required this.child, this.actionBar});

  final Widget child;

  final PreferredSizeWidget? actionBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: actionBar,
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          bottom: actionBar != null ? kToolbarHeight * 2 : 0,
        ),
        child: child,
      ),
    );
  }
}
