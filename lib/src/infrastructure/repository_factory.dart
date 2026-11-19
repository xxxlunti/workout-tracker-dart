import '../domain/interfaces/exercise_repository.dart';
import '../domain/interfaces/workout_repository.dart';
import 'repositories/in_memory_exercise_repository.dart';
import 'repositories/in_memory_workout_repository.dart';
import 'repositories/json_exercise_repository.dart';
import 'repositories/json_workout_repository.dart';
import 'seed.dart';
import 'settings.dart';

class Repositories {
  const Repositories({required this.exercises, required this.workouts});

  final ExerciseRepository exercises;
  final WorkoutRepository workouts;
}

Repositories createRepositories(Settings settings, String baseDir) {
  switch (settings.storage) {
    case 'json':
      return Repositories(
        exercises: JsonExerciseRepository(
          '$baseDir/${settings.exercisesFile}',
          seed: defaultExercises(),
        ),
        workouts: JsonWorkoutRepository('$baseDir/${settings.workoutsFile}'),
      );
    case 'memory':
      return Repositories(
        exercises: InMemoryExerciseRepository(defaultExercises()),
        workouts: InMemoryWorkoutRepository(),
      );
    default:
      throw ArgumentError('Невідомий тип сховища: ${settings.storage}');
  }
}
