import 'package:flutter/cupertino.dart';
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
    this.groupHeaderHeight = 40,
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
        keyList.firstWhere((element) => viewModel.pinnedMap[element] ?? false);
    final currentHeader = currentKey.currentContext?.findRenderObject()
        as RenderSliverPersistentHeader?;

    if (currentHeader == null) {
      return;
    }

    final isDownScroll = currentHeader.constraints.userScrollDirection ==
        ScrollDirection.reverse;
    if (isDownScroll && keyList.length > keyList.indexOf(currentKey) + 1) {
      // 下スクロール時
      final nextKey = keyList[keyList.indexOf(currentKey) + 1];
      final nextHeader = nextKey.currentContext?.findRenderObject()
          as RenderSliverPersistentHeader?;

      if (nextHeader != null) {
        final double currentHeight =
            nextHeader.constraints.precedingScrollExtent -
                _scrollController.offset;
        // ヘッダー同士が接触した後の高さ更新
        if (currentHeight < groupHeaderHeight) {
          viewModel.setSeparatorHeight(currentKey, currentHeight);
        }
        // 下位ヘッダーが上までスクロールしきった時のpinned更新
        if (currentHeight <= 0) {
          viewModel.setPinned(nextKey);
        }
      }
    } else if (!isDownScroll) {
      // 上スクロール時

      // 上位ヘッダーが表示された時のpinned更新
      if (0 <= keyList.indexOf(currentKey) - 1) {
        final previousKey = keyList[keyList.indexOf(currentKey) - 1];
        if ((currentHeader.constraints.precedingScrollExtent -
                _scrollController.offset) >
            0) {
          viewModel.setPinned(previousKey, needNotify: false);
        }
      }

      // ヘッダー同士が接触した後の高さ更新
      if (keyList.length > keyList.indexOf(currentKey) + 1) {
        final nextKey = keyList[keyList.indexOf(currentKey) + 1];
        final nextHeader = nextKey.currentContext?.findRenderObject()
            as RenderSliverPersistentHeader?;
        if (nextHeader != null) {
          final double currentHeight =
              nextHeader.constraints.precedingScrollExtent +
                  nextHeader.constraints.overlap -
                  _scrollController.offset;
          if (currentHeight < groupHeaderHeight) {
            viewModel.setSeparatorHeight(currentKey, currentHeight);
          } else {
            viewModel.setSeparatorHeight(currentKey, groupHeaderHeight);
          }
        }
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
          pinned: viewModel.pinnedMap[globalKey],
          height: viewModel.groupHeaderHeightMap[globalKey],
        ))
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
