import re

def main():
    with open('stance_app/lib/data/content.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Use a more reliable split: the start of the Workout definition
    blocks = content.split("Workout(")
    # The first block is preamble
    workout_blocks = blocks[1:]
    
    print(f"Workout count: {len(workout_blocks)}")
    
    for block in workout_blocks:
        # We only want the content until the closing parenthesis of the Workout call.
        # Since Workout(...) is the outer shell, we find the matching closing paren.
        # But a simpler way is to just look for id: and title: in the block.
        
        id_match = re.search(r"id:\s*['\"]([^'\"]*)['\"]", block)
        title_match = re.search(r"title:\s*['\"]([^'\"]*)['\"]", block)
        dur_match = re.search(r"duration:\s*(\d+)", block)
        
        if not id_match or not title_match:
            print(f"Error: Missing ID or Title in block starting with {block[:50]}...")
            continue
            
        wid = id_match.group(1)
        title = title_match.group(1)
        
        # Count ExerciseSteps
        ex_steps = re.findall(r"ExerciseStep\(", block)
        # The number of steps should match the previous inventory.
        
    print("Structural check complete.")

if __name__ == "__main__":
    main()
