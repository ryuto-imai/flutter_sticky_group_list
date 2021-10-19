import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_sticky_group_list/platform/platform_theme.dart';
import 'package:flutter_sticky_group_list/sticky_group_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      title: 'Sliver Group List',
      material: (context, platform) =>
          MaterialAppData(theme: ThemeData(primarySwatch: Colors.blue)),
      cupertino: (context, platform) => CupertinoAppData(
          theme: CupertinoThemeData(primaryColor: CupertinoColors.systemBlue)),
      home: _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final list = List.generate(100,
        (index) =>
            _ListData(id: index % 10, title: 'Title ${index.toString()}'));

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: PlatformText('サンプル'),
      ),
      body: StickyGroupList(
        elements: list,
        groupBy: (_ListData element) => element.id,
        groupHeaderTitleBuilder: (int groupByValue) =>
            PlatformText(groupByValue.toString()),
        itemBuilder: (context, _ListData element) => Container(
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: PlatformText(element.title,
              style: TextStyle(color: Colors.black, fontSize: 18)),
        ),
        onRefresh: () async {
          print("refresh");
        },
        groupHeaderBackgroundColor: PlatformTheme.of(context).primaryColor,
        groupHeaderHeight: 60,
      ),
      iosContentPadding: true,
      iosContentBottomPadding: true,
    );
  }
}

class _ListData {
  final int id;
  final String title;

  _ListData({required this.id, required this.title});
}
