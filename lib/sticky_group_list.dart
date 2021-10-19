import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'default_sliver_persistent_header.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sticky_group_list/platform/platform_refresh_indicator.dart';
import 'package:flutter_sticky_group_list/sticky_group_list_view_model.dart';

class StickyGroupList<T, E extends Object> extends StatelessWidget {
  // リスト化したいModelを入れる
  final List<T> elements;

  // グループ化するための値を返す
  final E Function(T element) groupBy;

  // グループごとのHeaderのWidgetを設定できる
  final Widget Function(E value) groupHeaderTitleBuilder;

  // リスト部分のWidgetを設定できる
  final Widget Function(BuildContext context, T element) itemBuilder;

  // リストを下に引っ張った時の更新処理を設定できる
  final Future<void> Function()? onRefresh;

  // ヘッダーの背景色
  final Color? groupHeaderBackgroundColor;

  // ヘッダーの高さ
  final double groupHeaderHeight;

  final Map<E, GlobalObjectKey> _headerGlobalKeys = {};
  final _scrollController = ScrollController();

  StickyGroupList({
    Key? key,
    required this.elements,
    required this.groupBy,
    required this.groupHeaderTitleBuilder,
    required this.itemBuilder,
    this.onRefresh,
    this.groupHeaderBackgroundColor,
    this.groupHeaderHeight = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var itemGroups = _itemGroups;
    itemGroups.keys
        .forEach((key) => _headerGlobalKeys[key] = GlobalObjectKey(key));
    return ListenableProvider(
      create: (_) {
        final viewModel =
            StickyGroupListViewModel(headerDefaultHeight: groupHeaderHeight);
        viewModel.initParameters(keys: _headerGlobalKeys.values.toList());
        _scrollController.addListener(() => _scrollListener(viewModel));
        return viewModel;
      },
      dispose: _dispose,
      child: _SliverGroupList(
        groupHeaderTitleBuilder: groupHeaderTitleBuilder,
        itemBuilder: itemBuilder,
        onRefresh: onRefresh,
        groupHeaderBackgroundColor: groupHeaderBackgroundColor,
        itemGroups: itemGroups,
        headerGlobalKeys: _headerGlobalKeys,
        scrollController: _scrollController,
      ),
    );
  }

  Map<E, List<T>> get _itemGroups =>
      elements.fold(Map<E, List<T>>(), (itemGroup, element) {
        final group = groupBy(element);
        var groupItem = itemGroup[group];
        if (groupItem != null) {
          groupItem.add(element);
          itemGroup[group] = groupItem;
        } else {
          itemGroup[group] = [element];
        }
        return itemGroup;
      });

  void _dispose(BuildContext context, ChangeNotifier? notifier) {
    notifier?.dispose();
    _scrollController.dispose();
  }

  void _scrollListener(StickyGroupListViewModel viewModel) {
    final keyList = _headerGlobalKeys.values.toList();
    final currentKey =
        keyList.firstWhere((element) => viewModel.getHeaderHeight(element) > 0);
    final currentHeader = currentKey.currentContext?.findRenderObject()
        as RenderSliverPersistentHeader?;

    if (currentHeader == null) {
      return;
    }

    final isDownScroll = currentHeader.constraints.userScrollDirection ==
        ScrollDirection.reverse;
    if (isDownScroll) {
      // 下スクロール時

      if (keyList.length > keyList.indexOf(currentKey) + 1) {
        final nextKey = keyList[keyList.indexOf(currentKey) + 1];
        final nextHeader = nextKey.currentContext?.findRenderObject()
            as RenderSliverPersistentHeader?;

        if (nextHeader != null) {
          final double currentHeight =
              nextHeader.constraints.precedingScrollExtent -
                  _scrollController.offset;

          // 高さ更新
          viewModel.setHeaderHeight(currentKey, currentHeight);
        }
      }
    } else if (!isDownScroll) {
      // 上スクロール時

      // ヘッダー同士が接触した後の高さ更新
      var currentHeight = viewModel.getHeaderHeight(currentKey);
      if (currentHeight < groupHeaderHeight) {
        // 上部ヘッダーの高さを変更

        if (keyList.length > keyList.indexOf(currentKey) + 1) {
          final nextKey = keyList[keyList.indexOf(currentKey) + 1];
          final nextHeader = nextKey.currentContext?.findRenderObject()
              as RenderSliverPersistentHeader?;
          if (nextHeader != null) {
            currentHeight = nextHeader.constraints.precedingScrollExtent -
                _scrollController.offset;

            // 高さ更新
            viewModel.setHeaderHeight(currentKey, currentHeight);
          }
        }
      } else if (0 <= keyList.indexOf(currentKey) - 1) {
        // 上部ヘッダーより前にあるヘッダーを表示
        final previousKey = keyList[keyList.indexOf(currentKey) - 1];
        final previousHeight = currentHeader.constraints.precedingScrollExtent -
            _scrollController.offset;

        // 高さ更新
        viewModel.setHeaderHeight(previousKey, previousHeight);
      }
    }
  }
}

class _SliverGroupList<T, E extends Object> extends StatelessWidget {
  final Widget Function(E value) groupHeaderTitleBuilder;
  final Widget Function(BuildContext context, T element) itemBuilder;
  final Future<void> Function()? onRefresh;
  final Color? groupHeaderBackgroundColor;
  final Map<E, List<T>> itemGroups;
  final Map<E, GlobalObjectKey> headerGlobalKeys;
  final ScrollController? scrollController;

  _SliverGroupList(
      {required this.groupHeaderTitleBuilder,
      required this.itemBuilder,
      required this.onRefresh,
      required this.groupHeaderBackgroundColor,
      required this.itemGroups,
      required this.headerGlobalKeys,
      required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StickyGroupListViewModel>();
    return sliverGroupListWidget(viewModel);
  }

  Widget sliverGroupListWidget(StickyGroupListViewModel viewModel) {
    List<Widget> slivers = [];
    itemGroups.forEach((key, value) {
      final globalKey = headerGlobalKeys[key];
      slivers
        ..add(DefaultSliverPersistentHeader(
            headerKey: globalKey,
            title: groupHeaderTitleBuilder(key),
            backgroundColor: groupHeaderBackgroundColor,
            maxHeight: viewModel.headerDefaultHeight,
            minHeight: viewModel.getHeaderHeight(globalKey)))
        ..add(SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) => itemBuilder(context, value[index]),
                childCount: value.length)));
    });

    final onRefresh = this.onRefresh;
    if (onRefresh != null) {
      return PlatformRefreshIndicator(
          onRefresh: onRefresh, slivers: slivers, controller: scrollController);
    } else {
      return CustomScrollView(
        slivers: slivers,
        controller: scrollController,
      );
    }
  }
}
