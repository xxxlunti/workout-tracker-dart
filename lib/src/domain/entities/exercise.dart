import '../errors.dart';

class Exercise {
  Exercise({
    required this.id,
    required String name,
    required this.sets,
    required this.reps,
    this.weightKg = 0,
  }) : name = name.trim() {
    if (this.name.isEmpty) {
      throw ValidationError('Назва вправи не може бути порожньою');
    }
    if (sets <= 0) {
      throw ValidationError('Кількість підходів має бути більшою за нуль');
    }
    if (reps <= 0) {
      throw ValidationError('Кількість повторень має бути більшою за нуль');
    }
    if (weightKg < 0) {
      throw ValidationError('Вага не може бути від\'ємною');
    }
  }

  final int id;
  final String name;
  final int sets;
  final int reps;
  final double weightKg;

  bool get isBodyweight => weightKg == 0;

  double get totalVolumeKg => sets * reps * weightKg;
}
