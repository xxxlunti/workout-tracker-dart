import 'dart:io';

import '../../application/use_cases/add_exercise.dart';
import '../../application/use_cases/add_exercise_to_workout.dart';
import '../../application/use_cases/get_workout_status.dart';
import '../../application/use_cases/list_exercises.dart';
import '../../application/use_cases/list_workout_history.dart';
import '../../application/use_cases/pause_workout.dart';
import '../../application/use_cases/resume_workout.dart';
import '../../application/use_cases/start_workout.dart';
import '../../application/use_cases/stop_workout.dart';
import '../../application/workout_status_view.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/errors.dart';

const String menuText = '''

=== Трекер тренувань ===
1. Каталог вправ
2. Додати вправу до каталогу
3. Почати тренування
4. Пауза
5. Продовжити
6. Додати вправу до тренування
7. Статус тренування
8. Завершити тренування
9. Історія тренувань
0. Вихід
''';

class CliApp {
  CliApp({
    required this.addExercise,
    required this.listExercises,
    required this.startWorkout,
    required this.pauseWorkout,
    required this.resumeWorkout,
    required this.stopWorkout,
    required this.addExerciseToWorkout,
    required this.workoutStatus,
    required this.workoutHistory,
    String? Function()? readLine,
    void Function(String)? write,
  })  : _readLine = readLine ?? (() => stdin.readLineSync()),
        _write = write ?? print;

  final AddExerciseUseCase addExercise;
  final ListExercisesUseCase listExercises;
  final StartWorkoutUseCase startWorkout;
  final PauseWorkoutUseCase pauseWorkout;
  final ResumeWorkoutUseCase resumeWorkout;
  final StopWorkoutUseCase stopWorkout;
  final AddExerciseToWorkoutUseCase addExerciseToWorkout;
  final GetWorkoutStatusUseCase workoutStatus;
  final ListWorkoutHistoryUseCase workoutHistory;

  final String? Function() _readLine;
  final void Function(String) _write;

  late final Map<String, void Function()> _handlers = {
    '1': _showExercises,
    '2': _addExercise,
    '3': _start,
    '4': _pause,
    '5': _resume,
    '6': _addToWorkout,
    '7': _showStatus,
    '8': _stop,
    '9': _showHistory,
  };

  void run() {
    while (true) {
      _write(menuText);
      _write('Оберіть пункт:');
      final choice = _readLine();
      if (choice == null || choice.trim() == '0') {
        _write('До побачення!');
        return;
      }
      final handler = _handlers[choice.trim()];
      if (handler == null) {
        _write('Невідомий пункт меню');
        continue;
      }
      try {
        handler();
      } on DomainError catch (error) {
        _write('Помилка: ${error.message}');
      }
    }
  }

  String _ask(String prompt) {
    _write(prompt);
    return (_readLine() ?? '').trim();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatExercise(Exercise exercise) {
    final weight =
        exercise.isBodyweight ? 'власна вага' : '${exercise.weightKg} кг';
    return '[${exercise.id}] ${exercise.name} — '
        '${exercise.sets}×${exercise.reps}, $weight';
  }

  String _statusLabel(WorkoutStatus status) {
    switch (status) {
      case WorkoutStatus.idle:
        return 'не розпочато';
      case WorkoutStatus.active:
        return 'триває';
      case WorkoutStatus.paused:
        return 'на паузі';
      case WorkoutStatus.finished:
        return 'завершено';
    }
  }

  void _printView(WorkoutStatusView view) {
    _write('Тренування #${view.id}: ${_statusLabel(view.status)}, '
        'час ${_formatDuration(view.elapsed)}');
    if (view.exercises.isEmpty) {
      _write('Вправ у тренуванні поки немає');
      return;
    }
    for (final exercise in view.exercises) {
      _write('  ${_formatExercise(exercise)}');
    }
  }

  void _showExercises() {
    final query = _ask('Пошук (Enter — показати всі):');
    final items = listExercises.execute(query: query);
    if (items.isEmpty) {
      _write('Вправ за вашим запитом не знайдено');
      return;
    }
    for (final exercise in items) {
      _write(_formatExercise(exercise));
    }
  }

  void _addExercise() {
    final name = _ask('Назва вправи:');
    final sets = int.parse(_ask('Кількість підходів:'));
    final reps = int.parse(_ask('Кількість повторень:'));
    final weightText = _ask('Вага, кг (Enter — власна вага):');
    final weight =
        weightText.isEmpty ? 0.0 : double.parse(weightText.replaceAll(',', '.'));
    final exercise = addExercise.execute(
      name: name,
      sets: sets,
      reps: reps,
      weightKg: weight,
    );
    _write('Додано: ${_formatExercise(exercise)}');
  }

  void _start() {
    final view = startWorkout.execute();
    _write('Тренування #${view.id} розпочато');
  }

  void _pause() {
    final view = pauseWorkout.execute();
    _write('Пауза, час ${_formatDuration(view.elapsed)}');
  }

  void _resume() {
    resumeWorkout.execute();
    _write('Тренування продовжено');
  }

  void _addToWorkout() {
    final id = int.parse(_ask('ID вправи:'));
    addExerciseToWorkout.execute(id);
    _write('Вправу додано до тренування');
  }

  void _showStatus() {
    final view = workoutStatus.execute();
    if (view == null) {
      _write('Немає активного тренування');
      return;
    }
    _printView(view);
  }

  void _stop() {
    final view = stopWorkout.execute();
    _write('Тренування #${view.id} завершено. '
        'Тривалість ${_formatDuration(view.elapsed)}, вправ: ${view.exercises.length}');
  }

  void _showHistory() {
    final items = workoutHistory.execute();
    if (items.isEmpty) {
      _write('Історія порожня');
      return;
    }
    for (final view in items) {
      _printView(view);
    }
  }
}
