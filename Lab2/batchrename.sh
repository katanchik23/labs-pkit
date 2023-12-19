#!/bin/bash

directory="$1"
original_extension="$2"
new_extension="$3"

for file in "$directory"/*.$original_extension; do
    if [ -e "$file" ]; then
        filename=$(basename "$file")
        filename_noext="${filename%.*}"
        new_filename="$filename_noext.$new_extension"
        echo "Переіменовую '$filename' на '$new_filename'"
        mv "$file" "$directory/$new_filename"
    fi
done

