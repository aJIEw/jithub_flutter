import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/base/base_page.dart';
import 'package:jithub_flutter/core/extension/string.dart';
import 'package:jithub_flutter/core/util/event.dart';
import 'package:jithub_flutter/core/util/toast.dart';
import 'package:jithub_flutter/core/widget/clickable.dart';
import 'package:jithub_flutter/core/widget/container/shadow_container.dart';
import 'package:jithub_flutter/data/event/bus_event.dart';
import 'package:jithub_flutter/data/response/github_repo.dart';
import 'package:jithub_flutter/page/home/home_page.dart';
import 'package:jithub_flutter/page/profile/contribution_graph_view.dart';
import 'package:jithub_flutter/page/profile/profile_controller.dart';
import 'package:jithub_flutter/router/router.dart';
import 'package:jithub_flutter/widget/network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ProfilePage extends BaseView<ProfileController> {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  bool get hasActionBar => false;

  @override
  NotifierBuilder buildContent(BuildContext context) {
    return (state) {
      GithubUser user = state;
      return VisibilityDetector(
        key: const Key('tab_eco'),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction > 0) {
            if (!controller.popupShown &&
                controller.canShowPopup &&
                controller.contributionList.isNotEmpty) {
              // 显示今日贡献弹窗
              var event = controller
                  .contributionList[6 - controller.contributionPlaceholderDays];
              XEvent.post(BusEvent.showInitPopup, event);
            }
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ShadowContainer(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: DefaultNetworkImage(
                                  user.avatarUrl ?? '',
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  user.login ?? '',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[850]),
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                // color: Colors.cyan[100],
                                alignment: Alignment.centerRight,
                                child: Clickable(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(Icons.settings,
                                        color: Colors.grey[850], size: 22),
                                  ),
                                  onPressed: () {
                                    XRouter.push(XRouter.settingsPage);
                                  },
                                ),
                              )),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (user.bio?.isNotEmpty ?? false)
                            Text(
                              user.bio ?? "",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[850]),
                            ),
                          ..._getNonNullPropertyWidget(
                              user.location,
                              const Icon(
                                Icons.pin_drop_outlined,
                                size: 14,
                              )),
                          ..._getNonNullPropertyWidget(
                              user.company,
                              const Icon(
                                Icons.apartment_sharp,
                                size: 14,
                              )),
                          ..._getNonNullPropertyWidget(
                              user.blog,
                              const Icon(
                                Icons.language,
                                size: 14,
                              )),
                          ..._getNonNullPropertyWidget(
                              user.twitterUsername,
                              const Icon(
                                Icons.email,
                                size: 14,
                              )),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.people_alt_outlined,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (user.followers ?? '0').toString(),
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'followers',
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.circle,
                                size: 5,
                                color: Colors.grey[850],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (user.following ?? '0').toString(),
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'following',
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ShadowContainer(
                      child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.book,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Contribution",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[850],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Obx(
                              () => Text.rich(TextSpan(
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[850]),
                                  children: [
                                    TextSpan(
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                          text: controller
                                              .totalContribution.value
                                              .toString(),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const TextSpan(text: ' contributions')
                                      ],
                                    ),
                                    const TextSpan(
                                        text: ' in the last 90 days'),
                                  ])),
                            ),
                            Icon(
                              Icons.question_mark,
                              size: 14,
                              color: Colors.grey[700],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // graph
                        ContributionGraphView(),
                      ],
                    ),
                  )),
                  const SizedBox(height: 20),
                  ShadowContainer(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildListItem(
                              'assets/images/ic_option_repo.png',
                              Color('0xFF3E444D'.toHexValue()),
                              'Repositories', () {
                            XRouter.push(XRouter.repoListPage);
                          }),
                          _buildListItem('assets/images/ic_option_starred.png',
                              Color('0xFFFFC600'.toHexValue()), 'Starred', () {
                            XRouter.push(XRouter.starredReposPage);
                          }),
                          /*_buildListItem('assets/images/ic_option_settings.png',
                              Color('0xFF707070'.toHexValue()), 'Settings', () {
                            ToastUtils.toast('Clicked Settings');
                          }),*/
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };
  }

  List<Widget> _getNonNullPropertyWidget(String? property, Widget icon,
      {double marginTop = 8}) {
    if (property?.isNotEmpty ?? false) {
      return [
        SizedBox(height: marginTop),
        buildIconText('@' + (property ?? ''), icon),
      ];
    }

    return [];
  }

  Widget _buildListItem(
      String iconPath, Color iconBg, String title, VoidCallback onTab) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTab,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 12, 15, 12),
          child: Row(
            children: [
              Container(
                  width: 35,
                  height: 35,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: iconBg,
                  ),
                  child: Image.asset(iconPath, width: 20, height: 20)),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(title, style: const TextStyle(fontSize: 16)),
              ),
              Expanded(
                  child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(Icons.arrow_forward_ios,
                          size: 20, color: Colors.grey[400]))),
            ],
          ),
        ),
      ),
    );
  }
}
