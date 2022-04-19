import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/widget/clickable.dart';
import 'package:jithub_flutter/data/model/contribution_record.dart';
import 'package:jithub_flutter/page/profile/profile_controller.dart';

class ContributionGraphView extends GetView<ProfileController> {
  ContributionGraphView({Key? key}) : super(key: key);

  var weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  var graphSize = 160.0;

  var scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: graphSize,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildContributionLabel(),
          Container(
            color: Colors.grey[300],
            width: 1,
            height: graphSize,
          ),
          _buildContributionTable(context),
        ],
      ),
    );
  }

  void moveToEnd() {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  Widget _buildContributionLabel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 7; i++)
          Container(
            width: 30,
            height: graphSize / 7,
            child: Center(
              child: Text(
                weekdays[i],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContributionTable(BuildContext context) {
    return Obx(
      () => Expanded(
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
          child: GridView.builder(
              itemCount: controller.contributionList.length,
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              reverse: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, index) {
                // contribution item
                ContributionRecord contribution =
                    controller.contributionList[index];
                var num = contribution.number;
                var messageText = Text.rich(TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    children: [
                      TextSpan(
                          text: num.toString() +
                              ' contribution' +
                              (num > 1 ? 's' : ''),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' on ' + contribution.date.toString()),
                    ]));
                var popupKey = GlobalKey();

                Color? contributionColor = Colors.transparent;
                if (contribution.number > 5) {
                  contributionColor = Colors.green[600];
                } else if (contribution.number > 3) {
                  contributionColor = Colors.green[400];
                } else if (contribution.number > 0) {
                  contributionColor = Colors.green[200];
                } else if (contribution.number > -1) {
                  contributionColor = const Color(0xFFE9E9E9);
                }
                return Clickable(
                  key: popupKey,
                  onPressed: () {
                    BrnPopupWindow.showPopWindow(
                      context,
                      num.toString(),
                      popupKey,
                      widget: messageText,
                      popDirection: BrnPopupDirection.top,
                      backgroundColor: const Color(0x383D3B),
                      borderRadius: 6,
                      offset: 6,
                      spaceMargin: -6,
                      arrowHeight: 8,
                      paddingInsets: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: contributionColor,
                    ),
                    margin: const EdgeInsets.all(4),
                    /*child: Center(
                      child: Text(
                        '${index}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),*/
                  ),
                );
              }),
        ),
      ),
    );
  }
}
