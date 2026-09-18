import re

def main():
    mapping = {}
    with open('mapping_table.txt', 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.strip().split('|')
            if len(parts) >= 3:
                workout_id, ex_name, drill_id, tier, rationale = parts[0], parts[1], parts[2], parts[3], parts[4]
                if drill_id and tier in ["Tier A", "Tier B", "Tier C"]:
                    mapping[f"{workout_id}|{ex_name}"] = drill_id

    with open('stance_app/lib/data/content.dart', 'r', encoding='utf-8') as f:
        lines = f.readlines()

    new_lines = []
    current_workout_id = None
    
    for line in lines:
        # Detect Workout start
        if "Workout(" in line:
            # The ID is usually on the next line
            pass
        
        # Detect workout ID (on its own line)
        id_match = re.search(r"id:\s*['\"]([^'\"]*)['\"]", line)
        # We only care about the ID if we are inside a Workout definition
        # but the previous logic was too strict.
        # Let's just update current_workout_id whenever we see id: '...'
        # if it's at the start of a block.
        if id_match and "ExerciseStep" not in line:
            current_workout_id = id_match.group(1)
        
        step_match = re.search(r"ExerciseStep\(name:\s*['\"]([^'\"]*)['\"]", line)
        if step_match and current_workout_id:
            ex_name = step_match.group(1)
            key = f"{current_workout_id}|{ex_name}"
            if key in mapping:
                did = mapping[key]
                # Use a more flexible replacement to handle quotes
                # This regex matches the name part and adds drillId
                line = re.sub(r"(name:\s*['\"]" + re.escape(ex_name) + r"['\"])", r"\1, drillId: '" + did + "'", line)
        
        new_lines.append(line)

    with open('stance_app/lib/data/content.dart', 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

    print("Successfully applied mappings to content.dart")

if __name__ == "__main__":
    main()
