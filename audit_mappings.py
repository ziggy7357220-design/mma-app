import re

def main():
    # Load valid drill IDs
    valid_ids = set()
    with open('drill_ids.txt', 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.strip().split('|')
            if len(parts) == 2:
                valid_ids.add(parts[1])

    # Scan content.dart for drillIds
    errors = []
    with open('stance_app/lib/data/content.dart', 'r', encoding='utf-8') as f:
        for i, line in enumerate(f, 1):
            match = re.search(r"drillId:\s*['\"]([^'\"]*)['\"]", line)
            if match:
                did = match.group(1)
                if did not in valid_ids:
                    errors.append(f"Line {i}: Invalid drillId '{did}'")

    if not errors:
        print("Audit passed: All drillIds are valid.")
    else:
        print(f"Audit failed: {len(errors)} invalid IDs found.")
        for err in errors:
            print(err)

if __name__ == "__main__":
    main()
