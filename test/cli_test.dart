import 'package:test/test.dart';
import 'package:workout_tracker/src/application/use_cases/add_exercise.dart';
import 'package:workout_tracker/src/application/use_cases/add_exercise_to_workout.dart';
import 'package:workout_tracker/src/application/use_cases/get_workout_status.dart';
import 'package:workout_tracker/src/application/use_cases/list_exercises.dart';
import 'package:workout_tracker/src/application/use_cases/list_workout_history.dart';
import 'package:workout_tracker/src/application/use_cases/pause_workout.dart';
import 'package:workout_tracker/src/application/use_cases/resume_workout.dart';
import 'package:workout_tracker/src/application/use_cases/start_workout.dart';
import 'package:workout_tracker/src/application/use_cases/stop_workout.dart';
import 'package:workout_tracker/src/infrastructure/repositories/in_memory_exercise_repository.dart';
import 'package:workout_tracker/src/infrastructure/repositories/in_memory_workout_repository.dart';
import 'package:workout_tracker/src/infrastructure/seed.dart';
import 'package:workout_tracker/src/presentation/cli/cli_app.dart';

import 'fakes.dart';

String runCli(List<String> inputs) {
  final exercises = InMemoryExerciseRepository(defaultExercises());
  final workouts = InMemoryWorkoutRepository();
  final clock = FakeClock(DateTime(2026, 11, 19, 10));
  final iterator = inputs.iterator;
  final lines = <String>[];

  CliApp(
    addExercise: AddExerciseUseCase(exercises),
    listExercises: ListExercisesUseCase(exercises),
    startWorkout: StartWorkoutUseCase(workouts, clock),
    pauseWorkout: PauseWorkoutUseCase(workouts, clock),
    resumeWorkout: ResumeWorkoutUseCase(workouts, clock),
    stopWorkout: StopWorkoutUseCase(workouts, clock),
    addExerciseToWorkout:
        AddExerciseToWorkoutUseCase(workouts, exercises, clock),
    workoutStatus: GetWorkoutStatusUseCase(workouts, clock),
    workoutHistory: ListWorkoutHistoryUseCase(workouts, clock),
    readLine: () => iterator.moveNext() ? iterator.current : null,
    write: lines.add,
  ).run();

  return lines.join('\n');
}

void main() {
  test('каталог вправ', () {
    final out = runCli(['1', '', '0']);
    expect(out, contains('Віджимання'));
    expect(out, contains('власна вага'));
  });

  test('пошук у каталозі', () {
    final out = runCli(['1', 'жим', '0']);
    expect(out, contains('Жим лежачи'));
    expect(out, isNot(contains('Підтягування')));
  });

  test('додавання вправи до каталогу', () {
    final out = runCli(['2', 'Планка', '3', '1', '', '0']);
    expect(out, contains('Додано: [6] Планка'));
  });

  test('повний сценарій тренування', () {
    final out = runCli(['3', '6', '1', '4', '5', '7', '8', '9', '0']);
    expect(out, contains('Тренування #1 розпочато'));
    expect(out, contains('Вправу додано до тренування'));
    expect(out, contains('Пауза'));
    expect(out, contains('Тренування продовжено'));
    expect(out, contains('Тренування #1: триває'));
    expect(out, contains('Тренування #1 завершено'));
    expect(out, contains('Тренування #1: завершено'));
  });

  test('помилки предметної області виводяться без аварії', () {
    final out = runCli(['4', '3', '3', '0']);
    expect(out, contains('Помилка: Немає активного тренування'));
    expect(out, contains('Помилка: Є незавершене тренування'));
  });

  test('некоректне введення не призводить до аварії', () {
    final out = runCli(['2', 'Планка', 'abc', '6', 'не-число', '0']);
    expect(out.split('некоректне значення').length - 1, 2);
    expect(out, contains('До побачення!'));
  });

  test('невідомий пункт меню', () {
    expect(runCli(['42', '0']), contains('Невідомий пункт меню'));
  });
}
