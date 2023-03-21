import 'package:flutter/material.dart';

import '../../database/database.dart';

class TodoCard extends StatefulWidget {
  const TodoCard({
    super.key,
    required this.isImportant,
    required this.todo,
  });
  final Todo todo;
  final bool isImportant;

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  bool checked = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Checkbox(
          shape: const CircleBorder(),
          onChanged: (value) async {
            setState(() {
              checked = value ?? false;
            });
            await Future.delayed(const Duration(seconds: 1));
            if (checked) {
              MyDatabase.instance.deleteTodo(widget.todo);
            }
          },
          value: checked,
        ),
        title: Text(widget.todo.title, style: const TextStyle(fontSize: 20)),
        subtitle: Text(widget.todo.content),
        trailing: IconButton(
          icon: widget.isImportant
              ? const Icon(
                  Icons.star,
                  color: Colors.yellow,
                )
              : const Icon(
                  Icons.star_outline,
                  color: Colors.blueGrey,
                ),
          onPressed: () {
            MyDatabase.instance.updateTodo(Todo(
              id: widget.todo.id,
              title: widget.todo.title,
              content: widget.todo.content,
              category: widget.isImportant ? 1 : 2,
            ));
          },
        ),
      ),
    );
  }
}
