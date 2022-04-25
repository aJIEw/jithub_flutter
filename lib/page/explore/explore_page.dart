import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/base/base_page.dart';
import 'package:jithub_flutter/core/extension/string.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/util/toast.dart';
import 'package:jithub_flutter/core/widget/container/shadow_container.dart';
import 'package:jithub_flutter/data/response/trending_repo.dart';
import 'package:jithub_flutter/page/explore/explore_controller.dart';
import 'package:jithub_flutter/router/router.dart';
import 'package:jithub_flutter/widget/network_image.dart';
import 'package:jithub_flutter/page/home/home_page.dart';

class ExplorePage extends BaseView<ExploreController> {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  bool get hasActionBar => false;

  @override
  NotifierBuilder buildContent(BuildContext context) {
    return (state) {
      List<TrendingRepo> trendingRepos = controller.trendingRepos;
      return Scaffold(
        body: ListView.builder(
            itemCount: trendingRepos.length,
            itemBuilder: (_, index) {
              TrendingRepo repo = trendingRepos[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ShadowContainer(
                  offsetX: 1,
                  offsetY: -3,
                  color: Colors.grey[300],
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          _onPressRepo(context, repo);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: DefaultNetworkImage(
                                    repo.avatar ?? "",
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                title: Text(repo.name ?? "",
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold)),
                                subtitle: Text(repo.author ?? "")),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Text(
                                repo.description ?? '',
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                              child: Row(
                                children: [
                                  buildIconText(
                                      (repo.currentPeriodStars ?? 0).toString() + ' Today',
                                      const Icon(Icons.star,
                                          color: Colors.yellow, size: 12)),
                                  const SizedBox(width: 12),
                                  buildIconText(
                                      repo.language ?? '',
                                      Icon(Icons.circle,
                                          color: Color(
                                              repo.languageColor?.toHexValue() ??
                                                  0xffffff),
                                          size: 10)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Row(
                                children: [
                                  buildIconText(
                                      (repo.stars ?? '0').toString(),
                                      Icon(Icons.star_border,
                                          color: Colors.grey[850], size: 12)),
                                  const SizedBox(width: 12),
                                  buildIconText(
                                      (repo.forks ?? '0').toString(),
                                      SvgPicture.asset(
                                          'assets/images/ic_trending_fork.svg',
                                          width: 10,
                                          height: 10)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Row(
                                children: [
                                  buildIconText(
                                      'Built By',
                                      Icon(Icons.person,
                                          color: Colors.grey[700], size: 14)),
                                  const SizedBox(width: 12),
                                  for (var i = 0;
                                      i < (min(repo.builtBy?.length ?? 0, 7));
                                      i++)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: DefaultNetworkImage(
                                          repo.builtBy?[i].avatar ?? "",
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(50, 0, 50, 12),
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(
                                        const Size(double.infinity, 40)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    )),
                                  ),
                                  onPressed: () {
                                    ToastUtils.success('Starred ${repo.name}');
                                  },
                                  child: const Text("Star",
                                      style: TextStyle(color: Colors.white))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      );
    };
  }

  void _onPressRepo(BuildContext context, TrendingRepo repo) {
    var name = (repo.author ?? "") + " / " + (repo.name ?? "");
    var url = repo.url;
    if (url != null) {
      XRouter.goWeb(context, url, name);
    }
  }
}
