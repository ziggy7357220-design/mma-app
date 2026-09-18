import re

with open('stance_app/lib/data/content.dart', 'r') as f:
    content = f.read()

# Find the workouts list
workout_match = re.search(r'static final List<Workout> workouts = \[(.*?)\]\s*};', content, re.DOTALL)
if not workout_match:
    # Try without the closing brace if it's at the end of file
    workout_match = re.search(r'static final List<Workout> workouts = \[(.*)', content, re.DOTALL)

if workout_match:
    workouts_text = workout_match.group(1)
    # Find all ExerciseStep calls
    steps = re.findall(r'ExerciseStep\((.*?)\),', workouts_text, re.DOTALL)
    
    print(f"Found {len(steps)} steps")
    for i, step in enumerate(steps):
        # Simple extraction of name and duration
        name_match = re.search(r'name:\s*\'(.*?)\'', step)
        dur_match = re.search(r'duration:\s*(\d+)', step)
        drill_match = re.search(r'drillId:\s*\'(.*?)\'', step)
        
        name = name_match.group(1) if name_match else "Unknown"
        dur = dur_match.group(1) if dur_match else "0"
        drill = drill_match.group(1) if drill_match else "None"
        
        print(f"{i}|{name}|{dur}|{drill}")
else:
    print("Workouts list not found")
