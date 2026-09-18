import sys

def normalize(text):
    if not text: return ""
    text = text.strip().lower()
    text = text.replace("warm-up", "warm up")
    text = text.replace("cool-down", "cool down")
    if text.startswith("the "):
        text = text[4:]
    return text.strip()

# Conservative Semantic Map (Tier C)
SEMANTIC_MAP = {
    "stance integrity": "stance",
    "linear slides": "basic_footwork",
    "lateral slides": "basic_footwork",
    "basic pivots": "footwork_pivot",
    "controlled pivots": "footwork_pivot",
    "l-step/v-step": "footwork_v_step",
    "v-step": "footwork_v_step",
    "l-step": "footwork_v_step",
    "ring cutting": "footwork_ring_cutting",
    "ring cutting motion": "footwork_ring_cutting",
    "guard mastery": "guard_positioning",
    "guard positioning": "guard_positioning",
    # Striking
    "front snap kick": "front_kick",
    "side kick basics": "kicks_side",
    "spinning hook kick": "kicks_hook",
    "the 1-2 sequence": "1_2___jab__plus__cross",
    # BJJ
    "closed guard maintenance": "closed_guard",
    "guard recovery": "grapple_trans_turtle_to_guard",
    "guard recovery counter": "grapple_trans_turtle_to_guard",
    # Wrestling
    "double leg": "double_leg_takedown",
    "single leg": "grapple_td_single_leg",
}

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

    exercises = []
    with open('all_exercises.txt', 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line: continue
            parts = line.split('|')
            if len(parts) == 2:
                exercises.append(parts)

    results = []
    for workout_id, ex_name in exercises:
        ex_lower = ex_name.lower().strip()
        ex_norm = normalize(ex_name)
        
        if ex_lower in drill_map:
            results.append(f"{workout_id}|{ex_name}|{drill_map[ex_lower]}|Tier A|Exact match")
            continue
        
        found_b = False
        for drill_name, drill_id in drill_map.items():
            if normalize(drill_name) == ex_norm:
                results.append(f"{workout_id}|{ex_name}|{drill_id}|Tier B|Normalized match")
                found_b = True
                break
        if found_b: continue

        if ex_norm in SEMANTIC_MAP:
            did = SEMANTIC_MAP[ex_norm]
            results.append(f"{workout_id}|{ex_name}|{did}|Tier C|Semantic mapping")
            continue

        if ex_norm in ["warm up", "cool down", "rest", "recovery", "break", "cool-down", "warm-up"]:
             results.append(f"{workout_id}|{ex_name}||Tier D|Generic utility step")
             continue

        results.append(f"{workout_id}|{ex_name}||Tier D|No confident match")

    with open('mapping_table.txt', 'w', encoding='utf-8') as f:
        f.write('\n'.join(results) + '\n')

    print(f"Mapped {len(results)} exercises.")

if __name__ == "__main__":
    main()
