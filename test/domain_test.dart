import 'package:test/test.dart';
import 'package:workout_tracker/src/domain/entities/exercise.dart';
import 'package:workout_tracker/src/domain/entities/workout_session.dart';
import 'package:workout_tracker/src/domain/errors.dart';

Exercise sampleExercise() =>
    Exercise(id: 1, name: 'Жим лежачи', sets: 4, reps: 10, weightKg: 50);

void main() {
  final t0 = DateTime(2026, 11, 19, 10);

  group('Exercise', () {
    test('обрізає назву та рахує обсяг', () {
      final exercise =
          Exercise(id: 1, name: '  Жим  ', sets: 4, reps: 10, weightKg: 50);
      expect(exercise.name, 'Жим');
      expect(exercise.totalVolumeKg, 2000);
      expect(exercise.isBodyweight, isFalse);
    });

    test('вправа з власною вагою', () {
      expect(Exercise(id: 1, name: 'Віджимання', sets: 3, reps: 15).isBodyweight,
          isTrue);
    });

    test('валідація', () {
      expect(() => Exercise(id: 1, name: ' ', sets: 1, reps: 1),
          throwsA(isA<ValidationError>()));
      expect(() => Exercise(id: 1, name: 'A', sets: 0, reps: 1),
          throwsA(isA<ValidationError>()));
      expect(() => Exercise(id: 1, name: 'A', sets: 1, reps: 0),
          throwsA(isA<ValidationError>()));
      expect(() => Exercise(id: 1, name: 'A', sets: 1, reps: 1, weightKg: -1),
          throwsA(isA<ValidationError>()));
    });
  });

  group('WorkoutSession', () {
    test('start, pause, resume, stop накопичують час', () {
      final session = WorkoutSession(id: 1);
      expect(session.status, WorkoutStatus.idle);

      session.start(t0);
      expect(session.isActive, isTrue);
      expect(session.elapsedAt(t0.add(Duration(minutes: 5))),
          Duration(minutes: 5));

      session.pause(t0.add(Duration(minutes: 10)));
      expect(session.status, WorkoutStatus.paused);
      expect(session.elapsedAt(t0.add(Duration(minutes: 30))),
          Duration(minutes: 10));

      session.resume(t0.add(Duration(minutes: 40)));
      expect(session.isActive, isTrue);

      session.stop(t0.add(Duration(minutes: 45)));
      expect(session.isFinished, isTrue);
      expect(session.elapsedAt(t0.add(Duration(hours: 5))),
          Duration(minutes: 15));
    });

    test('стоп із паузи зберігає накопичений час', () {
      final session = WorkoutSession(id: 1)
        ..start(t0)
        ..pause(t0.add(Duration(minutes: 7)));
      session.stop(t0.add(Duration(hours: 1)));
      expect(session.accumulated, Duration(minutes: 7));
    });

    test('список вправ назовні не можна змінити в обхід addExercise', () {
      final session = WorkoutSession(id: 1)..start(t0);
      expect(() => session.exercises.add(sampleExercise()),
          throwsUnsupportedError);
      expect(session.exercises, isEmpty);
    });

    test('недопустимі переходи станів', () {
      final session = WorkoutSession(id: 1);
      expect(() => session.pause(t0), throwsA(isA<InvalidWorkoutStateError>()));
      expect(() => session.resume(t0), throwsA(isA<InvalidWorkoutStateError>()));
      expect(() => session.stop(t0), throwsA(isA<InvalidWorkoutStateError>()));
      session.start(t0);
      expect(() => session.start(t0), throwsA(isA<InvalidWorkoutStateError>()));
      expect(() => session.resume(t0), throwsA(isA<InvalidWorkoutStateError>()));
    });

    test('вправи додаються до незавершеного тренування', () {
      final session = WorkoutSession(id: 1)..start(t0);
      session.addExercise(sampleExercise());
      expect(session.exercises.length, 1);
      session.stop(t0.add(Duration(minutes: 1)));
      expect(() => session.addExercise(sampleExercise()),
          throwsA(isA<InvalidWorkoutStateError>()));
    });
  });
}
