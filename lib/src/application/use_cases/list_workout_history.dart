import '../../domain/interfaces/clock.dart';
import '../../domain/interfaces/workout_repository.dart';
import '../workout_status_view.dart';

class ListWorkoutHistoryUseCase {
  ListWorkoutHistoryUseCase(this._workouts, this._clock);

  final WorkoutRepository _workouts;
  final Clock _clock;

  List<WorkoutStatusView> execute() {
    final now = _clock.now();
    return _workouts
        .getAll()
        .where((s) => s.isFinished)
        .map((s) => WorkoutStatusView.fromSession(s, now))
        .toList();
  }
}
