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
import 'package:workout_tracker/src/domain/entities/workout_session.dart';
import 'package:workout_tracker/src/domain/errors.dart';

import 'fakes.dart';

void main() {
  late FakeExerciseRepository exercises;
  late FakeWorkoutRepository workouts;
  late FakeClock clock;

  setUp(() {
    exercises = FakeExerciseRepository(sampleExercises());
    workouts = FakeWorkoutRepository();
    clock = FakeClock(DateTime(2026, 11, 19, 10));
  });

  test('AddExerciseUseCase призначає наступний id', () {
    final exercise = AddExerciseUseCase(exercises)
        .execute(name: ' Станова тяга ', sets: 3, reps: 5, weightKg: 80);
    expect(exercise.id, 4);
    expect(exercise.name, 'Станова тяга');
    expect(exercises.getById(4), isNotNull);
  });

  test('ListExercisesUseCase сортує та шукає за назвою', () {
    final useCase = ListExercisesUseCase(exercises);
    expect(useCase.execute().map((e) => e.id), [1, 3, 2]);
    expect(useCase.execute(query: 'присід').map((e) => e.id), [2]);
    expect(useCase.execute(query: 'zzz'), isEmpty);
  });

  test('повний цикл: start, pause, resume, stop', () {
    final start = StartWorkoutUseCase(workouts, clock).execute();
    expect(start.status, WorkoutStatus.active);

    clock.advance(Duration(minutes: 10));
    final paused = PauseWorkoutUseCase(workouts, clock).execute();
    expect(paused.status, WorkoutStatus.paused);
    expect(paused.elapsed, Duration(minutes: 10));

    clock.advance(Duration(minutes: 30));
    expect(GetWorkoutStatusUseCase(workouts, clock).execute()!.elapsed,
        Duration(minutes: 10));

    ResumeWorkoutUseCase(workouts, clock).execute();
    clock.advance(Duration(minutes: 5));
    final stopped = StopWorkoutUseCase(workouts, clock).execute();
    expect(stopped.status, WorkoutStatus.finished);
    expect(stopped.elapsed, Duration(minutes: 15));
    expect(GetWorkoutStatusUseCase(workouts, clock).execute(), isNull);
  });

  test('керування без активного тренування', () {
    expect(() => PauseWorkoutUseCase(workouts, clock).execute(),
        throwsA(isA<NoActiveWorkoutError>()));
    expect(() => StopWorkoutUseCase(workouts, clock).execute(),
        throwsA(isA<NoActiveWorkoutError>()));
  });

  test('додавання вправи до тренування', () {
    StartWorkoutUseCase(workouts, clock).execute();
    final view = AddExerciseToWorkoutUseCase(workouts, exercises, clock)
        .execute(2);
    expect(view.exercises.map((e) => e.name), ['Присідання зі штангою']);
    expect(
        () => AddExerciseToWorkoutUseCase(workouts, exercises, clock).execute(99),
        throwsA(isA<ExerciseNotFoundError>()));
  });

  test('історія містить лише завершені тренування', () {
    StartWorkoutUseCase(workouts, clock).execute();
    clock.advance(Duration(minutes: 20));
    StopWorkoutUseCase(workouts, clock).execute();
    StartWorkoutUseCase(workouts, clock).execute();
    final history = ListWorkoutHistoryUseCase(workouts, clock).execute();
    expect(history.length, 1);
    expect(history.first.elapsed, Duration(minutes: 20));
  });
}
