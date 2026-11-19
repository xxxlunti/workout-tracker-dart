import 'dart:io';

import 'package:workout_tracker/src/application/use_cases/add_exercise.dart';
import 'package:workout_tracker/src/application/use_cases/add_exercise_to_workout.dart';
import 'package:workout_tracker/src/application/use_cases/get_workout_status.dart';
import 'package:workout_tracker/src/application/use_cases/list_exercises.dart';
import 'package:workout_tracker/src/application/use_cases/list_workout_history.dart';
import 'package:workout_tracker/src/application/use_cases/pause_workout.dart';
import 'package:workout_tracker/src/application/use_cases/resume_workout.dart';
import 'package:workout_tracker/src/application/use_cases/start_workout.dart';
import 'package:workout_tracker/src/application/use_cases/stop_workout.dart';
import 'package:workout_tracker/src/domain/interfaces/clock.dart';
import 'package:workout_tracker/src/infrastructure/repository_factory.dart';
import 'package:workout_tracker/src/infrastructure/settings.dart';
import 'package:workout_tracker/src/infrastructure/system_clock.dart';
import 'package:workout_tracker/src/presentation/cli/cli_app.dart';

void main() {
  final baseDir = Directory.current.path;
  final settings = Settings.load('$baseDir/appsettings.json');
  final repositories = createRepositories(settings, baseDir);
  final Clock clock = SystemClock();

  final app = CliApp(
    addExercise: AddExerciseUseCase(repositories.exercises),
    listExercises: ListExercisesUseCase(repositories.exercises),
    startWorkout: StartWorkoutUseCase(repositories.workouts, clock),
    pauseWorkout: PauseWorkoutUseCase(repositories.workouts, clock),
    resumeWorkout: ResumeWorkoutUseCase(repositories.workouts, clock),
    stopWorkout: StopWorkoutUseCase(repositories.workouts, clock),
    addExerciseToWorkout: AddExerciseToWorkoutUseCase(
      repositories.workouts,
      repositories.exercises,
      clock,
    ),
    workoutStatus: GetWorkoutStatusUseCase(repositories.workouts, clock),
    workoutHistory: ListWorkoutHistoryUseCase(repositories.workouts, clock),
  );
  app.run();
}
