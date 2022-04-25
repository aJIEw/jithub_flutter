import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/base/base_app_bar.dart';
import 'package:jithub_flutter/core/base/provider_widget.dart';
import 'package:jithub_flutter/core/extension/string.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/util/toast.dart';
import 'package:jithub_flutter/core/widget/pull_to_refresh.dart';
import 'package:jithub_flutter/data/response/user_repo.dart';
import 'package:jithub_flutter/page/home/home_page.dart';
import 'package:jithub_flutter/page/repo/repo_list_viewmodel.dart';
import 'package:jithub_flutter/provider/provider.dart';
import 'package:jithub_flutter/provider/state/user_profile.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RepoListPage extends StatefulWidget {
  const RepoListPage({Key? key}) : super(key: key);

  @override
  State<RepoListPage> createState() => _RepoListPageState();
}

class _RepoListPageState extends State<RepoListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(title: 'repo_title'.tr),
      body: ProviderWidget<RepoListViewModel>(
        viewModel: RepoListViewModel(),
        onViewModelCreated: (RepoListViewModel viewModel) async {
          initUserProfile(viewModel);

          // registerBusEvent(viewModel);
        },
        builder:
            (BuildContext context, RepoListViewModel viewModel, Widget? child) {
          return viewModel.dataList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SmartRefresher(
                  header: PullToRefreshHelper.getClassicI18nHeader(context),
                  footer: PullToRefreshHelper.getClassicI18nFooter(context),
                  enablePullUp: true,
                  controller: viewModel.refreshController,
                  onRefresh: viewModel.onRefresh,
                  onLoading: viewModel.onLoadMore,
                  child: ListView.builder(
                    itemCount: viewModel.dataList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildListItem(context, viewModel, index);
                    },
                  ),
                );
        },
      ),
    );
  }

  void initUserProfile(RepoListViewModel viewModel) {
    var userProfile = Store.value<UserProfile>(context);

    logger.d(
        '_RepoListPageState - registerBusEvent: userProfile initialized: ${userProfile.user?.name}');

    viewModel.init(param: userProfile.user?.name);
  }

  Widget _buildListItem(
      BuildContext context, RepoListViewModel viewModel, int index) {
    var cardRadius = const BorderRadius.all(Radius.circular(5.0));

    UserRepo item = viewModel.dataList[index];
    String updateTime = item.pushedAt?.getFriendlyTime() ?? '';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
      ),
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: cardRadius,
        onTap: () {
          onPressRepo(context, item);
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(fontSize: 18)),
                  if (item.description != null) ...[
                    const SizedBox(height: 8),
                    Text(item.description ?? '',
                        style: Theme.of(context).textTheme.subtitle1),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildIconText(
                          (item.stargazersCount ?? 0).toString(),
                          const Icon(Icons.star,
                              color: Colors.yellow, size: 12)),
                      const SizedBox(width: 12),
                      buildIconText(
                          (item.forksCount ?? '0').toString(),
                          SvgPicture.asset('assets/images/ic_trending_fork.svg',
                              width: 10, height: 10)),
                      if (updateTime.isNotEmpty)
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Text('Updated $updateTime'),
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),
            if (item.private ?? false)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  height: 24,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[350]!),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Text('Private',
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          ?.copyWith(color: Colors.grey[850]!)),
                ),
              )
          ],
        ),
      ),
    );
  }
}
