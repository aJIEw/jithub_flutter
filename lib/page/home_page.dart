import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/base/base_controller.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/data/response/user_feeds.dart';
import 'package:jithub_flutter/provider/provider.dart';
import 'package:jithub_flutter/util/app_utils.dart';
import 'package:provider/provider.dart';

import '../core/api_service.dart';
import '/core/base/provider_widget.dart';
import '/core/util/click.dart';
import '/core/util/logger.dart';
import '/core/util/sputils.dart';
import '/core/widget/button/round_button.dart';
import '/core/widget/common_dialogs.dart';
import '/provider/state/app_status.dart';
import '/provider/state/user_profile.dart';
import '/router/router.dart';
import '../core/base/base_page.dart';
import 'viewmodel/home_viewmodel.dart';

/// This page is built with [ProviderWidget], just to show you how to use it.
/// In most cases, you should use [BaseController] instead.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void afterFirstLayout(BuildContext context) {
    logger.d('HomePage - afterFirstLayout: ${context.size}');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2(builder: (BuildContext context, AppStatus status,
        UserProfile userProfile, Widget? child) {
      return BasePageWrapper(
        child: WillPopScope(
            child: ProviderWidget<HomeViewModel>(
                viewModel: HomeViewModel(),
                onViewModelCreated: (viewModel) {
                  if (userProfile.authToken == null &&
                      SPUtils.getAuthToken().isNotEmpty) {
                    userProfile.init(SPUtils.getAuthToken(), SPUtils.getUser());
                  }
                },
                builder: (BuildContext context, HomeViewModel viewModel,
                    Widget? child) {
                  return Scaffold(
                    key: _scaffoldKey,
                    body: IndexedStack(
                      index: status.tabIndex,
                      children: getTabWidget(context),
                    ),
                    bottomNavigationBar: BottomNavigationBar(
                      items: getTabs(),
                      currentIndex: status.tabIndex,
                      type: BottomNavigationBarType.fixed,
                      fixedColor: Theme.of(context).primaryColor,
                      selectedFontSize: 12,
                      unselectedFontSize: 12,
                      onTap: (index) async {
                        if (SPUtils.isLoggedIn()) {
                          status.tabIndex = index;
                        } else {
                          var result = await XRouter.goWeb(context, githubAuthUrl, "");
                          initLoginInfo(result);
                        }
                      },
                    ),
                  );
                }),
            onWillPop: () =>
                ClickUtils.exitBy2Click(status: _scaffoldKey.currentState)),
      );
    });
  }

  List<BottomNavigationBarItem> getTabs() => [
        _getBottomTabBarItem('home'),
        _getBottomTabBarItem('explore'),
        _getBottomTabBarItem('profile'),
      ];

  _getBottomTabBarItem(String type) {
    return BottomNavigationBarItem(
      label: 'tab_$type'.tr,
      icon: SvgPicture.asset(
        'assets/images/ic_tab_$type.svg',
        width: 20,
        height: 20,
      ),
      activeIcon: SvgPicture.asset('assets/images/ic_tab_${type}.svg',
          width: 20, height: 20, color: Theme.of(context).primaryColor),
    );
  }

  List<Widget> getTabWidget(BuildContext context) => [
        _homeTab(context),
        _exploreTab(context),
        _profileTab(context),
      ];

  _homeTab(BuildContext context) {
    var userProfile = context.read<UserProfile>();
    var loggedIn = SPUtils.isLoggedIn();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (loggedIn) Text('home_text'.trParams({'user_name': userProfile.user?.name ?? ''})),
          RoundButton(
            onPressed: () {
              if (loggedIn) {
                showAlertDialog('logout_confirm_title'.tr,
                    confirmText: 'dialog_confirm_text'.tr,
                    cancelText: 'dialog_cancel_text'.tr, onConfirm: () {
                  AppUtils.logout(context);
                });
              } else {
                XRouter.push(XRouter.loginPage);
              }
            },
            child: Text(loggedIn ? 'btn_logout'.tr : 'btn_login'.tr),
          )
        ],
      ),
    );
  }

  _exploreTab(BuildContext context) {
    return const Center(child: Text("Explore Tab"));
  }

  _profileTab(BuildContext context) {
    return Center(
        child: RoundButton(
            onPressed: () {
              XRouter.push(XRouter.settingsPage);
            },
            child: Text('btn_to_settings'.tr)));
  }

  void initLoginInfo(String accessToken) async {
    var feeds = await requestUserFeeds(accessToken);
    var userUrl = feeds?.currentUserPublicUrl;
    if (userUrl != null) {
      var name = userUrl.substring(userUrl.lastIndexOf("/") + 1);
      var info = {
        'token': accessToken,
        'name': name,
      };
      var userProfile = Store.value<UserProfile>(context);
      userProfile.initWithLoginInfo(info);
    }
  }

  Future<UserFeeds?> requestUserFeeds(String accessToken) async {
    var response = await HttpClient.get('/feeds');
    if (response.ok) {
      var feeds = UserFeeds.fromJson(response.data);
      return feeds;
    } else {
      logger.d('_CommonWebViewState - onRequestError: ${response.error}');
      return null;
    }
  }
}

const int tabIndexHome = 0;

const int tabIndexExplore = 1;

const int tabIndexProfile = 2;
