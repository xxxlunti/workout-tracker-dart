import '../errors.dart';
import 'exercise.dart';

enum WorkoutStatus { idle, active, paused, finished }

class WorkoutSession {
  WorkoutSession({required this.id, List<Exercise> exercises = const []})
      : _status = WorkoutStatus.idle,
        _elapsed = Duration.zero,
        _exercises = List<Exercise>.of(exercises);

  WorkoutSession.restore({
    required this.id,
    required WorkoutStatus status,
    required Duration elapsed,
    required List<Exercise> exercises,
    DateTime? startedAt,
    DateTime? resumedAt,
  })  : _status = status,
        _elapsed = elapsed,
        _startedAt = startedAt,
        _resumedAt = resumedAt,
        _exercises = List<Exercise>.of(exercises);

  final int id;
  final List<Exercise> _exercises;
  WorkoutStatus _status;
  Duration _elapsed;
  DateTime? _startedAt;
  DateTime? _resumedAt;

  WorkoutStatus get status => _status;
  bool get isActive => _status == WorkoutStatus.active;
  bool get isPaused => _status == WorkoutStatus.paused;
  bool get isFinished => _status == WorkoutStatus.finished;
  bool get isInProgress => isActive || isPaused;
  Duration get accumulated => _elapsed;
  DateTime? get startedAt => _startedAt;
  DateTime? get resumedAt => _resumedAt;
  List<Exercise> get exercises => _exercises;

  Duration elapsedAt(DateTime now) {
    final resumedAt = _resumedAt;
    if (_status == WorkoutStatus.active && resumedAt != null) {
      return _elapsed + now.difference(resumedAt);
    }
    return _elapsed;
  }

  void start(DateTime now) {
    if (_status != WorkoutStatus.idle) {
      throw InvalidWorkoutStateError('Тренування вже розпочато');
    }
    _status = WorkoutStatus.active;
    _startedAt = now;
    _resumedAt = now;
  }

  void pause(DateTime now) {
    if (!isActive) {
      throw InvalidWorkoutStateError(
        'Паузу можна поставити лише для активного тренування',
      );
    }
    _elapsed = elapsedAt(now);
    _resumedAt = null;
    _status = WorkoutStatus.paused;
  }

  void resume(DateTime now) {
    if (!isPaused) {
      throw InvalidWorkoutStateError(
        'Продовжити можна лише тренування, що на паузі',
      );
    }
    _resumedAt = now;
    _status = WorkoutStatus.active;
  }

  void stop(DateTime now) {
    if (!isInProgress) {
      throw InvalidWorkoutStateError('Немає тренування, яке можна завершити');
    }
    _elapsed = elapsedAt(now);
    _resumedAt = null;
    _status = WorkoutStatus.finished;
  }

  void addExercise(Exercise exercise) {
    if (isFinished) {
      throw InvalidWorkoutStateError(
        'Не можна додати вправу до завершеного тренування',
      );
    }
    _exercises.add(exercise);
  }
}
