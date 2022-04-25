import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/widget/container/shadow_container.dart';
import 'package:jithub_flutter/data/response/user_repo.dart';
import 'package:jithub_flutter/page/home/home_repo_item_controller.dart';

import 'home_page.dart';

class HomeRepoItem extends StatelessWidget {
  HomeRepoItem(this.repoUrl, {Key? key})
      : controller = HomeRepoItemController(repoUrl),
        super(key: key);

  String repoUrl = "";

  HomeRepoItemController controller;

  @override
  Widget build(BuildContext context) {
    return ShadowContainer(
        offsetX: 1,
        offsetY: -3,
        color: Colors.grey[300],
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Obx(() {
            UserRepo repo = controller.repo.value;

            if (controller.loading.value) {
              return SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width - 16,
                child: const CupertinoActivityIndicator(),
              );
            } else {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    onPressRepo(context, repo);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            repo.name ?? '',
                            style: TextStyle(
                                color: Colors.grey[850],
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (repo.description != null &&
                              repo.description != '')
                            Text(repo.description!),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              buildIconText(
                                  (repo.stargazersCount ?? 0).toString(),
                                  const Icon(Icons.star,
                                      color: Colors.yellow, size: 12)),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: buildIconText(
                                    repo.language ?? '',
                                    Icon(Icons.circle,
                                        color: Colors.grey[850], size: 8)),
                              ),
                            ],
                          )
                        ]),
                  ),
                ),
              );
            }
          }),
        ));
  }
}
