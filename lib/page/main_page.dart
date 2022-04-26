import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/base/base_controller.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/util/event.dart';
import 'package:jithub_flutter/core/util/toast.dart';
import 'package:jithub_flutter/data/event/bus_event.dart';
import 'package:jithub_flutter/data/response/user_feeds.dart';
import 'package:jithub_flutter/page/explore/explore_page.dart';
import 'package:jithub_flutter/page/home/home_page.dart';
import 'package:jithub_flutter/page/profile/profile_page.dart';
import 'package:jithub_flutter/page/viewmodel/main_viewmodel.dart';
import 'package:jithub_flutter/provider/provider.dart';
import 'package:provider/provider.dart';

import '/core/base/provider_widget.dart';
import '/core/util/click.dart';
import '/core/util/logger.dart';
import '/core/util/sputils.dart';
import '/provider/state/app_status.dart';
import '/provider/state/user_profile.dart';
import '/router/router.dart';
import '../core/api_service.dart';
import '../core/base/base_page.dart';

/// This page is built with [ProviderWidget], just to show you how to use it.
/// In most cases, you should use [BaseController] instead.
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with AfterLayoutMixin<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void afterFirstLayout(BuildContext context) {
    logger.d('HomePage - afterFirstLayout: ${context.size}');

    registerBusEvent();
  }

  void registerBusEvent() {
    XEvent.on(BusEvent.showLoginPage, (value) async {
      goToLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2(builder: (BuildContext context, AppStatus status,
        UserProfile userProfile, Widget? child) {
      return BasePageWrapper(
        child: WillPopScope(
            child: ProviderWidget<MainViewModel>(
                viewModel: MainViewModel(),
                onViewModelCreated: (viewModel) {
                  if (userProfile.authToken == null &&
                      SPUtils.getAuthToken().isNotEmpty) {
                    userProfile.init(SPUtils.getAuthToken(), SPUtils.getUser());
                  }
                },
                builder: (BuildContext context, MainViewModel viewModel,
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
                      onTap: (index) {
                        if (SPUtils.isLoggedIn()) {
                          status.tabIndex = index;
                        } else {
                          goToLogin();
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
        const HomePage(),
        const ExplorePage(),
        const ProfilePage(),
      ];

  void goToLogin() async {
    String? result = await XRouter.goWeb(context, ApiService.githubAuthUrl, "");
    if (result != null && result.isNotEmpty) {
      initLoginInfo(result);
    }
  }

  void initLoginInfo(String accessToken) async {
    var feeds = await requestUserFeeds();
    var userUrl = feeds?.currentUserPublicUrl;
    if (userUrl != null) {
      var name = userUrl.substring(userUrl.lastIndexOf("/") + 1);
      var info = {
        'token': accessToken,
        'name': name,
      };
      var userProfile = Store.value<UserProfile>(context);
      userProfile.initWithLoginInfo(info);

      ToastUtils.toast('login_success'.tr);

      XEvent.post(BusEvent.userLoggedIn, true);
    }
  }

  Future<UserFeeds?> requestUserFeeds() async {
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
