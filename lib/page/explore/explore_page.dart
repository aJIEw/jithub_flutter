import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/base/base_page.dart';
import 'package:jithub_flutter/core/extension/string.dart';
import 'package:jithub_flutter/core/widget/container/shadow_container.dart';
import 'package:jithub_flutter/data/response/trending_repo.dart';
import 'package:jithub_flutter/page/explore/explore_controller.dart';
import 'package:jithub_flutter/page/explore/explore_star_button.dart';
import 'package:jithub_flutter/page/home/home_page.dart';
import 'package:jithub_flutter/router/router.dart';
import 'package:jithub_flutter/widget/network_image.dart';

class ExplorePage extends BaseView<ExploreController> {
  const ExplorePage({super.key});

  @override
  bool get hasActionBar => false;

  @override
  NotifierBuilder buildContent(BuildContext context) {
    return (state) {
      final List<TrendingRepo> trendingRepos = controller.trendingRepos;
      return Scaffold(
        body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          cacheExtent: 9999,
          itemCount: trendingRepos.length,
          itemBuilder: (_, index) {
            final TrendingRepo repo = trendingRepos[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ShadowContainer(
                offsetX: 1,
                offsetY: -3,
                color: Colors.grey[300] ?? Colors.grey,
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
                        _onPressRepo(repo);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Repo owner and star button
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: DefaultNetworkImage(
                                    repo.avatar ?? '',
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          repo.name ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(repo.author ?? ''),
                                      ],
                                    ),
                                  ),
                                ),
                                ExploreStarButton(
                                  repo.author ?? '',
                                  repo.name ?? '',
                                ),
                              ],
                            ),
                          ),

                          // Repo description
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(
                              repo.description ?? '',
                              style: const TextStyle(fontSize: 15),
                              textAlign: TextAlign.left,
                            ),
                          ),

                          // Repo star and other info
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                            child: Row(
                              children: [
                                buildIconText(
                                  '${repo.currentPeriodStars ?? 0} Today',
                                  const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (repo.language?.isNotEmpty ?? false)
                                  buildIconText(
                                    repo.language ?? '',
                                    Icon(
                                      Icons.circle,
                                      color: Color(
                                        repo.languageColor?.toHexValue() ??
                                            0xffffff,
                                      ),
                                      size: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Total star and fork number
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Row(
                              children: [
                                buildIconText(
                                  (repo.stars ?? '0').toString(),
                                  Icon(
                                    Icons.star_border,
                                    color: Colors.grey[850],
                                    size: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                buildIconText(
                                  (repo.forks ?? '0').toString(),
                                  SvgPicture.asset(
                                    'assets/images/ic_trending_fork.svg',
                                    width: 10,
                                    height: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Built by, top 7 contributors
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Row(
                              children: [
                                buildIconText(
                                  'Built By',
                                  Icon(
                                    Icons.person,
                                    color: Colors.grey[700],
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                for (
                                  var i = 0;
                                  i < (min(repo.builtBy?.length ?? 0, 7));
                                  i++
                                )
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: DefaultNetworkImage(
                                        repo.builtBy?[i].avatar ?? '',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    };
  }

  void _onPressRepo(TrendingRepo repo) {
    final name = '${repo.author ?? ''} / ${repo.name ?? ''}';
    final url = repo.url;
    if (url != null) {
      XRouter.goWeb(url, name);
    }
  }
}
