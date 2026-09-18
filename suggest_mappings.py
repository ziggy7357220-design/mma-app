import sys

def normalize(text):
    if not text: return ""
    text = text.strip().lower()
    text = text.replace("warm-up", "warm up")
    text = text.replace("cool-down", "cool down")
    if text.startswith("the "):
        text = text[4:]
    return text.strip()

def main():
    drill_map = {}
    with open('drill_ids.txt', 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line: continue
            parts = line.split('|')
            if len(parts) == 2:
                name, did = parts
                drill_map[name.lower()] = did

    with open('mapping_table.txt', 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.strip().split('|')
            if len(parts) < 3: continue
            workout_id, ex_name, drill_id, tier, rationale = parts[0], parts[1], parts[2], parts[3], parts[4]
            
            if tier == "Tier D":
                ex_norm = normalize(ex_name)
                if ex_norm in ["warm up", "cool down", "rest", "recovery", "break"]:
                    continue
                
                for drill_name, did in drill_map.items():
                    # Better matching: overlap of significant words
                    ex_words = set(ex_norm.split())
                    dr_words = set(drill_name.split())
                    intersection = ex_words.intersection(dr_words)
                    if len(intersection) >= 2:
                        print(f"{ex_name} <-> {drill_name} ({did}) | Match: {intersection}")
                    elif len(ex_words) == 1 and ex_words.intersection(dr_words):
                        print(f"{ex_name} <-> {drill_name} ({did}) | Match: {intersection}")

if __name__ == "__main__":
    main()
