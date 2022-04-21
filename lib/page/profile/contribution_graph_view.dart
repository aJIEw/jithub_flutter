import 'package:bruno/bruno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:jithub_flutter/core/constants.dart';
import 'package:jithub_flutter/core/util/event.dart';
import 'package:jithub_flutter/core/widget/clickable.dart';
import 'package:jithub_flutter/data/event/bus_event.dart';
import 'package:jithub_flutter/data/model/contribution_record.dart';
import 'package:jithub_flutter/page/profile/profile_controller.dart';

class ContributionGraphView extends GetView<ProfileController> {
  ContributionGraphView({Key? key}) : super(key: key);

  final _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final _graphSize = 160.0;
  final _scrollController = ScrollController();

  GlobalKey? _todayKey;
  Text? _todayMessage;
  final Jiffy _today = Jiffy();

  @override
  Widget build(BuildContext context) {
    registerBusEvent(context);

    return SizedBox(
      height: _graphSize,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildContributionLabel(),
          Container(
            color: Colors.grey[300],
            width: 1,
            height: _graphSize,
          ),
          _buildContributionTable(context),
        ],
      ),
    );
  }

  void moveToEnd() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Widget _buildContributionLabel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 7; i++)
          SizedBox(
            width: 30,
            height: _graphSize / 7,
            child: Center(
              child: Text(
                _weekdays[i],
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
        child: controller.contributionList.isNotEmpty
            ? ScrollConfiguration(
                behavior:
                    const MaterialScrollBehavior().copyWith(overscroll: false),
                child: GridView.builder(
                    itemCount: controller.contributionList.length,
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    reverse: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (_, index) {
                      // contribution item
                      ContributionRecord contribution =
                          controller.contributionList[index];

                      // popup window 的内容
                      var num = contribution.number;
                      var messageText = Text.rich(TextSpan(
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                          children: [
                            TextSpan(
                                text: num.toString() +
                                    ' contribution' +
                                    (num > 1 ? 's' : ''),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: ' on ' + contribution.date.toString()),
                          ]));
                      var popupKey = GlobalKey();

                      // 保存当日的 key 和 message，用于初次点击到 profile 时显示 popup
                      if (_todayKey == null &&
                          Jiffy(contribution.date, Constants.dateDefaultFormat)
                                  .dayOfYear ==
                              _today.dayOfYear) {
                        _todayKey = popupKey;
                        _todayMessage = messageText;
                      }

                      // 根据当日最多和最少 commit 数显示不同深度的颜色
                      var maxNum = controller.maxDailyContribution.value;
                      var minNum = controller.minDailyContribution.value;
                      var step = (maxNum - minNum) / 3;
                      var minLevel = minNum + step;
                      var midLevel = minNum + step * 2;
                      var maxLevel = minNum + step * 3;
                      Color? contributionColor = Colors.transparent;
                      if (contribution.number >= maxLevel) {
                        contributionColor = Colors.green[800];
                      } else if (contribution.number >= midLevel) {
                        contributionColor = Colors.green[600];
                      } else if (contribution.number >= minLevel) {
                        contributionColor = Colors.green[400];
                      } else if (contribution.number > 0) {
                        contributionColor = Colors.green[200];
                      } else if (contribution.number > -1) {
                        contributionColor = const Color(0xFFE9E9E9);
                      }
                      return Clickable(
                        key: popupKey,
                        onPressed: () {
                          _showPopupWindow(
                              context, num.toString(), popupKey, messageText);
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
              )
            : const CupertinoActivityIndicator(radius: 8),
      ),
    );
  }

  void _showPopupWindow(
      BuildContext context, String num, GlobalKey popupKey, Widget message) {
    BrnPopupWindow.showPopWindow(
      context,
      num.toString(),
      popupKey,
      widget: message,
      popDirection: BrnPopupDirection.top,
      backgroundColor: const Color(0xFF383D3B),
      borderRadius: 6,
      offset: 6,
      spaceMargin: -6,
      arrowHeight: 8,
      paddingInsets: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  void registerBusEvent(BuildContext context) {
    XEvent.on(BusEvent.showInitPopup, (ContributionRecord event) {
      if (_todayKey != null &&
          _todayMessage != null &&
          controller.canShowPopup) {
        var num = event.number.toString();
        _showPopupWindow(context, num, _todayKey!, _todayMessage!);
        controller.popupShown = true;
      }
    });
  }
}
