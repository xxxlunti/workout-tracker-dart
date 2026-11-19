import '../../domain/interfaces/clock.dart';
import '../../domain/interfaces/workout_repository.dart';
import '../current_workout.dart';
import '../workout_status_view.dart';

class ResumeWorkoutUseCase {
  ResumeWorkoutUseCase(this._workouts, this._clock);

  final WorkoutRepository _workouts;
  final Clock _clock;

  WorkoutStatusView execute() {
    final now = _clock.now();
    final session = requireCurrentWorkout(_workouts);
    session.resume(now);
    _workouts.save(session);
    return WorkoutStatusView.fromSession(session, now);
  }
}
