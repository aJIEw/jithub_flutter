// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:jiffy/jiffy.dart';

void main() {
  test('Jiffy days diff', () {
    var date1 = Jiffy('2022-04-21T03:53:30Z').dayOfYear;
    var today = Jiffy('2022-04-21T08:55:05Z').dayOfYear;
    var daysInBetween1 = today - date1;
    expect(daysInBetween1, 0);

    var date2 = Jiffy('2022-04-17T06:53:30Z').dayOfYear;
    var daysInBetween2 = today - date2;
    expect(daysInBetween2, 4);
  });

  test('Reverse list column index', () {
    /*
    == Problem ==
    * 14 > 20 | 7  > 13
    * 15 > 19 | 8  > 12
    * 16 > 18 | 9  > 11
    * 17 > 17 | 10 > 10
    * 18 > 16 | 11 > 9
    * 19 > 15 | 12 > 8
    * 20 > 14 | 13 > 7
    * */

    /*
    == Solution ==
    * input: i
    * mid = (i / 7.0).floor() * 7 + 3
    * if (i > mid) {
    *   return mid - (i - mid);
    * } else if (i < mid) {
    *   return mid + (mid - i);
    * } else {
    *   return i;
    * }
    * */

    var daysInBetween = 15;
    var _contributionPlaceholderDays = 3;

    var total = daysInBetween + _contributionPlaceholderDays;

    var mid = (total / 7.0).floor() * 7 + 3;
    var updateIndex = mid;
    if (total > mid) {
      updateIndex = mid - (total - mid);
    } else if (total < mid) {
      updateIndex = mid + (mid - total);
    }
    expect(updateIndex, 16);
  });
}
