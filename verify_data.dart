import 'package:stance_app/data/content.dart';
import 'package:stance_app/data/drill_library.dart';
import 'package:stance_app/models/models.dart';

void main() {
  final drills = DrillLibrary.drills;
  final workouts = ContentLibrary.workouts;

  int totalExerciseSteps = 0;
  int linkedDrills = 0;
  int unlinkedDrills = 0;

  for (var workout in workouts) {
    for (var step in workout.exercises) {
      totalExerciseSteps++;
      if (step.drillId != null) {
        linkedDrills++;
      } else {
        unlinkedDrills++;
      }
    }
  }

  print('Drills: ${drills.length}');
  print('Workouts: ${workouts.length}');
  print('Total ExerciseSteps: $totalExerciseSteps');
  print('Linked drillIds: $linkedDrills');
  print('Unlinked ExerciseSteps: $unlinkedDrills');
}
