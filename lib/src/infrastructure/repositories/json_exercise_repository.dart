import 'dart:convert';
import 'dart:io';

import '../../domain/entities/exercise.dart';
import '../../domain/interfaces/exercise_repository.dart';
import 'json_mappers.dart';

class JsonExerciseRepository implements ExerciseRepository {
  JsonExerciseRepository(String path, {Iterable<Exercise> seed = const []})
      : _file = File(path) {
    if (!_file.existsSync()) {
      _file.parent.createSync(recursive: true);
      _write(seed.toList());
    }
  }

  final File _file;

  List<Exercise> _read() {
    final data = jsonDecode(_file.readAsStringSync()) as List<dynamic>;
    return data
        .map((e) => exerciseFromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _write(List<Exercise> items) {
    final encoder = JsonEncoder.withIndent('  ');
    _file.writeAsStringSync(encoder.convert(items.map(exerciseToJson).toList()));
  }

  @override
  int nextId() {
    final items = _read();
    if (items.isEmpty) {
      return 1;
    }
    return items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  List<Exercise> getAll() => _read();

  @override
  Exercise? getById(int id) {
    for (final exercise in _read()) {
      if (exercise.id == id) {
        return exercise;
      }
    }
    return null;
  }

  @override
  Exercise add(Exercise exercise) {
    final items = _read()..add(exercise);
    _write(items);
    return exercise;
  }

  @override
  bool delete(int id) {
    final items = _read();
    final remaining = items.where((e) => e.id != id).toList();
    if (remaining.length == items.length) {
      return false;
    }
    _write(remaining);
    return true;
  }
}
