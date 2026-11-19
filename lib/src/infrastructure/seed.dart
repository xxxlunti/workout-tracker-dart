import '../domain/entities/exercise.dart';

List<Exercise> defaultExercises() => [
      Exercise(id: 1, name: 'Віджимання', sets: 3, reps: 15),
      Exercise(id: 2, name: 'Присідання зі штангою', sets: 4, reps: 8, weightKg: 60),
      Exercise(id: 3, name: 'Підтягування', sets: 3, reps: 8),
      Exercise(id: 4, name: 'Жим лежачи', sets: 4, reps: 10, weightKg: 50),
      Exercise(id: 5, name: 'Станова тяга', sets: 3, reps: 5, weightKg: 80),
    ];
