import 'package:flutter/widgets.dart';
import 'package:jithub_flutter/core/app_theme.dart';
import 'package:material_ui/material_ui.dart' as modern;

class MaterialUiThemeScope extends StatelessWidget {
  const MaterialUiThemeScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return modern.Theme(data: AppTheme.getCurrentTheme(), child: child);
  }
}
