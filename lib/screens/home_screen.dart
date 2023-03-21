import 'package:demo_drift/screens/widgets/navigator_bar.dart';
import 'package:demo_drift/screens/widgets/todo_page.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../database/database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static final Map<String, Map<String, dynamic>> destinations = {
    "My Day": {
      "icon": Icons.sunny,
      "image": "assets/images/task.jpg",
    },
    "Important": {
      "icon": Icons.label_important,
      "image": "assets/images/planned.jpg",
    },
  };
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  Stream<List<Category>> categoryStream = MyDatabase.instance.getAllCategory();
  late final List<Widget> widgets;
  @override
  void initState() {
    super.initState();
  }

  void _addTodoEntry(
      {required String title, required String content, required int category}) {
    MyDatabase.instance.addTodo(
      TodosCompanion.insert(
        content: content,
        category: Value(category),
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Category>>(
        stream: categoryStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String title = snapshot.data?.elementAt(index).description ?? "";
            return Scaffold(
              bottomNavigationBar: MyNavigatorBar(
                categories: snapshot.data ?? ([] as List<Category>),
                index: index,
                onDestinationSelected: (value) => setState(() => index = value),
              ),
              backgroundColor: Colors.grey[50],
              body: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(10)),
                  border: Border.all(color: Colors.blueGrey, width: 0.1),
                ),
                child: IndexedStack(
                  index: index,
                  children: snapshot.data
                          ?.map(
                            (category) => TodoPage(
                              addTodoEntry: _addTodoEntry,
                              categoryId: category.id,
                              title: title,
                              image: HomeScreen.destinations[title]?["image"],
                            ),
                          )
                          .toList() ??
                      [],
                ),
              ),
            );
          }
          return const Material(
              child: Center(child: CircularProgressIndicator()));
        });
  }
}
