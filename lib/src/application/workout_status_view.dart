import '../domain/entities/exercise.dart';
import '../domain/entities/workout_session.dart';

class WorkoutStatusView {
  const WorkoutStatusView({
    required this.id,
    required this.status,
    required this.elapsed,
    required this.exercises,
  });

  factory WorkoutStatusView.fromSession(WorkoutSession session, DateTime now) {
    return WorkoutStatusView(
      id: session.id,
      status: session.status,
      elapsed: session.elapsedAt(now),
      exercises: session.exercises,
    );
  }

  final int id;
  final WorkoutStatus status;
  final Duration elapsed;
  final List<Exercise> exercises;
}
