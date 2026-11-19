import 'package:workout_tracker/src/domain/entities/exercise.dart';
import 'package:workout_tracker/src/domain/entities/workout_session.dart';
import 'package:workout_tracker/src/domain/interfaces/clock.dart';
import 'package:workout_tracker/src/domain/interfaces/exercise_repository.dart';
import 'package:workout_tracker/src/domain/interfaces/workout_repository.dart';

class FakeClock implements Clock {
  FakeClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;

  void advance(Duration duration) {
    current = current.add(duration);
  }
}

class FakeExerciseRepository implements ExerciseRepository {
  FakeExerciseRepository([Iterable<Exercise> exercises = const []]) {
    for (final e in exercises) {
      _items[e.id] = e;
    }
  }

  final Map<int, Exercise> _items = {};

  @override
  int nextId() => _items.isEmpty ? 1 : _items.keys.reduce((a, b) => a > b ? a : b) + 1;

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

class FakeWorkoutRepository implements WorkoutRepository {
  final Map<int, WorkoutSession> _items = {};

  @override
  int nextId() => _items.isEmpty ? 1 : _items.keys.reduce((a, b) => a > b ? a : b) + 1;

  @override
  List<WorkoutSession> getAll() => _items.values.toList();

  @override
  WorkoutSession? getById(int id) => _items[id];

  @override
  void save(WorkoutSession session) {
    _items[session.id] = session;
  }
}

List<Exercise> sampleExercises() => [
      Exercise(id: 1, name: 'Віджимання', sets: 3, reps: 15),
      Exercise(id: 2, name: 'Присідання зі штангою', sets: 4, reps: 8, weightKg: 60),
      Exercise(id: 3, name: 'Підтягування', sets: 3, reps: 8),
    ];
