import 'package:hooks_riverpod/hooks_riverpod.dart';

final loadingStateProvider = StateProvider((_) => false);
final todoPageProvider = StateProvider((_) => 1);

class TodoRepository {
  TodoRepository();

  void fetch() async {
    //TODO: some fetch procedure
  }
}

final todoRepositoryProvider = Provider((_) => TodoRepository());
