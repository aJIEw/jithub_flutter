import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:jithub_flutter/core/util/event.dart';
import 'package:jithub_flutter/core/widget/anchored_popup.dart';
import 'package:jithub_flutter/core/widget/clickable.dart';
import 'package:jithub_flutter/data/event/bus_event.dart';
import 'package:jithub_flutter/data/model/contribution_record.dart';
import 'package:jithub_flutter/page/profile/profile_controller.dart';

class ContributionGraphView extends GetView<ProfileController> {
  ContributionGraphView({super.key});

  final _weekdays = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final _graphSize = 160.0;
  final _scrollController = ScrollController();

  final ValueNotifier<GlobalKey?> _todayKey = ValueNotifier(null);
  final ValueNotifier<Text?> _todayMessage = ValueNotifier(null);
  final Jiffy _today = Jiffy.now();

  @override
  Widget build(BuildContext context) {
    registerBusEvent(context);

    return SizedBox(
      height: _graphSize,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildContributionLabel(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(color: Colors.grey[300], width: 1, height: _graphSize),
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
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final columnCount = (controller.contributionList.length / 7)
                      .ceil();
                  final columnWidth = _graphSize / 7;
                  final contentWidth = columnCount * columnWidth;
                  final hasOverflow = contentWidth > constraints.maxWidth;

                  return hasOverflow
                      ? SizedBox(
                          width: constraints.maxWidth,
                          child: ScrollConfiguration(
                            behavior: const MaterialScrollBehavior().copyWith(
                              overscroll: false,
                            ),
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
                              itemBuilder: (_, index) => _buildContributionCell(
                                context,
                                controller.contributionList[index],
                              ),
                            ),
                          ),
                        )
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: contentWidth,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (
                                  var column = columnCount - 1;
                                  column >= 0;
                                  column--
                                )
                                  SizedBox(
                                    width: columnWidth,
                                    child: Column(
                                      children: [
                                        for (var row = 0; row < 7; row++)
                                          Expanded(
                                            child: _buildContributionCell(
                                              context,
                                              controller
                                                  .contributionList[column * 7 +
                                                  row],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                },
              )
            : const CupertinoActivityIndicator(radius: 8),
      ),
    );
  }

  Widget _buildContributionCell(
    BuildContext context,
    ContributionRecord contribution,
  ) {
    final num = contribution.number;
    final contributionDateText = contribution.date.isNotEmpty
        ? Jiffy.parse(contribution.date).format(pattern: 'MMM dd, yyyy')
        : '';
    final messageText = Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 12, color: Colors.white),
        children: [
          TextSpan(
            text: '$num contribution${num > 1 ? 's' : ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' on $contributionDateText'),
        ],
      ),
    );
    final popupKey = GlobalKey();

    if (_todayKey.value == null &&
        contribution.date.isNotEmpty &&
        Jiffy.parse(contribution.date).dateTime.year == _today.dateTime.year &&
        Jiffy.parse(contribution.date).dayOfYear == _today.dayOfYear) {
      _todayKey.value = popupKey;
      _todayMessage.value = messageText;
    }

    final maxNum = controller.maxDailyContribution.value;
    final minNum = controller.minDailyContribution.value;
    final step = (maxNum - minNum) / 3;
    final minLevel = minNum + step;
    final midLevel = minNum + step * 2;
    final maxLevel = minNum + step * 3;
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
        _showPopupWindow(context, popupKey, messageText);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: contributionColor,
        ),
        margin: const EdgeInsets.all(4),
      ),
    );
  }

  void _showPopupWindow(
    BuildContext context,
    GlobalKey popupKey,
    Widget message,
  ) {
    showAnchoredPopup<void>(
      context: context,
      anchorKey: popupKey,
      child: message,
      preferredDirection: AnchoredPopupDirection.auto,
      backgroundColor: const Color(0xFF383D3B),
      borderRadius: 6,
      offset: 6,
      spaceMargin: -6,
      screenPadding: 10,
      arrowHeight: 8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  void registerBusEvent(BuildContext context) {
    XEvent.on(BusEvent.showInitPopup, (ContributionRecord event) {
      if (_todayKey.value != null &&
          _todayMessage.value != null &&
          controller.canShowPopup) {
        _showPopupWindow(context, _todayKey.value!, _todayMessage.value!);
        controller.popupShown = true;
      }
    });
  }
}
