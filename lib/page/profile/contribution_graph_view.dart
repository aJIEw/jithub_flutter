import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/widget/clickable.dart';
import 'package:jithub_flutter/data/model/contribution_record.dart';

class ContributionGraphView extends StatelessWidget {
  ContributionGraphView({Key? key}) : super(key: key);

  var weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  var graphSize = 160.0;

  var contributionPlaceholderDays = 0;

  var contributionRecords = [];

  var scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _initContributionData();

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
    return Expanded(
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
        child: GridView.builder(
            itemCount: contributionRecords.length,
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
              ContributionRecord contribution = contributionRecords[index];
              var num = contribution.number;
              var messageText = Text.rich(TextSpan(
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  children: [
                    TextSpan(text: num.toString() + ' contribution' +
                        (num > 1 ? 's' : ''),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' on ' + contribution.date.toString()),
                  ]
              ));
              var popupKey = GlobalKey();

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
                    color: contribution.number > -1
                        ? Colors.green[500]
                        : Colors.transparent,
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
    );
  }

  void _initContributionData() {
    var today = DateTime.now();
    switch (today.weekday) {
      case DateTime.sunday:
        contributionPlaceholderDays = 6;
        break;
      case DateTime.monday:
        contributionPlaceholderDays = 5;
        break;
      case DateTime.tuesday:
        contributionPlaceholderDays = 4;
        break;
      case DateTime.wednesday:
        contributionPlaceholderDays = 3;
        break;
      case DateTime.thursday:
        contributionPlaceholderDays = 2;
        break;
      case DateTime.friday:
        contributionPlaceholderDays = 1;
        break;
      case DateTime.saturday:
        contributionPlaceholderDays = 0;
        break;
    }

    var startIndex = 7;
    var dateFormat = "MMM dd, yyyy";
    if (contributionPlaceholderDays > 0) {
      var totalOffset = 6 - contributionPlaceholderDays;
      for (var i = 0; i <= totalOffset; i++) {
        var offset = totalOffset - i;
        var date = Jiffy().subtract(days: offset).format(dateFormat);
        contributionRecords
            .add(ContributionRecord(index: i, date: date, number: 0));
      }

      for (var i = (7 - contributionPlaceholderDays); i < 7; i++) {
        contributionRecords
            .add(ContributionRecord(index: i, date: "", number: -1));
      }
    } else {
      startIndex = 0;
    }

    // 15 weeks at most
    for (var i = startIndex, j = 1; i <= 105; i = 7 * (++j)) {
      var weekEndIndex = i + 6;
      var weekStartIndex = i;
      for (var offset = weekEndIndex; offset >= i; offset--) {
        var date = Jiffy()
            .subtract(days: offset - contributionPlaceholderDays)
            .format("MMM dd, yyyy");
        contributionRecords.add(
            ContributionRecord(index: weekStartIndex, date: date, number: 0));
        weekStartIndex++;
      }
    }

    logger.d(
        'ContributionGraphView - _initContributionData: ${contributionRecords
            .length}');
  }
}
