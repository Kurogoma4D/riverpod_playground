import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_playground/todo/todo.dart';
import 'package:riverpod_playground/todo_controller.dart';

final addTodoKey = UniqueKey();
final activeFilterKey = UniqueKey();
final completedFilterKey = UniqueKey();
final allFilterKey = UniqueKey();

final todoListProvider = StateNotifierProvider(
  (ref) => TodoController([
    Todo(id: 'todo-0', description: 'hi'),
    Todo(id: 'todo-1', description: 'hello'),
    Todo(id: 'todo-2', description: 'bonjour'),
  ]),
);

enum TodoListFilter {
  all,
  active,
  completed,
}

final todoListFilter = StateProvider((_) => TodoListFilter.all);

final uncompletedTodosCount = Computed(
  (read) =>
      read(todoListProvider.state).where((todo) => !todo.completed).length,
);

final filterdTodos = Computed<List<Todo>>((read) {
  final filter = read(todoListFilter);
  final todos = read(todoListProvider.state);

  switch (filter.state) {
    case TodoListFilter.active:
      return todos.where((todo) => !todo.completed).toList();
      break;
    case TodoListFilter.completed:
      return todos.where((todo) => todo.completed).toList();
      break;
    case TodoListFilter.all:
    default:
      return todos;
  }
});

void main() {
  runApp(ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Center(
        child: const _Indicator(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => counterProvider.read(context).increment(),
      ),
    );
  }
}
