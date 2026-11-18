import 'dart:convert';
import 'dart:io';

import '../../domain/entities/workout_session.dart';
import '../../domain/interfaces/workout_repository.dart';
import 'json_mappers.dart';

class JsonWorkoutRepository implements WorkoutRepository {
  JsonWorkoutRepository(String path) : _file = File(path) {
    if (!_file.existsSync()) {
      _file.parent.createSync(recursive: true);
      _write(<WorkoutSession>[]);
    }
  }

  final File _file;

  List<WorkoutSession> _read() {
    final data = jsonDecode(_file.readAsStringSync()) as List<dynamic>;
    return data
        .map((e) => sessionFromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _write(List<WorkoutSession> items) {
    final encoder = JsonEncoder.withIndent('  ');
    _file.writeAsStringSync(encoder.convert(items.map(sessionToJson).toList()));
  }

  @override
  int nextId() {
    final items = _read();
    if (items.isEmpty) {
      return 1;
    }
    return items.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  List<WorkoutSession> getAll() => _read();

  @override
  WorkoutSession? getById(int id) {
    for (final session in _read()) {
      if (session.id == id) {
        return session;
      }
    }
    return null;
  }

  @override
  void save(WorkoutSession session) {
    final items = _read();
    final index = items.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      items[index] = session;
    } else {
      items.add(session);
    }
    _write(items);
  }
}
