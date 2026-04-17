import 'dart:math' as math;

import 'package:flutter/material.dart';

enum AnchoredPopupDirection { auto, top, bottom }

class AnchoredPopupHandle {
  AnchoredPopupHandle._(this._dismiss);

  final VoidCallback _dismiss;
  bool _dismissed = false;

  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _dismiss();
  }
}

AnchoredPopupHandle? _activePopupHandle;

/// Closes the currently visible anchored popup, if any.
void dismissActiveAnchoredPopup() {
  _activePopupHandle?.dismiss();
}

/// Shows a lightweight popup anchored to [anchorKey].
///
/// Usage:
/// ```dart
/// showAnchoredPopup<void>(
///   context: context,
///   anchorKey: popupKey,
///   child: const Text('Popup content'),
/// );
/// ```
///
/// Provide either [child] or [text]. Opening a new popup automatically
/// dismisses the previous one so only one popup stays visible at a time.
Future<T?> showAnchoredPopup<T>({
  required BuildContext context,
  required GlobalKey anchorKey,
  Widget? child,
  String? text,
  TextStyle? textStyle,
  AnchoredPopupDirection preferredDirection = AnchoredPopupDirection.bottom,
  Color barrierColor = Colors.transparent,
  Color backgroundColor = const Color(0xFF383D3B),
  Color borderColor = Colors.transparent,
  double borderWidth = 0.5,
  double borderRadius = 6,
  double offset = 0,
  double screenPadding = 8,
  double spaceMargin = 0,
  double? maxWidth,
  double arrowWidth = 15,
  double arrowHeight = 6,
  double? arrowOffset,
  double turnOverFromBottom = 50,
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  ),
  bool barrierDismissible = true,
  bool canWrap = false,
  bool showCloseIcon = false,
  VoidCallback? onDismissed,
}) {
  assert(
    child != null || text != null,
    'Either child or text must be provided.',
  );

  final anchorContext = anchorKey.currentContext;
  final rootNavigator = Navigator.of(context, rootNavigator: true);
  final overlayState = rootNavigator.overlay;
  if (anchorContext == null || overlayState == null) {
    return Future<T?>.value();
  }

  final anchorRenderBox = anchorContext.findRenderObject() as RenderBox?;
  final overlayRenderBox =
      overlayState.context.findRenderObject() as RenderBox?;
  if (anchorRenderBox == null || overlayRenderBox == null) {
    return Future<T?>.value();
  }

  dismissActiveAnchoredPopup();

  final anchorRect =
      anchorRenderBox.localToGlobal(Offset.zero, ancestor: overlayRenderBox) &
      anchorRenderBox.size;
  final overlaySize = overlayRenderBox.size;
  final content =
      child ??
      _AnchoredPopupTextContent(
        text: text ?? '',
        textStyle:
            textStyle ?? const TextStyle(fontSize: 16, color: Colors.white),
        canWrap: canWrap,
        showCloseIcon: showCloseIcon,
      );

  late final AnchoredPopupHandle handle;
  bool didNotifyDismiss = false;

  void notifyDismissed() {
    if (didNotifyDismiss) return;
    didNotifyDismiss = true;
    onDismissed?.call();
  }

  // Only one popup can be visible at once.
  handle = AnchoredPopupHandle._(() {
    notifyDismissed();
    if (rootNavigator.canPop()) {
      rootNavigator.pop();
    }
  });
  _activePopupHandle = handle;

  final future = showGeneralDialog<T>(
    context: context,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final resolvedDirection = _resolveDirection(
        overlaySize: overlaySize,
        anchorRect: anchorRect,
        preferredDirection: preferredDirection,
        screenPadding: screenPadding,
        turnOverFromBottom: turnOverFromBottom,
      );

      return Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            if (barrierDismissible)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: handle.dismiss,
                ),
              ),
            _AnchoredPopupOverlay(
              anchorRect: anchorRect,
              overlaySize: overlaySize,
              direction: resolvedDirection,
              screenPadding: screenPadding,
              offset: offset,
              spaceMargin: spaceMargin,
              backgroundColor: backgroundColor.withAlpha(255),
              borderColor: borderColor.withAlpha(255),
              borderWidth: borderWidth,
              borderRadius: borderRadius,
              maxWidth: maxWidth,
              padding: padding,
              arrowWidth: arrowWidth,
              arrowHeight: arrowHeight,
              arrowOffset: arrowOffset,
              child: content,
            ),
          ],
        ),
      );
    },
    transitionBuilder:
        (dialogContext, animation, secondaryAnimation, dialogChild) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: dialogChild,
            ),
          );
        },
  );

  future.whenComplete(() {
    notifyDismissed();
    if (identical(_activePopupHandle, handle)) {
      _activePopupHandle = null;
    }
  });

  return future;
}

