import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StickyGroupListViewModel extends ChangeNotifier {
  final double headerDefaultHeight;

  StickyGroupListViewModel({required this.headerDefaultHeight});

  Map<GlobalObjectKey, double> _headerHeightMap = {};

  Map<GlobalObjectKey, double> get headerHeightMap => _headerHeightMap;


  // 各Mapパラメータの初期化
  void initParameters({required List<GlobalObjectKey> keys}) {
    _headerHeightMap =
        keys.fold(Map<GlobalObjectKey, double>(), (previousValue, element) {
      previousValue[element] = headerDefaultHeight;
      return previousValue;
    });
  }

  double getHeaderHeight(GlobalObjectKey? key) {
    return _headerHeightMap[key] ?? 0;
  }

  // 指定したkeyのheaderHeightを更新する
  void setHeaderHeight(GlobalObjectKey key, double height) {
    if (height > headerDefaultHeight) {
      if (getHeaderHeight(key) == headerDefaultHeight) {
        return;
      }
      _headerHeightMap.update(key, (value) => headerDefaultHeight);
    } else if (height < 0) {
      if (getHeaderHeight(key) == 0) {
        return;
      }
      _headerHeightMap.update(key, (value) => 0);
    } else {
      if (getHeaderHeight(key) == height) {
        return;
      }
      _headerHeightMap.update(key, (value) => height);
    }
    notifyListeners();
  }
}
