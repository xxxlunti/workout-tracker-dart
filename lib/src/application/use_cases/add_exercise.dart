import '../../domain/entities/exercise.dart';
import '../../domain/interfaces/exercise_repository.dart';

class AddExerciseUseCase {
  AddExerciseUseCase(this._exercises);

  final ExerciseRepository _exercises;

  Exercise execute({
    required String name,
    required int sets,
    required int reps,
    double weightKg = 0,
  }) {
    final exercise = Exercise(
      id: _exercises.nextId(),
      name: name,
      sets: sets,
      reps: reps,
      weightKg: weightKg,
    );
    return _exercises.add(exercise);
  }
}
