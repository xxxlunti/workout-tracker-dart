import '../entities/workout_session.dart';

abstract class WorkoutRepository {
  int nextId();

  List<WorkoutSession> getAll();

  WorkoutSession? getById(int id);

  void save(WorkoutSession session);
}
