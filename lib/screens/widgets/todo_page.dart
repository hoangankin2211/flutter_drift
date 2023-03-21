import 'package:demo_drift/screens/widgets/todo_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../database/database.dart';

class TodoPage extends StatelessWidget {
  TodoPage({
    super.key,
    required this.title,
    required this.image,
    required this.categoryId,
    required this.addTodoEntry,
  });
  final String title;
  final String image;
  final int categoryId;
  final Function({
    required String title,
    required String content,
    required int category,
  }) addTodoEntry;

  final _controller = TextEditingController();

  late final Stream<List<TodoEntryWithCategory>> todos =
      MyDatabase.instance.entriesInCategory(categoryId);

  void addToImportant(Todo todo, bool value) {
    MyDatabase.instance.updateTodo(todo);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(10)),
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.directional(
          textDirection: TextDirection.ltr,
          bottom: 5,
          start: 80,
          end: 80,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                color: Colors.white54, borderRadius: BorderRadius.circular(5)),
            child: TextField(
              controller: _controller,
              onSubmitted: (value) {
                addTodoEntry(
                  category: categoryId,
                  title: _controller.text,
                  content:
                      intl.DateFormat().add_yMMMMd().format(DateTime.now()),
                );
                _controller.clear();
              },
              decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: IconButton(
                    onPressed: () {
                      addTodoEntry(
                        category: categoryId,
                        title: _controller.text,
                        content: intl.DateFormat()
                            .add_yMMMMd()
                            .format(DateTime.now()),
                      );
                      _controller.clear();
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black54,
                    ),
                  ),
                  hintStyle: const TextStyle(color: Colors.black),
                  border: InputBorder.none,
                  hintText: "Add a task"),
            ),
          ),
        ),
        Positioned.directional(
          textDirection: TextDirection.ltr,
          top: 20,
          start: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              const SizedBox(height: 5),
              Text(
                intl.DateFormat().add_yMEd().format(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        Positioned.directional(
          textDirection: TextDirection.ltr,
          top: 100,
          start: 80,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.7,
            child: StreamBuilder<List<TodoEntryWithCategory>>(
                stream: todos,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 5),
                      itemBuilder: (context, index) {
                        final item = snapshot.data!.elementAt(index).entry;
                        return TodoCard(
                          isImportant: item.category == 2,
                          todo: item,
                        );
                      },
                      itemCount: snapshot.data?.length ?? 0,
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                }),
          ),
        ),
      ],
    );
  }
}
