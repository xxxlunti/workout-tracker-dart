import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout_session.dart';

Map<String, dynamic> exerciseToJson(Exercise exercise) => {
      'id': exercise.id,
      'name': exercise.name,
      'sets': exercise.sets,
      'reps': exercise.reps,
      'weightKg': exercise.weightKg,
    };

Exercise exerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: json['id'] as int,
      name: json['name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weightKg: (json['weightKg'] as num).toDouble(),
    );

Map<String, dynamic> sessionToJson(WorkoutSession session) => {
      'id': session.id,
      'status': session.status.name,
      'elapsedMs': session.accumulated.inMilliseconds,
      'startedAt': session.startedAt?.toIso8601String(),
      'resumedAt': session.resumedAt?.toIso8601String(),
      'exercises': session.exercises.map(exerciseToJson).toList(),
    };

WorkoutSession sessionFromJson(Map<String, dynamic> json) {
  final startedAt = json['startedAt'] as String?;
  final resumedAt = json['resumedAt'] as String?;
  return WorkoutSession.restore(
    id: json['id'] as int,
    status: WorkoutStatus.values.byName(json['status'] as String),
    elapsed: Duration(milliseconds: json['elapsedMs'] as int),
    startedAt: startedAt == null ? null : DateTime.parse(startedAt),
    resumedAt: resumedAt == null ? null : DateTime.parse(resumedAt),
    exercises: (json['exercises'] as List<dynamic>)
        .map((e) => exerciseFromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
