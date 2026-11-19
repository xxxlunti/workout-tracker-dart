import '../entities/exercise.dart';

abstract class ExerciseRepository {
  int nextId();

  List<Exercise> getAll();

  Exercise? getById(int id);

  Exercise add(Exercise exercise);

  bool delete(int id);
}
