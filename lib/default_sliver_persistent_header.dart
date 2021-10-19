import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DefaultSliverPersistentHeader extends StatelessWidget {
  final Key? headerKey;
  final Widget? title;
  final Color? backgroundColor;
  final double maxHeight;
  final double minHeight;

  DefaultSliverPersistentHeader(
      {this.headerKey,
      this.title,
      this.backgroundColor,
      required this.maxHeight,
      required this.minHeight});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
        key: headerKey,
        delegate: _DefaultSliverPersistentHeaderDelegate(
            child: Container(
                color: backgroundColor,
                child: Padding(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: title,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                )),
            maxHeight: maxHeight,
            minHeight: minHeight),
        pinned: true);
  }
}

class _DefaultSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxHeight;
  final double minHeight;

  _DefaultSliverPersistentHeaderDelegate(
      {required this.child, required this.maxHeight, required this.minHeight});

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) =>
      maxExtent != oldDelegate.maxExtent;
}
