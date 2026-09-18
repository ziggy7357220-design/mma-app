import re

def main():
    drill_library = {}
    with open('stance_app/lib/data/drill_library.dart', 'r', encoding='utf-8') as f:
        content = f.read()
        matches = re.findall(r"Drill\(id:\s*['\"]([^'\"]*)['\"],\s*name:\s*['\"]([^'\"]*)['\"]", content)
        for did, name in matches:
            drill_library[did] = name

    with open('stance_app/lib/data/content.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    blocks = content.split("Workout(")
    for block in blocks[1:]:
        steps = re.findall(r"ExerciseStep\((.*?)\)", block, re.DOTALL)
        for step_content in steps:
            name_match = re.search(r"name:\s*['\"]([^'\"]*)['\"]", step_content)
            did_match = re.search(r"drillId:\s*['\"]([^'\"]*)['\"]", step_content)
            ex_name = name_match.group(1) if name_match else "Unknown"
            did = did_match.group(1) if did_match else None
            
            if did and did in drill_library:
                drill_name = drill_library[did]
                # Tier C if not A or B
                if not (drill_name.lower() == ex_name.lower() or 
                        drill_name.lower().replace("-", " ").replace("_", " ") == ex_name.lower().replace("-", " ").replace("_", " ")):
                    print(f"{ex_name} -> {drill_name} ({did})")

if __name__ == "__main__":
    main()
