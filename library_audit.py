import re

def main():
    with open('stance_app/lib/data/drill_library.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    matches = re.findall(r"Drill\(id:\s*['\"]([^'\"]*)['\"],\s*name:\s*['\"]([^'\"]*)['\"]", content)
    
    ids = [m[0] for m in matches]
    names = [m[1] for m in matches]
    
    print(f"Count: {len(ids)}")
    print(f"Unique IDs: {len(set(ids))}")
    print(f"Unique Names: {len(set(names))}")
    
    if len(ids) != len(set(ids)):
        print("Duplicate IDs found!")
    if len(names) != len(set(names)):
        print("Duplicate Names found!")

if __name__ == "__main__":
    main()
