import 'dart:async';

import 'package:flutter/material.dart';

enum ButtonState { busy, idle }

/// Modified from https://github.com/iamyogik/argon_buttons_flutter/blob/master/lib/argon_buttons_flutter.dart
class TimerButton extends StatefulWidget {
  final ButtonStyle? style;
  final Widget Function(int time)? loader;
  final void Function(
    void Function(int startSeconds) startTimer,
    ButtonState? btnState,
  )?
  onTap;
  final VoidCallback? onCountdownFinished;
  final int initialTimer;
  final Duration animationDuration;
  final Curve curve;
  final Curve reverseCurve;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final Widget child;

  const TimerButton({
    super.key,
    this.style,
    this.loader,
    this.onTap,
    this.onCountdownFinished,
    this.initialTimer = 0,
    this.animationDuration = const Duration(milliseconds: 450),
    this.curve = Curves.easeInOutCirc,
    this.reverseCurve = Curves.easeInOutCirc,
    this.clipBehavior = Clip.none,
    this.focusNode,
    required this.child,
  });

  @override
  State<TimerButton> createState() => _TimerButtonState();
}

class _TimerButtonState extends State<TimerButton>
    with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;
  ButtonState? btn;
  int secondsLeft = 0;
  Timer? _timer;
  final Stream<void> emptyStream = const Stream<void>.empty();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve,
      ),
    );

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          btn = ButtonState.idle;
        });
      }
    });

    if (widget.initialTimer == 0) {
      btn = ButtonState.idle;
    } else {
      startTimer(widget.initialTimer);
      btn = ButtonState.busy;
    }
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    _controller.dispose();
    super.dispose();
  }

  void animateForward() {
    setState(() {
      btn = ButtonState.busy;
    });
    _controller.forward();
  }

  void animateReverse() {
    _controller.reverse();
  }

  void startTimer(int newTime) {
    if (newTime == 0) {
      throw ('Count Down Time can not be null');
    }

    animateForward();

    setState(() {
      secondsLeft = newTime;
    });

    if (_timer != null) {
      _timer!.cancel();
    }

    final oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(() {
        if (secondsLeft < 1) {
          timer.cancel();
          widget.onCountdownFinished?.call();
        } else {
          secondsLeft = secondsLeft - 1;
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return buttonBody();
      },
    );
  }

  Widget buttonBody() {
    return ElevatedButton(
      style: widget.style,
      clipBehavior: widget.clipBehavior,
      focusNode: widget.focusNode,
      onPressed: () {
        if (widget.onTap != null) {
          widget.onTap!((newCounter) => startTimer(newCounter), btn);
        }
      },
      child: btn == ButtonState.idle
          ? widget.child
          : StreamBuilder(
              stream: emptyStream,
              builder: (context, snapshot) {
                if (secondsLeft == 0) {
                  animateReverse();
                }
                return widget.loader!(secondsLeft);
              },
            ),
    );
  }
}

class CountdownButton extends StatefulWidget {
  const CountdownButton({
    super.key,
    required this.seconds,
    required this.finalText,
    this.onPressed,
    this.startOnInitial = true,
  });

  final String finalText;
  final int seconds;
  final VoidCallback? onPressed;

  final bool startOnInitial;

  @override
  State<CountdownButton> createState() => _CountdownButtonState();
}

class _CountdownButtonState extends State<CountdownButton> {
  bool canResentCode = false;

  @override
  Widget build(BuildContext context) {
    return TimerButton(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0.2),
        backgroundColor: WidgetStateProperty.all(
          canResentCode ? Colors.blue : Colors.grey[300],
        ),
        minimumSize: WidgetStateProperty.all(const Size(100, 50)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
      initialTimer: widget.startOnInitial ? widget.seconds - 1 : 0,
      onTap: canResentCode ? _onTab : null,
      loader: _countdownLoader,
      onCountdownFinished: () {
        setState(() {
          canResentCode = true;
        });
      },
      child: displayText(widget.finalText),
    );
  }

  void _onTab(
    void Function(int startSeconds) startTimer,
    ButtonState? btnState,
  ) {
    if (btnState == ButtonState.idle) {
      setState(() {
        canResentCode = false;
      });
      startTimer(widget.seconds - 1);

      widget.onPressed?.call();
    }
  }

  Widget _countdownLoader(int time) {
    return displayText('${widget.finalText} (${time + 1})');
  }

  Widget displayText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.merge(
          const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
