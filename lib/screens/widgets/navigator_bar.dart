import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../home_screen.dart';

class MyNavigatorBar extends StatefulWidget {
  const MyNavigatorBar({
    super.key,
    required this.index,
    required this.onDestinationSelected,
    required this.categories,
  });

  final int index;
  final Function(int) onDestinationSelected;
  final List<Category> categories;

  @override
  State<MyNavigatorBar> createState() => _MyNavigatorBarState();
}

class _MyNavigatorBarState extends State<MyNavigatorBar> {
  // {
  //   "icon": Icons.list_alt,
  //   "title": "Planned",
  //   "widget": TodoPage(
  //     todos: [],
  //     image: "assets/images/planned.jpg",
  //     title: "Planned",
  //   ),
  // },
  // {
  //   "icon": Icons.task,
  //   "title": "Tasks",
  //   "widget": TodoPage(
  //     todos: [],
  //     image: "assets/images/task.jpg",
  //     title: "Tasks",
  //   ),
  // },
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.index,
      onTap: widget.onDestinationSelected,
      elevation: 5,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.blue,
      type: BottomNavigationBarType.shifting,
      items: widget.categories
          .map((e) => BottomNavigationBarItem(
              icon: Icon(
                  HomeScreen.destinations[e.description]?["icon"] as IconData),
              label: e.description))
          .toList(),
    );
  }
}
