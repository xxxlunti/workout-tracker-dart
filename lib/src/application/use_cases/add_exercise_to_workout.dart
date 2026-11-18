import '../../domain/errors.dart';
import '../../domain/interfaces/clock.dart';
import '../../domain/interfaces/exercise_repository.dart';
import '../../domain/interfaces/workout_repository.dart';
import '../current_workout.dart';
import '../workout_status_view.dart';

class AddExerciseToWorkoutUseCase {
  AddExerciseToWorkoutUseCase(this._workouts, this._exercises, this._clock);

  final WorkoutRepository _workouts;
  final ExerciseRepository _exercises;
  final Clock _clock;

  WorkoutStatusView execute(int exerciseId) {
    final session = requireCurrentWorkout(_workouts);
    final exercise = _exercises.getById(exerciseId);
    if (exercise == null) {
      throw ExerciseNotFoundError(exerciseId);
    }
    session.addExercise(exercise);
    _workouts.save(session);
    return WorkoutStatusView.fromSession(session, _clock.now());
  }
}
