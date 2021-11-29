import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_theme.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({Key? key}) : super(key: key);

  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = AppTheme.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('choose_theme'.tr)),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              sliver: SliverFixedExtentList(
                itemExtent: 50.0,
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      'theme_dark'.tr,
                      style: TextStyle(
                          color: _isDark
                              ? Colors.grey
                              : Theme.of(context).primaryColor),
                    ),
                    trailing: Switch(
                      value: _isDark,
                      onChanged: (value) {
                        AppTheme.changeTheme(
                            _isDark ? ThemeData.light() : ThemeData.dark());
                        setState(() {
                          _isDark = value;
                        });
                      },
                    ),
                  );
                }, childCount: 1),
              ),
            ),
            SliverPadding(
                padding: const EdgeInsets.all(10),
                sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        var themeColor = AppTheme.materialColors[index];
                        return GestureDetector(
                          onTap: () {
                            var theme = AppTheme.getDefaultTheme(index);
                            AppTheme.changeTheme(theme);
                          },
                          child: Container(color: themeColor),
                        );
                      },
                      childCount: AppTheme.materialColors.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        childAspectRatio: 1.0)))
          ],
        ));
  }
}
