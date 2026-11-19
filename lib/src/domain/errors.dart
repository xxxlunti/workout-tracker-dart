class DomainError implements Exception {
  DomainError(this.message);

  final String message;

  @override
  String toString() => message;
}

class ValidationError extends DomainError {
  ValidationError(super.message);
}

class ExerciseNotFoundError extends DomainError {
  ExerciseNotFoundError(int id) : super('Вправу з id=$id не знайдено');
}

class NoActiveWorkoutError extends DomainError {
  NoActiveWorkoutError() : super('Немає активного тренування');
}

class InvalidWorkoutStateError extends DomainError {
  InvalidWorkoutStateError(super.message);
}
