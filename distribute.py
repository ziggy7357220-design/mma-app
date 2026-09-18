import re

def main():
    with open('stance_app/lib/data/content.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract all ExerciseSteps and their drillIds
    steps = re.findall(r"ExerciseStep\((.*?)\)", content, re.DOTALL)
    
    dist = {"A": 0, "B": 0, "C": 0, "D": 0, "E": 0}
    
    # We need the DrillLibrary to determine the tier
    drill_library = {}
    with open('stance_app/lib/data/drill_library.dart', 'r', encoding='utf-8') as f:
        lib_content = f.read()
        matches = re.findall(r"Drill\(id:\s*['\"]([^'\"]*)['\"],\s*name:\s*['\"]([^'\"]*)['\"]", lib_content)
        for did, name in matches:
            drill_library[did] = name

    for step_content in steps:
        name_match = re.search(r"name:\s*['\"]([^'\"]*)['\"]", step_content)
        did_match = re.search(r"drillId:\s*['\"]([^'\"]*)['\"]", step_content)
        
        ex_name = name_match.group(1) if name_match else "Unknown"
        did = did_match.group(1) if did_match else None
        
        if not did:
            dist["D"] += 1
            continue
        
        if did not in drill_library:
            dist["E"] += 1 # Invalid/Ambiguous
            continue
        
        drill_name = drill_library[did]
        if drill_name.lower() == ex_name.lower():
            dist["A"] += 1
        elif drill_name.lower().replace("-", " ").replace("_", " ") == ex_name.lower().replace("-", " ").replace("_", " "):
            dist["B"] += 1
        else:
            dist["C"] += 1

    print(f"A: {dist['A']}")
    print(f"B: {dist['B']}")
    print(f"C: {dist['C']}")
    print(f"D: {dist['D']}")
    print(f"E: {dist['E']}")
    print(f"Total: {sum(dist.values())}")

if __name__ == "__main__":
    main()
