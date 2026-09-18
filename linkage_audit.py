import re

def main():
    # Load Drill Library for resolution
    drill_library = {}
    with open('stance_app/lib/data/drill_library.dart', 'r', encoding='utf-8') as f:
        content = f.read()
        # Match Drill(id: "...", name: "...")
        matches = re.findall(r"Drill\(id:\s*['\"]([^'\"]*)['\"],\s*name:\s*['\"]([^'\"]*)['\"]", content)
        for did, name in matches:
            drill_library[did] = name

    with open('stance_app/lib/data/content.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Split by Workout
    blocks = content.split("Workout(")
    
    total_steps = 0
    linked_steps = 0
    unlinked_steps = 0
    invalid_ids = 0
    unique_linked_ids = set()
    
    all_linkages = []

    for block in blocks[1:]:
        # Get Workout info
        id_match = re.search(r"id:\s*['\"]([^'\"]*)['\"]", block)
        title_match = re.search(r"title:\s*['\"]([^'\"]*)['\"]", block)
        wid = id_match.group(1) if id_match else "Unknown"
        title = title_match.group(1) if title_match else "Unknown"
        
        # Find all ExerciseSteps in this block
        # Need to capture name and drillId
        steps = re.findall(r"ExerciseStep\((.*?)\)", block, re.DOTALL)
        for step_content in steps:
            total_steps += 1
            
            name_match = re.search(r"name:\s*['\"]([^'\"]*)['\"]", step_content)
            did_match = re.search(r"drillId:\s*['\"]([^'\"]*)['\"]", step_content)
            
            ex_name = name_match.group(1) if name_match else "Unknown"
            did = did_match.group(1) if did_match else None
            
            resolved_name = None
            tier = "D" # Default to D
            reason = "No drillId assigned"
            
            if did:
                linked_steps += 1
                unique_linked_ids.add(did)
                if did in drill_library:
                    resolved_name = drill_library[did]
                    # Determine Tier (roughly based on name match)
                    if resolved_name.lower() == ex_name.lower():
                        tier = "A"
                        reason = "Exact match"
                    elif resolved_name.lower().replace("-", " ").replace("_", " ") == ex_name.lower().replace("-", " ").replace("_", " "):
                        tier = "B"
                        reason = "Normalized match"
                    else:
                        tier = "C"
                        reason = "Semantic match"
                else:
                    invalid_ids += 1
                    reason = "Invalid drillId"
            else:
                unlinked_steps += 1
            
            all_linkages.append({
                "wid": wid,
                "title": title,
                "ex_name": ex_name,
                "did": did,
                "resolved": resolved_name,
                "tier": tier,
                "reason": reason
            })

    print(f"total_steps={total_steps}")
    print(f"linked_steps={linked_steps}")
    print(f"unlinked_steps={unlinked_steps}")
    print(f"invalid_ids={invalid_ids}")
    print(f"unique_linked_ids={len(unique_linked_ids)}")
    print("-" * 20)
    for l in all_linkages:
        print(f"{l['wid']}|{l['title']}|{l['ex_name']}|{l['did']}|{l['resolved']}|{l['tier']}|{l['reason']}")

if __name__ == "__main__":
    main()
