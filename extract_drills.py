import re

drills = []
with open('stance_app/lib/data/drill_library.dart', 'r', encoding='utf-8') as f:
    content = f.read()
    # Match Drill(id: "...", name: "...") or Drill(id: '...', name: '...')
    pattern = r"Drill\(id:\s*['\"]([^'\"]*)['\"],\s*name:\s*['\"]([^'\"]*)['\"]"
    matches = re.findall(pattern, content)
    for match in matches:
        drills.append(f"{match[1]}|{match[0]}")

with open('drill_ids.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(drills) + '\n')

print(f"Extracted {len(drills)} drills.")
