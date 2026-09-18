import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stance_app/state.dart';
import 'package:stance_app/models/models.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Achievements Logic', () {
    test('Session milestones unlock correctly', () async {
      final state = AppState();
      
      // Complete 1 workout
      await state.recordSession(workoutId: 'w1', actualTrainedSeconds: 600, scheduledSeconds: 600);
      expect(state.unlockedAchievements.contains('session_1'), isTrue);
      expect(state.unlockedAchievements.contains('session_5'), isFalse);

      // Complete up to 5 total
      for (int i = 2; i <= 5; i++) {
        await state.recordSession(workoutId: 'w$i', actualTrainedSeconds: 600, scheduledSeconds: 600);
      }
      expect(state.unlockedAchievements.contains('session_5'), isTrue);
      expect(state.unlockedAchievements.contains('session_10'), isFalse);
    });

    test('Streak milestones unlock correctly', () async {
      final state = AppState();
      
      // Simulate 7 day streak
      // We have to manipulate lastTrainingDate and currentStreak because recordSession 
      // depends on DateTime.now()
      state.currentStreak = 7;
      // Manually trigger check as it's usually called in _notify()
      // Since we can't call private _checkAchievements, we use a method that triggers it
      await state.markTechniqueLearned('some_tech'); 

      expect(state.unlockedAchievements.contains('streak_7'), isTrue);
    });

    test('Training time milestones unlock correctly', () async {
      final state = AppState();
      
      // 5 hours = 300 minutes
      await state.recordSession(workoutId: 'long_w', actualTrainedSeconds: 300 * 60, scheduledSeconds: 300 * 60);
      expect(state.unlockedAchievements.contains('hours_5'), isTrue);
    });

    test('Combo achievements unlock correctly', () async {
      final state = AppState();
      
      // First combo
      await state.addCombo(Combo(id: 'c1', name: 'C1', strikes: ['Jab'], createdAt: DateTime.now()));
      expect(state.unlockedAchievements.contains('combo_creator'), isTrue);

      // Up to 10 combos
      for (int i = 2; i <= 10; i++) {
        await state.addCombo(Combo(id: 'c$i', name: 'C$i', strikes: ['Jab'], createdAt: DateTime.now()));
      }
      expect(state.unlockedAchievements.contains('combo_master'), isTrue);
    });

    test('Achievements persist and do not double-award XP', () async {
      final state = AppState();
      int initialXP = state.xp;
      
      await state.recordSession(workoutId: 'w1', actualTrainedSeconds: 600, scheduledSeconds: 600);
      int xpAfterFirst = state.xp;
      expect(xpAfterFirst, greaterThan(initialXP));
      
      // Save and reload
      await state.save();
      final newState = AppState();
      await newState.load();
      
      int xpAfterReload = newState.xp;
      expect(xpAfterReload, xpAfterFirst);
      
      // Completing another session should not re-award 'session_1'
      await newState.recordSession(workoutId: 'w2', actualTrainedSeconds: 600, scheduledSeconds: 600);
      // Only 30 XP for completion, not another 50 for session_1
      expect(newState.xp, xpAfterReload + 30);
    });
  });
}
