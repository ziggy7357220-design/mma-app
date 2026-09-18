import re

def extract_drills(file_path):
    drills = []
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        # Match Drill(id: "...", name: "...", ...)
        matches = re.finditer(r'Drill\(\s*id:\s*"([^"]+)",\s*name:\s*"([^"]+)"', content)
        for m in matches:
            drills.append({'id': m.group(1), 'name': m.group(2)})
    return drills

def extract_names(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        return [line.strip() for line in f if line.strip()]

library_drills = extract_drills('stance_app/lib/data/drill_library.dart')
baseline_names = extract_names('dart_names.txt')

lib_names = [d['name'] for d in library_drills]
lib_ids = [d['id'] for d in library_drills]

print(f"Current drills: {len(library_drills)}")
print(f"Unique IDs: {len(set(lib_ids))}")
print(f"Duplicate IDs: {len(lib_ids) - len(set(lib_ids))}")
print(f"Unique names: {len(set(lib_names))}")
print(f"Duplicate names: {len(lib_names) - len(set(lib_names))}")

missing = [name for name in baseline_names if name not in lib_names]
unexpected = [name for name in lib_names if name not in baseline_names]

print(f"Missing from library: {len(missing)}")
for m in missing:
    print(f" - {m}")

print(f"Unexpected in library: {len(unexpected)}")
for u in unexpected:
    print(f" - {u}")

# Check specifically for Shadow Boxing Tips
if "Shadow Boxing Tips" in baseline_names and "Shadow Boxing Tips" not in lib_names:
    print("VERIFIED: 'Shadow Boxing Tips' was removed.")
else:
    print("VERIFICATION FAILED: 'Shadow Boxing Tips' removal not confirmed.")

