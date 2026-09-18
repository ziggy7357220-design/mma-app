import re

def main():
    with open('stance_app/lib/data/content.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    workouts = re.findall(r"Workout\s*\((.*?)\)", content, re.DOTALL)
    
    workout_ids = []
    workout_exercise_counts = {}
    
    # Each workout block starts with Workout( and contains ExerciseStep() calls.
    # We need to find the ID for each workout.
    
    # Split content by "Workout("
    blocks = content.split("Workout(")
    # The first block is usually imports/empty
    for block in blocks[1:]:
        # Extract ID
        id_match = re.search(r"id:\s*['\"]([^'\"]*)['\"]", block)
        if id_match:
            wid = id_match.group(1)
            workout_ids.append(wid)
            # Count ExerciseSteps in this block
            ex_count = len(re.findall(r"ExerciseStep\(", block))
            workout_exercise_counts[wid] = ex_count

    print(f"Workout count: {len(workout_ids)}")
    print(f"Total ExerciseSteps: {sum(workout_exercise_counts.values())}")
    print(f"Unique Workout IDs: {len(set(workout_ids))}")
    print(f"Duplicate Workout IDs: {len(workout_ids) - len(set(workout_ids))}")
    
    for wid, count in workout_exercise_counts.items():
        print(f"{wid}: {count}")

if __name__ == "__main__":
    main()
