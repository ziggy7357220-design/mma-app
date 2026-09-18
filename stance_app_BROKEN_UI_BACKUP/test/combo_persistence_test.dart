import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stance_app/state.dart';
import 'package:stance_app/models/models.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Combo Persistence', () {
    test('Combo should be saved and loaded correctly', () async {
      // 1. Setup state and create combo
      final state = AppState();
      final combo = Combo(
        id: 'test_1',
        name: 'Test Combo',
        strikes: ['Jab', 'Cross'],
        createdAt: DateTime.now(),
        folder: 'Training',
        presetCount: 8,
      );
      
      state.combos.add(combo);
      await state.save();

      // 2. Create a fresh AppState to simulate app restart
      final newState = AppState();
      await newState.load();

      // 3. Verify persistence
      expect(newState.combos.length, 1);
      expect(newState.combos.first.id, 'test_1');
      expect(newState.combos.first.name, 'Test Combo');
      expect(newState.combos.first.folder, 'Training');
      expect(newState.combos.first.presetCount, 8);
      expect(newState.combos.first.strikes, ['Jab', 'Cross']);
    });

    test('Editing and deleting combos should persist', () async {
      final state = AppState();
      final combo = Combo(
        id: 'test_edit',
        name: 'Original Name',
        strikes: ['Jab'],
        createdAt: DateTime.now(),
      );
      state.combos.add(combo);
      await state.save();

      // Edit
      final editedCombo = Combo(
        id: 'test_edit',
        name: 'Edited Name',
        strikes: ['Jab', 'Cross'],
        createdAt: combo.createdAt,
      );
      state.combos.removeWhere((c) => c.id == 'test_edit');
      state.combos.add(editedCombo);
      await state.save();

      final state2 = AppState();
      await state2.load();
      expect(state2.combos.first.name, 'Edited Name');
      expect(state2.combos.first.strikes.length, 2);

      // Delete
      state2.combos.removeWhere((c) => c.id == 'test_edit');
      await state2.save();

      final state3 = AppState();
      await state3.load();
      expect(state3.combos.isEmpty, isTrue);
    });
  });
}
