import 'dart:convert';
import 'dart:io';

class Settings {
  const Settings({
    required this.storage,
    required this.exercisesFile,
    required this.workoutsFile,
  });

  factory Settings.load(String path) {
    final raw =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    return Settings(
      storage: raw['storage'] as String? ?? 'memory',
      exercisesFile: raw['exercisesFile'] as String? ?? 'data/exercises.json',
      workoutsFile: raw['workoutsFile'] as String? ?? 'data/workouts.json',
    );
  }

  final String storage;
  final String exercisesFile;
  final String workoutsFile;
}
