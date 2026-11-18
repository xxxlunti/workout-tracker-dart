import '../domain/interfaces/clock.dart';

class SystemClock implements Clock {
  @override
  DateTime now() => DateTime.now();
}
