import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class PlatformRefreshIndicator extends PlatformWidget {
  final Key? key;
  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final ScrollController? controller;

  PlatformRefreshIndicator(
      {this.key,
      required this.onRefresh,
      required this.slivers,
      this.controller});

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (_, __) => RefreshIndicator(
          child: CustomScrollView(
            key: key,
            controller: controller,
            slivers: slivers,
          ),
          onRefresh: onRefresh),
      cupertino: (_, __) => CustomScrollView(
        key: key,
        controller: controller,
        slivers: <Widget>[
              CupertinoSliverRefreshControl(
                refreshTriggerPullDistance: 100.0,
                refreshIndicatorExtent: 60.0,
                onRefresh: onRefresh,
              ),
            ] +
            slivers,
      ),
    );
  }
}