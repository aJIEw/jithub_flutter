import 'package:flutter/material.dart';

class BaseContainer extends StatelessWidget {
  const BaseContainer(
      {Key? key, this.color = Colors.white, required this.child})
      : super(key: key);

  final Color? color;

  final child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        /*image: DecorationImage(
          image: AssetImage('assets/images/bg_theme.png'),
          fit: BoxFit.cover,
        ),*/
      ),
      child: child,
    );
  }
}
