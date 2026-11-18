import '../../domain/entities/exercise.dart';
import '../../domain/interfaces/exercise_repository.dart';

class InMemoryExerciseRepository implements ExerciseRepository {
  InMemoryExerciseRepository([Iterable<Exercise> exercises = const []]) {
    for (final exercise in exercises) {
      _items[exercise.id] = exercise;
    }
  }

  final Map<int, Exercise> _items = {};

  @override
  int nextId() {
    if (_items.isEmpty) {
      return 1;
    }
    return _items.keys.reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  List<Exercise> getAll() => _items.values.toList();

  @override
  Exercise? getById(int id) => _items[id];

  @override
  Exercise add(Exercise exercise) {
    _items[exercise.id] = exercise;
    return exercise;
  }

  @override
  bool delete(int id) => _items.remove(id) != null;
}