class _AnchoredPopupOverlay extends StatelessWidget {
  const _AnchoredPopupOverlay({
    required this.anchorRect,
    required this.overlaySize,
    required this.direction,
    required this.screenPadding,
    required this.offset,
    required this.spaceMargin,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.maxWidth,
    required this.padding,
    required this.arrowWidth,
    required this.arrowHeight,
    required this.arrowOffset,
    required this.child,
  });

  final Rect anchorRect;
  final Size overlaySize;
  final AnchoredPopupDirection direction;
  final double screenPadding;
  final double offset;
  final double spaceMargin;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double? maxWidth;
  final EdgeInsetsGeometry padding;
  final double arrowWidth;
  final double arrowHeight;
  final double? arrowOffset;
  final Widget child;

  bool get _expandedRight => anchorRect.center.dx < overlaySize.width / 2;

  @override
  Widget build(BuildContext context) {
    // Positioning rule: anchors on the left half expand to the right,
    // anchors on the right half expand to the left.
    final popupLeft = _expandedRight
        ? (anchorRect.left + spaceMargin)
              .clamp(screenPadding, overlaySize.width - screenPadding)
              .toDouble()
        : null;
    final popupRight = _expandedRight
        ? null
        : (overlaySize.width - anchorRect.right + spaceMargin)
              .clamp(screenPadding, overlaySize.width - screenPadding)
              .toDouble();
    final popupTop = direction == AnchoredPopupDirection.bottom
        ? (anchorRect.bottom + offset)
              .clamp(screenPadding, overlaySize.height - screenPadding)
              .toDouble()
        : null;
    final popupBottom = direction == AnchoredPopupDirection.top
        ? (overlaySize.height - anchorRect.top + offset)
              .clamp(screenPadding, overlaySize.height - screenPadding)
              .toDouble()
        : null;

    final popupMaxWidth =
        (maxWidth == null
                ? _expandedRight
                      ? math.max(
                          0,
                          overlaySize.width -
                              (popupLeft ?? screenPadding) -
                              screenPadding,
                        )
                      : math.max(
                          0,
                          overlaySize.width -
                              (popupRight ?? screenPadding) -
                              screenPadding,
                        )
                : maxWidth!)
            .toDouble();
    final popupMaxHeight =
        (direction == AnchoredPopupDirection.bottom
                ? math.max(
                    0,
                    overlaySize.height -
                        (popupTop ?? screenPadding) -
                        screenPadding,
                  )
                : math.max(
                    0,
                    overlaySize.height -
                        (popupBottom ?? screenPadding) -
                        screenPadding,
                  ))
            .toDouble();

    final autoArrowLeft = anchorRect.center.dx - arrowWidth / 2;
    final autoArrowRight =
        overlaySize.width - anchorRect.center.dx - arrowWidth / 2;
    final arrowLeft = _expandedRight
        ? (arrowOffset ?? autoArrowLeft)
              .clamp(
                screenPadding,
                overlaySize.width - screenPadding - arrowWidth,
              )
              .toDouble()
        : null;
    final arrowRight = _expandedRight
        ? null
        : (arrowOffset ?? autoArrowRight)
              .clamp(
                screenPadding,
                overlaySize.width - screenPadding - arrowWidth,
              )
              .toDouble();
    final arrowTop = direction == AnchoredPopupDirection.bottom
        ? (popupTop! - arrowHeight).toDouble()
        : null;
    final arrowBottom = direction == AnchoredPopupDirection.top
        ? (popupBottom! - arrowHeight).toDouble()
        : null;

    return Stack(
      children: [
        // Popup body.
        Positioned(
          left: popupLeft,
          right: popupRight,
          top: popupTop,
          bottom: popupBottom,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: popupMaxWidth,
              maxHeight: popupMaxHeight,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: Padding(
                padding: padding.resolve(Directionality.of(context)),
                child: child,
              ),
            ),
          ),
        ),
        // Arrow is positioned independently so it stays aligned with the anchor
        // even when the popup body width changes.
        Positioned(
          left: arrowLeft,
          right: arrowRight,
          top: arrowTop,
          bottom: arrowBottom,
          child: IgnorePointer(
            child: CustomPaint(
              size: Size(arrowWidth, arrowHeight),
              painter: _PopupArrowPainter(
                color: backgroundColor,
                borderColor: borderColor,
                borderWidth: borderWidth,
                direction: direction,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnchoredPopupTextContent extends StatelessWidget {
  const _AnchoredPopupTextContent({
    required this.text,
    required this.textStyle,
    required this.canWrap,
    required this.showCloseIcon,
  });

  final String text;
  final TextStyle textStyle;
  final bool canWrap;
  final bool showCloseIcon;

  @override
  Widget build(BuildContext context) {
    final icon = showCloseIcon
        ? const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(Icons.close, size: 14, color: Colors.white70),
          )
        : const SizedBox.shrink();

    if (canWrap) {
      return RichText(
        text: TextSpan(
          style: textStyle,
          children: [
            TextSpan(text: text),
            if (showCloseIcon)
              WidgetSpan(alignment: PlaceholderAlignment.middle, child: icon),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
        if (showCloseIcon) icon,
      ],
    );
  }
}

class _PopupArrowPainter extends CustomPainter {
  const _PopupArrowPainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.direction,
  });

  final Color color;
  final Color borderColor;
  final double borderWidth;
  final AnchoredPopupDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPath = Path();
    final strokePath = Path();
    final isDownArrow = direction == AnchoredPopupDirection.top;

    if (isDownArrow) {
      fillPath
        ..moveTo(0, -1.5)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, -1.5)
        ..close();
      strokePath
        ..moveTo(0, -0.5)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, -0.5);
    } else {
      fillPath
        ..moveTo(0, size.height + 1.5)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height + 1.5)
        ..close();
      strokePath
        ..moveTo(0.5, size.height + 0.5)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width - 0.5, size.height + 0.5);
    }

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    if (borderWidth > 0 && borderColor.a > 0) {
      canvas.drawPath(
        strokePath,
        Paint()
          ..color = borderColor
          ..strokeWidth = borderWidth
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PopupArrowPainter oldDelegate) {
    return color != oldDelegate.color ||
        borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth ||
        direction != oldDelegate.direction;
  }
}

AnchoredPopupDirection _resolveDirection({
  required Size overlaySize,
  required Rect anchorRect,
  required AnchoredPopupDirection preferredDirection,
  required double screenPadding,
  required double turnOverFromBottom,
}) {
  // Turn over from bottom when bottom space is tight.
  if (preferredDirection == AnchoredPopupDirection.top) {
    return AnchoredPopupDirection.top;
  }

  final bottomSpace = overlaySize.height - anchorRect.bottom - screenPadding;
  if (preferredDirection == AnchoredPopupDirection.bottom) {
    return bottomSpace < turnOverFromBottom
        ? AnchoredPopupDirection.top
        : AnchoredPopupDirection.bottom;
  }

  final topSpace = anchorRect.top - screenPadding;
  return bottomSpace >= turnOverFromBottom || bottomSpace >= topSpace
      ? AnchoredPopupDirection.bottom
      : AnchoredPopupDirection.top;
}
