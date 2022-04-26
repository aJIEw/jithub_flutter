import 'package:flutter/material.dart';
import 'package:jithub_flutter/core/base/provider_widget.dart';
import 'package:jithub_flutter/core/extension/string.dart';
import 'package:jithub_flutter/core/util/event.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/widget/pull_to_refresh.dart';
import 'package:jithub_flutter/data/event/bus_event.dart';
import 'package:jithub_flutter/data/model/github_event.dart';
import 'package:jithub_flutter/data/response/event_timeline.dart';
import 'package:jithub_flutter/data/response/user_repo.dart';
import 'package:jithub_flutter/page/home/home_repo_item.dart';
import 'package:jithub_flutter/page/home/home_viewmodel.dart';
import 'package:jithub_flutter/provider/provider.dart';
import 'package:jithub_flutter/provider/state/user_profile.dart';
import 'package:jithub_flutter/router/router.dart';
import 'package:jithub_flutter/widget/network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController scrollController = ScrollController();

  void registerBusEvent(HomeViewModel viewModel) {
    XEvent.on(BusEvent.userLoggedIn, (value) async {
      initUserProfile(viewModel);
    });
  }

  void initUserProfile(HomeViewModel viewModel) {
    var userProfile = Store.value<UserProfile>(context);

    logger.d(
        '_HomePageState - registerBusEvent: userProfile initialized: ${userProfile.user?.name}');

    viewModel.init(param: userProfile.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: ProviderWidget<HomeViewModel>(
        viewModel: HomeViewModel(),
        onViewModelCreated: (HomeViewModel viewModel) async {
          initUserProfile(viewModel);

          registerBusEvent(viewModel);
        },
        builder:
            (BuildContext context, HomeViewModel viewModel, Widget? child) =>
                RefreshConfiguration(
          enableLoadingWhenNoData: false,
          child: SmartRefresher(
            header: PullToRefreshHelper.getClassicI18nHeader(context),
            footer: PullToRefreshHelper.getClassicI18nFooter(context),
            enablePullUp: true,
            controller: viewModel.refreshController,
            onRefresh: viewModel.onRefresh,
            onLoading: viewModel.onLoadMore,
            child: ListView.builder(
                physics: const RangeMaintainingScrollPhysics(),
                controller: scrollController,
                cacheExtent: 9999,
                itemCount: viewModel.dataList.length,
                itemBuilder: (context, index) {
                  EventTimeline item = viewModel.dataList[index];

                  return _buildItem(item, item.repo?.url);
                }),
          ),
        ),
      ),
    ));
  }

  Widget _buildItem(EventTimeline item, String? repoName) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: DefaultNetworkImage(
                item.actor?.avatarUrl ?? "",
                width: 40,
                height: 40,
              ),
            ),
            title: _buildEventTitle(item),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                item.createdAt?.getFriendlyTime() ?? '',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          HomeRepoItem(repoName ?? ''),
        ],
      ),
    );
  }

  Widget _buildEventTitle(EventTimeline item) {
    TextSpan? actionText;

    var normalStyle = TextStyle(
      color: Colors.grey[850],
      fontSize: 14,
    );

    var boldStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey[850],
      fontSize: 14,
    );

    var repo = TextSpan(
      text: item.repo?.name ?? '',
      style: boldStyle,
    );

    var type = item.type;
    if (type == GithubEvent.WatchEvent.name) {
      actionText = TextSpan(
        children: [
          const TextSpan(text: ' starred '),
          repo,
        ],
      );
    } else if (type == GithubEvent.ForkEvent.name) {
      actionText = TextSpan(
        children: [
          const TextSpan(text: ' forked '),
          repo,
        ],
      );
    } else if (type == GithubEvent.ReleaseEvent.name) {
      if (item.payload?.action == 'published' &&
          item.payload?.release != null) {
        actionText = TextSpan(
          children: [
            const TextSpan(text: ' released '),
            TextSpan(
              text: item.payload?.release?.tagName ?? '',
              style: boldStyle,
            ),
            const TextSpan(text: ' of '),
            repo,
          ],
        );
      }
    } else if (type == GithubEvent.CreateEvent.name) {
      if (item.payload?.ref_type == 'repository') {
        actionText = TextSpan(
          children: [
            const TextSpan(text: '  created a repository '),
            repo,
          ],
        );
      }
    } else if (type == GithubEvent.PublicEvent.name) {
      actionText = TextSpan(
        children: [
          const TextSpan(text: ' made '),
          repo,
          const TextSpan(text: ' public'),
        ],
      );
    }

    return RichText(
        text: TextSpan(style: normalStyle, children: [
      TextSpan(text: item.actor?.login ?? '', style: boldStyle),
      actionText ?? const TextSpan(text: ''),
    ]));
  }
}

void onPressRepo(BuildContext context, UserRepo repo) {
  var name = (repo.owner?.login ?? "") + " / " + (repo.name ?? "");
  var url = repo.htmlUrl;
  if (url != null) {
    XRouter.goWeb(context, url, name);
  }
}

Widget buildIconText(String text, Widget icon) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      icon,
      const SizedBox(width: 4),
      Text(text),
    ],
  );
}
