import 'dart:io';

import 'package:test/test.dart';
import 'package:workout_tracker/src/domain/entities/exercise.dart';
import 'package:workout_tracker/src/domain/entities/workout_session.dart';
import 'package:workout_tracker/src/infrastructure/repositories/in_memory_exercise_repository.dart';
import 'package:workout_tracker/src/infrastructure/repositories/in_memory_workout_repository.dart';
import 'package:workout_tracker/src/infrastructure/repositories/json_exercise_repository.dart';
import 'package:workout_tracker/src/infrastructure/repositories/json_workout_repository.dart';
import 'package:workout_tracker/src/infrastructure/repository_factory.dart';
import 'package:workout_tracker/src/infrastructure/seed.dart';
import 'package:workout_tracker/src/infrastructure/settings.dart';

void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('workout_tracker_test_');
  });

  tearDown(() {
    dir.deleteSync(recursive: true);
  });

  group('InMemory', () {
    test('репозиторій вправ', () {
      final repo = InMemoryExerciseRepository(defaultExercises());
      expect(repo.getAll().length, 5);
      expect(repo.nextId(), 6);
      repo.add(Exercise(id: 6, name: 'Планка', sets: 3, reps: 1));
      expect(repo.getById(6)!.name, 'Планка');
      expect(repo.delete(6), isTrue);
      expect(repo.delete(6), isFalse);
    });

    test('репозиторій тренувань', () {
      final repo = InMemoryWorkoutRepository();
      expect(repo.nextId(), 1);
      repo.save(WorkoutSession(id: 1));
      expect(repo.nextId(), 2);
      expect(repo.getById(1), isNotNull);
      expect(repo.getById(9), isNull);
    });
  });

  group('JSON', () {
    test('репозиторій вправ створює файл із початковими даними', () {
      final path = '${dir.path}/nested/exercises.json';
      final repo = JsonExerciseRepository(path, seed: defaultExercises());
      expect(File(path).existsSync(), isTrue);
      expect(repo.getAll().length, 5);
      expect(repo.getById(4)!.weightKg, 50);
      expect(repo.nextId(), 6);
    });

    test('репозиторій вправ: додавання, видалення, повторне відкриття', () {
      final path = '${dir.path}/exercises.json';
      final repo = JsonExerciseRepository(path, seed: defaultExercises());
      repo.add(Exercise(id: 6, name: 'Планка', sets: 3, reps: 1));
      expect(repo.delete(1), isTrue);
      expect(repo.delete(1), isFalse);
      final reopened = JsonExerciseRepository(path);
      expect(reopened.getAll().length, 5);
      expect(reopened.getById(6)!.name, 'Планка');
    });

    test('кирилиця зберігається у файлі як є', () {
      final path = '${dir.path}/exercises.json';
      JsonExerciseRepository(path, seed: defaultExercises());
      expect(File(path).readAsStringSync(), contains('Віджимання'));
    });

    test('порожній файл читається як порожній список', () {
      final exercisesPath = '${dir.path}/e.json';
      final workoutsPath = '${dir.path}/w.json';
      File(exercisesPath).writeAsStringSync('');
      File(workoutsPath).writeAsStringSync('  \n');
      expect(JsonExerciseRepository(exercisesPath).getAll(), isEmpty);
      expect(JsonExerciseRepository(exercisesPath).nextId(), 1);
      expect(JsonWorkoutRepository(workoutsPath).getAll(), isEmpty);
      expect(JsonWorkoutRepository(workoutsPath).nextId(), 1);
    });

    test('репозиторій тренувань зберігає стан і час', () {
      final path = '${dir.path}/workouts.json';
      final repo = JsonWorkoutRepository(path);
      final t0 = DateTime(2026, 11, 19, 10);
      final session = WorkoutSession(id: repo.nextId())
        ..start(t0)
        ..addExercise(Exercise(id: 1, name: 'Віджимання', sets: 3, reps: 15))
        ..pause(t0.add(Duration(minutes: 12)));
      repo.save(session);

      final loaded = JsonWorkoutRepository(path).getById(1)!;
      expect(loaded.status, WorkoutStatus.paused);
      expect(loaded.accumulated, Duration(minutes: 12));
      expect(loaded.exercises.single.name, 'Віджимання');

      loaded.resume(t0.add(Duration(minutes: 20)));
      repo.save(loaded);
      expect(repo.getAll().length, 1);
      expect(repo.getById(1)!.isActive, isTrue);
    });
  });

  group('Settings і фабрика', () {
    test('завантаження налаштувань та створення JSON-сховища', () {
      final settingsFile = File('${dir.path}/appsettings.json')
        ..writeAsStringSync(
            '{"storage": "json", "exercisesFile": "db/e.json", "workoutsFile": "db/w.json"}');
      final settings = Settings.load(settingsFile.path);
      expect(settings.storage, 'json');
      final repos = createRepositories(settings, dir.path);
      expect(repos.exercises, isA<JsonExerciseRepository>());
      expect(repos.workouts, isA<JsonWorkoutRepository>());
      expect(File('${dir.path}/db/e.json').existsSync(), isTrue);
      expect(File('${dir.path}/db/w.json').existsSync(), isTrue);
    });

    test('сховище в пам\'яті та невідомий тип', () {
      final memory = createRepositories(
          Settings(storage: 'memory', exercisesFile: 'x', workoutsFile: 'y'),
          dir.path);
      expect(memory.exercises, isA<InMemoryExerciseRepository>());
      expect(
          () => createRepositories(
              Settings(storage: 'sqlite', exercisesFile: 'x', workoutsFile: 'y'),
              dir.path),
          throwsArgumentError);
    });
  });
}
