import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'todo.freezed.dart';

@freezed
abstract class Todo with _$Todo {
  const factory Todo({
    @required String id,
    @Default('') String description,
    @Default(false) bool completed,
  }) = _Todo;
}
