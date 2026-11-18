import '../domain/entities/workout_session.dart';
import '../domain/errors.dart';
import '../domain/interfaces/workout_repository.dart';

WorkoutSession? findCurrentWorkout(WorkoutRepository workouts) {
  for (final session in workouts.getAll()) {
    if (session.isInProgress) {
      return session;
    }
  }
  return null;
}

WorkoutSession requireCurrentWorkout(WorkoutRepository workouts) {
  final session = findCurrentWorkout(workouts);
  if (session == null) {
    throw NoActiveWorkoutError();
  }
  return session;
}
