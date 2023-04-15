import 'package:flutter/material.dart';


class BottomBar extends StatelessWidget {
  BottomBar({this.index});

  final int? index;
  final List<BottomNavigationBarItem> items = [];
  final List<Function(BuildContext)> callback = [];

  void addItem(icon, label, lcallback) {

    items.add(BottomNavigationBarItem(
        icon : icon,
        label : label
    ));
    callback.add(lcallback);
  }

  @override
  Widget build(BuildContext context) {
    /// BottomNavigationBar is automatically set to type 'fixed'
    /// when there are three of less items
    return BottomNavigationBar(
      onTap:  (int index) {
          callback[index](context);
      },
      items: items,
    );
  }
}
