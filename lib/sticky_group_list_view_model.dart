import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StickyGroupListViewModel extends ChangeNotifier {
  final double headerDefaultHeight;

  StickyGroupListViewModel({required this.headerDefaultHeight});

  Map<GlobalObjectKey, bool> _pinnedMap = {};

  Map<GlobalObjectKey, double> _headerHeightMap = {};

  Map<GlobalObjectKey, bool> get pinnedMap => _pinnedMap;

  Map<GlobalObjectKey, double> get groupHeaderHeightMap => _headerHeightMap;

  // 各Mapパラメータの初期化
  void initParameters({required List<GlobalObjectKey> keys}) {
    _pinnedMap =
        keys.fold(Map<GlobalObjectKey, bool>(), (previousValue, element) {
      previousValue[element] = false;
      return previousValue;
    });
    _pinnedMap[keys.first] = true;

    _headerHeightMap =
        keys.fold(Map<GlobalObjectKey, double>(), (previousValue, element) {
      previousValue[element] = headerDefaultHeight;
      return previousValue;
    });
  }

  // 指定したkeyのpinnedをtrueにして、それ以外をfalseにする
  void setPinned(GlobalObjectKey key, {bool needNotify = true}) {
    if (_pinnedMap[key] ?? true) return;
    _pinnedMap.updateAll((key, value) => false);
    _pinnedMap.update(key, (value) => true);
    if (needNotify) {
      notifyListeners();
    }
  }

  // 指定したkeyのheaderHeightを更新する
  void setSeparatorHeight(GlobalObjectKey key, double height) {
    if (height < 0) return;
    _headerHeightMap.update(key, (value) => height);
    notifyListeners();
  }
}
