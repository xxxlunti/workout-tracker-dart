import '../../domain/entities/exercise.dart';
import '../../domain/interfaces/exercise_repository.dart';

class ListExercisesUseCase {
  ListExercisesUseCase(this._exercises);

  final ExerciseRepository _exercises;

  List<Exercise> execute({String query = ''}) {
    final needle = query.trim().toLowerCase();
    final result = _exercises
        .getAll()
        .where((e) => needle.isEmpty || e.name.toLowerCase().contains(needle))
        .toList();
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }
}
