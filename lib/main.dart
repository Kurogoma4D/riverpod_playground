import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

class _Indicator extends HookWidget {
  const _Indicator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counter = useProvider(counterProvider);

    return Text(counter.count.toString());
  }
}

class Counter extends ChangeNotifier {
  Counter() {
    count = 0;
  }

  int count;

  void increment() {
    count++;
    notifyListeners();
  }
}

final counterProvider = ChangeNotifierProvider((_) => Counter());
