import re

def extract_dart_names():
    names = []
    with open('stance_app/lib/data/drill_library.dart', 'r') as f:
        content = f.read()
        # Match name: "..."
        names = re.findall(r'name: "([^"]*)"', content)
    return names

def extract_source_names():
    names = []
    with open('STANCE_DRILL_LIBRARY.txt', 'r') as f:
        content = f.read()
        # Match all quoted strings
        all_quotes = re.findall(r'"([^"]*)"', content)
        
        # Known categories/structural labels to exclude
        exclude = {
            "Strength & Conditioning", "Warm-Up & Mobility", "Boxing", 
            "Taekwondo", "Muay Thai", "Wrestling", "BJJ", "Kickboxing", 
            "Karate", "Judo", "Stretching", "Warm-Up / Movement Prep", 
            "Punches", "Footwork", "Jump Rope Drills", "Passing", 
            "Sweeps", "Takedowns", "With Chair", "Submissions", 
            "Bodyweight / Core / Lower Body"
        }
        
        for q in all_quotes:
            if q not in exclude:
                names.append(q)
    return names

dart_names = extract_dart_names()
source_names = extract_source_names()

print(f"Dart count: {len(dart_names)}")
print(f"Source count: {len(source_names)}")

# Find unexpected
unexpected = [n for n in dart_names if n not in source_names]
missing = [n for n in source_names if n not in dart_names]

print("\nUnexpected in Dart:")
for n in unexpected:
    print(n)

print("\nMissing from Dart:")
for n in missing:
    print(n)
