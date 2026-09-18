import re

with open('stance_app/lib/data/content.dart', 'r', encoding='utf-8') as f:
    content = f.read()

workouts = re.findall(r"Workout\(\s*id: '([^']*)'.*?exercises: const \[([\s\S]*?)\],", content, re.DOTALL)
for w_id, exercises_block in workouts:
    steps = re.findall(r"ExerciseStep\(name: '([^']*)'", exercises_block)
    for step in steps:
        print(f"{w_id}|{step}")
