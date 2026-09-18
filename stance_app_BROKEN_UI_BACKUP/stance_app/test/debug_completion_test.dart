import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stance_app/state.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('Forensic: Trace AppState.recordSession mutations', () async {
    final state = AppState();
    
    // Simulation: 32 min workout, 32 min completed (100%)
    final workoutId = 'test_workout';
    final scheduledSeconds = 32 * 60;
    final actualSeconds = 32 * 60;

    print('\n--- BEFORE recordSession ---');
    print('XP: ${state.xp}');
    print('Workouts: ${state.workoutsCompleted}');
    print('Minutes: ${state.totalTrainingMinutes}');
    print('Streak: ${state.currentStreak}');

    // We call the async method but do NOT await it yet
    final future = state.recordSession(
      workoutId: workoutId,
      actualTrainedSeconds: actualSeconds,
      scheduledSeconds: scheduledSeconds,
    );

    print('\n--- IMMEDIATELY AFTER call (not awaited) ---');
    print('XP: ${state.xp}');
    print('Workouts: ${state.workoutsCompleted}');
    print('Minutes: ${state.totalTrainingMinutes}');
    print('Streak: ${state.currentStreak}');

    await future;

    print('\n--- AFTER awaiting recordSession ---');
    print('XP: ${state.xp}');
    print('Workouts: ${state.workoutsCompleted}');
    print('Minutes: ${state.totalTrainingMinutes}');
    print('Streak: ${state.currentStreak}');
  });
}
