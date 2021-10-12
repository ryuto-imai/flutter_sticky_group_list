import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformTheme {
  final BuildContext context;

  PlatformTheme({required this.context});

  factory PlatformTheme.of(BuildContext context) =>
      PlatformTheme(context: context);

  Color get primaryColor {
    if (Platform.isIOS) {
      return CupertinoTheme.of(context).primaryColor;
    } else {
      return Theme.of(context).primaryColor;
    }
  }
}
