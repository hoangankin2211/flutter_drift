import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'table.dart';
part 'database.g.dart';

@DriftDatabase(tables: [Todos, Categories])
class MyDatabase extends _$MyDatabase {
  MyDatabase._() : super(_openConnection());

  static final MyDatabase instance = MyDatabase._();

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        if (details.wasCreated) {
          await batch((b) {
            b.insert(
              categories,
              CategoriesCompanion.insert(description: 'My Day'),
            );
            b.insert(
              categories,
              CategoriesCompanion.insert(description: 'Important'),
            );
          });
        }
      },
    );
  }

  MyDatabase.executor(QueryExecutor executor) : super(executor);

  Stream<List<Category>> getAllCategory() {
    return select(categories).watch();
  }

  Stream<Todo> entryById(int id) {
    return (select(todos)..where((tbl) => tbl.id.equals(id))).watchSingle();
  }

  Stream<List<TodoEntryWithCategory>> entriesInCategory(int? category) {
    final query = select(todos).join(
        [leftOuterJoin(categories, categories.id.equalsExp(todos.category))]);

    if (category != null) {
      query.where(categories.id.equals(category));
    } else {
      query.where(categories.id.isNull());
    }

    return query.map((row) {
      return TodoEntryWithCategory(
        category: row.readTableOrNull(categories),
        entry: row.readTable(todos),
      );
    }).watch();
  }

  //insert, Update,delete,
  Future<int> addTodo(TodosCompanion entry) async {
    return await computeWithDatabase(
      computation: (database) async {
        int result = await database.into(database.todos).insert(entry);

        return result;
      },
      connect: (connection) {
        return MyDatabase.executor(connection);
      },
    );
  }

  Future<bool> updateTodo(Todo entry) async {
    return await computeWithDatabase(
      computation: (database) async {
        return await database.update(database.todos).replace(entry);
      },
      connect: (connection) {
        return MyDatabase.executor(connection);
      },
    );
  }

  Future<bool> deleteTodo(Todo entry) async {
    return await computeWithDatabase(
      computation: (database) {
        return database.transaction(() async {
          return database.todos.deleteOne(entry);
        });
      },
      connect: (connection) {
        return MyDatabase.executor(connection);
      },
    );
  }

  Future<int> addCategory(CategoriesCompanion entry) async {
    return await computeWithDatabase(
      computation: (database) {
        return database.into(database.categories).insert(entry);
      },
      connect: (connection) {
        return MyDatabase.executor(connection);
      },
    );
  }

  Future<bool> deleteCategory(Category category) async {
    return await computeWithDatabase(
      computation: (database) {
        return database.transaction(() async {
          await (database.todos.update()
                ..where((todo) => todo.category.equals(category.id)))
              .write(const TodosCompanion(category: Value(null)));
          return await database.categories.deleteOne(category);
        });
      },
      connect: (connection) {
        return MyDatabase.executor(connection);
      },
    );
  }

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();

    final file = File(p.join(dbFolder.path, "db.sqlite1"));

    return NativeDatabase.createInBackground(file);
  });
}

class TodoEntryWithCategory {
  final Todo entry;
  final Category? category;
  TodoEntryWithCategory({required this.category, required this.entry});
}

class CategoryWithCount {
  final Category? category;
  final int count;

  CategoryWithCount({required this.category, required this.count});
}
