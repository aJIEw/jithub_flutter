import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/base/base_app_bar.dart';
import 'package:jithub_flutter/core/base/provider_widget.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/widget/pull_to_refresh.dart';
import 'package:jithub_flutter/data/response/user_repo.dart';
import 'package:jithub_flutter/page/home/home_page.dart';
import 'package:jithub_flutter/page/repo/starred_repos_viewmodel.dart';
import 'package:jithub_flutter/provider/provider.dart';
import 'package:jithub_flutter/provider/state/user_profile.dart';
import 'package:jithub_flutter/widget/network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StarredReposPage extends StatefulWidget {
  const StarredReposPage({Key? key}) : super(key: key);

  @override
  State<StarredReposPage> createState() => _StarredReposPageState();
}

class _StarredReposPageState extends State<StarredReposPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(title: 'starred_title'.tr),
      body: ProviderWidget<StarredReposViewModel>(
        viewModel: StarredReposViewModel(),
        onViewModelCreated: (StarredReposViewModel viewModel) async {
          initUserProfile(viewModel);

          // registerBusEvent(viewModel);
        },
        builder: (BuildContext context, StarredReposViewModel viewModel,
            Widget? child) {
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

  void initUserProfile(StarredReposViewModel viewModel) {
    var userProfile = Store.value<UserProfile>(context);

    logger.d(
        '_RepoListPageState - registerBusEvent: userProfile initialized: ${userProfile.user?.name}');

    viewModel.init(param: userProfile.user?.name);
  }

  Widget _buildListItem(
      BuildContext context, StarredReposViewModel viewModel, int index) {
    var cardRadius = const BorderRadius.all(Radius.circular(5.0));

    UserRepo item = viewModel.dataList[index];

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: DefaultNetworkImage(
                    item.owner?.avatarUrl ?? "",
                    width: 36,
                    height: 36,
                  ),
                ),
                title: Text(
                    (item.owner?.login ?? '') + ' / ' + (item.name ?? ''),
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(fontSize: 18)),
              ),
              if (item.description != null) ...[
                Text(item.description ?? '',
                    style: Theme.of(context).textTheme.subtitle1),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildIconText((item.stargazersCount ?? 0).toString(),
                      const Icon(Icons.star, color: Colors.yellow, size: 12)),
                  const SizedBox(width: 12),
                  if (item.language != null)
                    buildIconText(item.language ?? '',
                        Icon(Icons.circle, color: Colors.grey[850], size: 8)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
