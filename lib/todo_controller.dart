import 'package:flutter/cupertino.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:uuid/uuid.dart';

import 'todo/todo.dart';

final _uuid = Uuid();

class TodoController extends StateNotifier<List<Todo>> {
  TodoController([List<Todo> initialTodos]) : super(initialTodos ?? []);

  void add(String description) {
    state = [
      ...state,
      Todo(id: _uuid.v4(), description: description),
    ];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(
            completed: !todo.completed,
          )
        else
          todo,
    ];
  }

  void edit({@required String id, @required String description}) {
    state = [
      for (final todo in state)
        if (todo.id == id) todo.copyWith(description: description) else todo,
    ];
  }

  void remove(Todo target) {
    state = state.where((todo) => todo.id != target.id).toList();
  }

  void addAll(List<Todo> children) {
    state = [
      ...state,
      ...children,
    ];
  }
}
