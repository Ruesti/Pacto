import 'package:flutter/material.dart';

class AppSpacing {
  static const screenPadding = EdgeInsets.symmetric(horizontal: 16);
  static const cardPadding = EdgeInsets.all(16);
  static const listItemPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  static const sectionGap = SizedBox(height: 24);
  static const itemGap = SizedBox(height: 8);
}

class AppRadius {
  static const card = BorderRadius.all(Radius.circular(16));
  static const listItem = BorderRadius.all(Radius.circular(12));
  static const badge = BorderRadius.all(Radius.circular(20));
  static const icon = BorderRadius.all(Radius.circular(10));
}
