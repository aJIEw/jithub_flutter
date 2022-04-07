import 'package:flutter/material.dart';

import '/router/router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const String displayText = 'Jithub';

  @override
  void initState() {
    super.initState();
    countDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColorDark,
                Theme.of(context).primaryColor,
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: const [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
          child: Center(
              child: Wrap(
            runSpacing: 50,
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: Axis.vertical,
            alignment: WrapAlignment.center,
            children: displayText
                .split('')
                .map((text) => Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
                .toList(),
          ))),
    );
  }

  void countDown() {
    var _duration = const Duration(seconds: 1);
    Future.delayed(_duration, goMainPage);
  }

  void goMainPage() {
    XRouter.replace(XRouter.homePage);
  }
}
