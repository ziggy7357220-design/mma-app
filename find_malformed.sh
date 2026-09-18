#!/bin/bash
file="stance_app/lib/data/drill_library.dart"
line_num=0
in_drill=0
drill_start_line=0

while IFS= read -r line; do
  ((line_num++))
  if [[ $line == *"Drill("* ]]; then
    in_drill=1
    drill_start_line=$line_num
  fi
  if [[ $in_drill -eq 1 && $line == *"),"* ]]; then
    in_drill=0
  fi
done < "$file"
