import '../../domain/entities/workout_session.dart';
import '../../domain/interfaces/workout_repository.dart';

class InMemoryWorkoutRepository implements WorkoutRepository {
  final Map<int, WorkoutSession> _items = {};

  @override
  int nextId() {
    if (_items.isEmpty) {
      return 1;
    }
    return _items.keys.reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  List<WorkoutSession> getAll() => _items.values.toList();

  @override
  WorkoutSession? getById(int id) => _items[id];

  @override
  void save(WorkoutSession session) {
    _items[session.id] = session;
  }
}
