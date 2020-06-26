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
      home: const Home(),
    );
  }
}

class Home extends HookWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todos = useProvider(filterdTodos);
    final newTodoController = useTextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        children: <Widget>[
          const Title(),
          TextField(
            key: addTodoKey,
            controller: newTodoController,
            decoration: const InputDecoration(
              labelText: 'What needs to be done?',
            ),
            onSubmitted: (value) {
              todoListProvider.read(context).add(value);
              newTodoController.clear();
            },
          ),
          const SizedBox(height: 42),
          Column(
            children: <Widget>[
              const Toolbar(),
              if (todos.isNotEmpty) const Divider(height: 8),
              for (var i = 0; i < todos.length; i++) ...[
                if (i > 0) const Divider(height: 0),
                Dismissible(
                  key: ValueKey(todos[i].id),
                  onDismissed: (_) =>
                      todoListProvider.read(context).remove(todos[i]),
                  child: TodoItem(todos[i]),
                )
              ],
            ],
          ),
        ],
      )),
    );
  }
}

class Toolbar extends HookWidget {
  const Toolbar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filter = useProvider(todoListFilter);

    Color textColorFor(TodoListFilter value) {
      return filter.state == value ? Colors.blue : null;
    }

    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              '${useProvider(uncompletedTodosCount).toString()} items left',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Tooltip(
            key: allFilterKey,
            message: 'All todos',
            child: FlatButton(
              onPressed: () => filter.state = TodoListFilter.all,
              visualDensity: VisualDensity.compact,
              textColor: textColorFor(TodoListFilter.all),
              child: const Text('All'),
            ),
          ),
          Tooltip(
            key: activeFilterKey,
            message: 'Only uncompleted todos',
            child: FlatButton(
              onPressed: () => filter.state = TodoListFilter.active,
              visualDensity: VisualDensity.compact,
              textColor: textColorFor(TodoListFilter.active),
              child: const Text('Active'),
            ),
          ),
          Tooltip(
            key: completedFilterKey,
            message: 'Only completed todos',
            child: FlatButton(
              onPressed: () => filter.state = TodoListFilter.completed,
              visualDensity: VisualDensity.compact,
              textColor: textColorFor(TodoListFilter.completed),
              child: const Text('Completed'),
            ),
          ),
        ],
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'todos',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromARGB(38, 47, 47, 247),
        fontSize: 100,
        fontWeight: FontWeight.w100,
        fontFamily: 'Helvetiva Neue',
      ),
    );
  }
}

class TodoItem extends HookWidget {
  const TodoItem(this.todo, {Key key}) : super(key: key);

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    final itemFocusNode = useFocusNode();

    useListenable(itemFocusNode);
    final isFocused = itemFocusNode.hasFocus;

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    return Material(
      color: Colors.white,
      elevation: 6,
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = todo.description;
          } else {
            todoListProvider
                .read(context)
                .edit(id: todo.id, description: textEditingController.text);
          }
        },
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value) =>
                todoListProvider.read(context).toggle(todo.id),
          ),
          title: isFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(todo.description),
        ),
      ),
    );
  }
}
