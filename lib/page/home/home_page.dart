import 'package:flutter/material.dart';
import 'package:jithub_flutter/core/base/provider_widget.dart';
import 'package:jithub_flutter/core/widget/pull_to_refresh.dart';
import 'package:jithub_flutter/data/response/event_timeline.dart';
import 'package:jithub_flutter/page/home/home_viewmodel.dart';
import 'package:jithub_flutter/provider/provider.dart';
import 'package:jithub_flutter/provider/state/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ProviderWidget<HomeViewModel>(
      viewModel: HomeViewModel(),
      onViewModelCreated: (HomeViewModel viewModel) async {
        var userProfile = Store.value<UserProfile>(context);

        viewModel.init(param: userProfile.user);
      },
      builder: (BuildContext context, HomeViewModel viewModel, Widget? child) =>
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
              itemCount: viewModel.dataList.length,
              itemBuilder: (context, index) => _buildItem(context, index)),
        ),
      ),
    ));
  }

  _buildItem(BuildContext context, int index) {
    EventTimeline item = context.read<HomeViewModel>().dataList[index];

    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(item.createdAt!.toString()),
    );
  }
}
