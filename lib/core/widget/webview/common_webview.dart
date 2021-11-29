import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '/core/util/logger.dart';
import '../../base/base_app_bar.dart';

class CommonWebView extends StatefulWidget {
  const CommonWebView(this.url, this.title, {Key? key}) : super(key: key);

  final String url;
  final String title;

  @override
  _CommonWebViewState createState() => _CommonWebViewState();
}

class _CommonWebViewState extends State<CommonWebView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  InAppWebViewController? webViewController;
  CookieManager cookieManager = CookieManager.instance();
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldInterceptAjaxRequest: true,
        useShouldInterceptFetchRequest: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;

  double progress = 0;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.lightBlue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: BaseAppBar(title: widget.title),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
            initialOptions: options,
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              handleCallback(url);
            },
            onLoadError: (controller, url, code, message) {
              handleCallback(url);
              pullToRefreshController.endRefreshing();
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                pullToRefreshController.endRefreshing();
              }
              setState(() {
                this.progress = progress / 100;
              });
            },
            shouldInterceptAjaxRequest: (InAppWebViewController controller,
                AjaxRequest ajaxRequest) async {
              return addHeaderForAjaxRequest(ajaxRequest);
            },
            shouldInterceptFetchRequest: (InAppWebViewController controller,
                FetchRequest fetchRequest) async {
              return addHeaderForFetchRequest(fetchRequest);
            },
            shouldOverrideUrlLoading:
                (controller, shouldOverrideUrlLoadingRequest) async {
              return addHeaderForOverrideUrlLoading(
                  controller, shouldOverrideUrlLoadingRequest);
            },
            androidOnPermissionRequest: (controller, origin, resources) async {
              return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT);
            },
          ),
          progress < 1.0
              ? LinearProgressIndicator(value: progress)
              : Container(),
        ],
      ),
    );
  }

  Future<AjaxRequest> addHeaderForAjaxRequest(AjaxRequest ajaxRequest) async {
    var header = <String, dynamic>{};

    addHeader(header, ajaxRequest.url!);

    if (ajaxRequest.headers != null) {
      header.addAll(ajaxRequest.headers!.getHeaders());
    }
    ajaxRequest.headers = AjaxRequestHeaders.fromMap(header);

    return ajaxRequest;
  }

  Future<FetchRequest> addHeaderForFetchRequest(
      FetchRequest fetchRequest) async {
    var header = <String, dynamic>{};

    addHeader(header, fetchRequest.url!);

    if (fetchRequest.headers != null) {
      header.addAll(fetchRequest.headers!);
    }
    fetchRequest.headers = header;

    return fetchRequest;
  }

  Future<NavigationActionPolicy> addHeaderForOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction shouldOverrideUrlLoadingRequest) async {
    logger.d('URL: ${shouldOverrideUrlLoadingRequest.request.url}');

    if (Platform.isAndroid ||
        shouldOverrideUrlLoadingRequest.iosWKNavigationType ==
            IOSWKNavigationType.LINK_ACTIVATED) {
      var header = <String, String>{};

      addHeader(header, shouldOverrideUrlLoadingRequest.request.url!);

      if (shouldOverrideUrlLoadingRequest.request.headers != null) {
        header.addAll(shouldOverrideUrlLoadingRequest.request.headers!);
      }
      shouldOverrideUrlLoadingRequest.request.headers = header;

      controller.loadUrl(urlRequest: shouldOverrideUrlLoadingRequest.request);
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  Future addHeader(Map<String, dynamic> header, Uri url) async {
    // var csrfToken = await filterCookieName(url, 'CSRF-TOKEN');
    // header['CSRF-TOKEN'] = csrfToken;
  }

  Future<String?> filterCookieName(Uri url, String name) async {
    List<Cookie> cookies = await cookieManager.getCookies(url: url);

    return cookies.firstWhereOrNull((c) => c.name == name)?.value;
  }

  void handleCallback(Uri? url) {
    /*if (url.toString().startsWith('auth_namespace://url')) {
      var code = url?.queryParameters["code"];
      logger.d(code);
      Navigator.of(context).pop(code);
    }*/
  }
}
