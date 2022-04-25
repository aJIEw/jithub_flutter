import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/util/event.dart';
import 'package:jithub_flutter/data/event/bus_event.dart';
import 'package:jithub_flutter/page/explore/star_button_controller.dart';

class ExploreStarButton extends StatelessWidget {
  ExploreStarButton(this.author, this.repoName, {Key? key})
      : controller = StarButtonController(author, repoName),
        super(key: key);

  String author;
  String repoName;
  StarButtonController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(50, 0, 50, 12),
      child: ElevatedButton(
          style: ButtonStyle(
            minimumSize:
                MaterialStateProperty.all(const Size(double.infinity, 40)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            )),
          ),
          onPressed: () {
            if (controller.loading.value) {
              return;
            }

            if (controller.notLoggedIn.value) {
              XEvent.post(BusEvent.showLoginPage, true);
            } else {
              if (controller.hasStarred.value) {
                controller.requestUnstarRepo();
              } else {
                controller.requestStarRepo();
              }
            }
          },
          child: Obx(
            () {
              if (controller.loading.value) {
                return const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                );
              }
              return Text(controller.hasStarred.value ? "Unstar" : "Star",
                  style: const TextStyle(color: Colors.white));
            },
          )),
    );
  }
}
