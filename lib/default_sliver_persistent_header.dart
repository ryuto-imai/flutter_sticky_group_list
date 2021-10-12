import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DefaultSliverPersistentHeader extends StatelessWidget {
  final Key? headerKey;
  final Widget? title;
  final Color? backgroundColor;
  final double? height;
  final bool? pinned;

  DefaultSliverPersistentHeader(
      {this.headerKey,
      this.title,
      this.backgroundColor,
      this.height,
      this.pinned});

  @override
  Widget build(BuildContext context) {
    final double defaultHeight = 40;
    return SliverPersistentHeader(
      key: headerKey,
      delegate: _DefaultSliverPersistentHeaderDelegate(
          child: PreferredSize(
              preferredSize: Size.fromHeight(height ?? defaultHeight),
              child: Container(
                  color: backgroundColor,
                  child: Padding(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: title,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  )))),
      pinned: pinned ?? false,
    );
  }
}

class _DefaultSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final PreferredSize child;

  _DefaultSliverPersistentHeaderDelegate({required this.child});

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;

  @override
  double get maxExtent => child.preferredSize.height;

  @override
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
