import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stance_app/state.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppState.recordSession Verification', () {
    late AppState state;

    setUp(() {
      state = AppState();
    });

    test('Case 1: Full completion - meaningful and awarded', () async {
      final workoutId = 'test_workout';
      final scheduledSeconds = 32 * 60; // 32 min
      final actualSeconds = 32 * 60;

      await state.recordSession(
        workoutId: workoutId,
        actualTrainedSeconds: actualSeconds,
        scheduledSeconds: scheduledSeconds,
      );

      expect(state.workoutsCompleted, 1);
      expect(state.totalTrainingMinutes, 32);
      expect(state.xp, greaterThan(0));
      expect(state.currentStreak, 1);
      expect(state.completedToday.contains(workoutId), isTrue);
      expect(state.skillProgress[workoutId], closeTo(1.0, 0.01));
    });

    test('Case 2: Partial completion (60%) - meaningful and awarded', () async {
      final workoutId = 'test_workout_partial';
      final scheduledSeconds = 32 * 60;
      final actualSeconds = (32 * 60 * 0.6).toInt();

      await state.recordSession(
        workoutId: workoutId,
        actualTrainedSeconds: actualSeconds,
        scheduledSeconds: scheduledSeconds,
      );

      expect(state.workoutsCompleted, 1);
      expect(state.totalTrainingMinutes, (actualSeconds ~/ 60));
      expect(state.currentStreak, 1);
      expect(state.completedToday.contains(workoutId), isTrue);
      expect(state.skillProgress[workoutId], closeTo(0.6, 0.01));
    });

    test('Case 2b: Boundary completion (30%) - meaningful and awarded', () async {
      final workoutId = 'test_workout_boundary';
      final scheduledSeconds = 32 * 60;
      final actualSeconds = (32 * 60 * 0.3).toInt();

      await state.recordSession(
        workoutId: workoutId,
        actualTrainedSeconds: actualSeconds,
        scheduledSeconds: scheduledSeconds,
      );

      expect(state.workoutsCompleted, 1);
      expect(state.currentStreak, 1);
      expect(state.completedToday.contains(workoutId), isTrue);
    });

    test('Case 3: Heavy skip (< 30%) - NOT meaningful, NOT awarded', () async {
      final workoutId = 'test_workout_skipped';
      final scheduledSeconds = 32 * 60;
      final actualSeconds = (32 * 60 * 0.29).toInt(); // 29% completion

      await state.recordSession(
        workoutId: workoutId,
        actualTrainedSeconds: actualSeconds,
        scheduledSeconds: scheduledSeconds,
      );

      expect(state.workoutsCompleted, 0);
      expect(state.totalTrainingMinutes, 0);
      expect(state.xp, 0);
      expect(state.currentStreak, 0);
      expect(state.completedToday.contains(workoutId), isFalse);
      expect(state.skillProgress[workoutId], isNull);
    });

    test('Case 3b: Very low completion (5%) - NOT meaningful, NOT awarded', () async {
      final workoutId = 'test_workout_tiny';
      final scheduledSeconds = 32 * 60;
      final actualSeconds = (32 * 60 * 0.05).toInt(); // 5% completion

      await state.recordSession(
        workoutId: workoutId,
        actualTrainedSeconds: actualSeconds,
        scheduledSeconds: scheduledSeconds,
      );

      expect(state.workoutsCompleted, 0);
      expect(state.currentStreak, 0);
      expect(state.completedToday.contains(workoutId), isFalse);
    });

    test('Case 5: Duplicate completion on same day - no stat inflation', () async {
      final workoutId = 'test_workout_dup';
      final scheduledSeconds = 30 * 60;
      final actualSeconds = 30 * 60;

      // First completion
      await state.recordSession(
        workoutId: workoutId,
        actualTrainedSeconds: actualSeconds,
        scheduledSeconds: scheduledSeconds,
      );
      final firstXP = state.xp;
      final firstMinutes = state.totalTrainingMinutes;
      final firstCount = state.workoutsCompleted;
      final firstSkill = state.skillProgress[workoutId]!;

      // Second completion of same workout
      await state.recordSession(
        workoutId: workoutId,
        actualTrainedSeconds: actualSeconds,
        scheduledSeconds: scheduledSeconds,
      );

      expect(state.xp, firstXP, reason: 'XP should not increase on duplicate');
      expect(state.totalTrainingMinutes, firstMinutes, reason: 'Minutes should not inflate on duplicate');
      expect(state.workoutsCompleted, firstCount, reason: 'Workout count should not inflate on duplicate');
      expect(state.skillProgress[workoutId], firstSkill, reason: 'Skill progress should not inflate on duplicate');
    });
  });
}
