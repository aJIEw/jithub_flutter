import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jithub_flutter/core/widget/anchored_popup.dart';

void main() {
  testWidgets('shows popup and dismisses on barrier tap', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _PopupTestPage()));

    await tester.tap(find.text('Show top popup'));
    await tester.pumpAndSettle();

    expect(find.text('Top popup'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('Top popup'), findsNothing);
  });

  testWidgets('turns popup over when bottom space is limited', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 300));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: _PopupTestPage()));

    final anchor = find.byKey(_PopupTestPage.bottomKey);
    final anchorTopLeft = tester.getTopLeft(anchor);

    await tester.tap(find.text('Show bottom popup'));
    await tester.pumpAndSettle();

    final popup = find.text('Bottom popup');
    expect(popup, findsOneWidget);

    final popupTopLeft = tester.getTopLeft(popup);
    expect(popupTopLeft.dy, lessThan(anchorTopLeft.dy));
  });

  testWidgets('keeps only one popup visible at a time', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: _PopupTestPage(key: _PopupTestPage.pageKey)),
    );

    await tester.tap(find.text('Show top popup'));
    await tester.pumpAndSettle();
    expect(find.text('Top popup'), findsOneWidget);

    _PopupTestPage.pageKey.currentState!.showSecondPopup();
    await tester.pumpAndSettle();

    expect(find.text('Top popup'), findsNothing);
    expect(find.text('Second popup'), findsOneWidget);
  });

  testWidgets('positions popup correctly for right-side anchors', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _PopupTestPage()));

    final anchor = find.byKey(_PopupTestPage.secondKey);
    final anchorCenter = tester.getCenter(anchor);

    await tester.tap(find.text('Show second popup'));
    await tester.pumpAndSettle();

    final popup = find.text('Second popup');
    expect(popup, findsOneWidget);

    final popupRect = tester.getRect(popup);
    expect(popupRect.left, greaterThan(150));
    expect(anchorCenter.dx, greaterThanOrEqualTo(popupRect.left - 40));
    expect(anchorCenter.dx, lessThanOrEqualTo(popupRect.right + 40));
  });
}

class _PopupTestPage extends StatefulWidget {
  const _PopupTestPage({super.key});

  static final pageKey = GlobalKey<_PopupTestPageState>();
  static final topKey = GlobalKey();
  static final bottomKey = GlobalKey();
  static final secondKey = GlobalKey();

  @override
  State<_PopupTestPage> createState() => _PopupTestPageState();
}

class _PopupTestPageState extends State<_PopupTestPage> {
  void showTopPopup() {
    showAnchoredPopup<void>(
      context: context,
      anchorKey: _PopupTestPage.topKey,
      text: 'Top popup',
      preferredDirection: AnchoredPopupDirection.bottom,
      offset: 6,
      spaceMargin: -6,
    );
  }

  void showBottomPopup() {
    showAnchoredPopup<void>(
      context: context,
      anchorKey: _PopupTestPage.bottomKey,
      text: 'Bottom popup',
      preferredDirection: AnchoredPopupDirection.bottom,
      offset: 6,
      turnOverFromBottom: 80,
    );
  }

  void showSecondPopup() {
    showAnchoredPopup<void>(
      context: context,
      anchorKey: _PopupTestPage.secondKey,
      text: 'Second popup',
      preferredDirection: AnchoredPopupDirection.bottom,
      offset: 6,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              top: 40,
              left: 40,
              child: ElevatedButton(
                key: _PopupTestPage.topKey,
                onPressed: showTopPopup,
                child: const Text('Show top popup'),
              ),
            ),
            Positioned(
              top: 220,
              left: 40,
              child: ElevatedButton(
                key: _PopupTestPage.bottomKey,
                onPressed: showBottomPopup,
                child: const Text('Show bottom popup'),
              ),
            ),
            Positioned(
              top: 40,
              left: 220,
              child: ElevatedButton(
                key: _PopupTestPage.secondKey,
                onPressed: showSecondPopup,
                child: const Text('Show second popup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
