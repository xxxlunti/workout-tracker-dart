import '../../domain/entities/workout_session.dart';
import '../../domain/interfaces/clock.dart';
import '../../domain/interfaces/workout_repository.dart';
import '../workout_status_view.dart';

class StartWorkoutUseCase {
  StartWorkoutUseCase(this._workouts, this._clock);

  final WorkoutRepository _workouts;
  final Clock _clock;

  WorkoutStatusView execute() {
    final now = _clock.now();
    final session = WorkoutSession(id: _workouts.nextId());
    session.start(now);
    _workouts.save(session);
    return WorkoutStatusView.fromSession(session, now);
  }
}
