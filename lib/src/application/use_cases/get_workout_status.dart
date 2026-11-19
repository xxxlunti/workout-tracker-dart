import '../../domain/interfaces/clock.dart';
import '../../domain/interfaces/workout_repository.dart';
import '../current_workout.dart';
import '../workout_status_view.dart';

class GetWorkoutStatusUseCase {
  GetWorkoutStatusUseCase(this._workouts, this._clock);

  final WorkoutRepository _workouts;
  final Clock _clock;

  WorkoutStatusView? execute() {
    final session = findCurrentWorkout(_workouts);
    if (session == null) {
      return null;
    }
    return WorkoutStatusView.fromSession(session, _clock.now());
  }
}
