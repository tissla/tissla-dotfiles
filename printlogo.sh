#!/bin/bash

centerfile() {
    local term_width=$(tput cols)
    
    # find longest row
    local max_length=0
    while IFS= read -r line; do
        local plain=$(echo "$line" | sed -r "s/\x1B\[[0-9;]*[mK]//g")
        if [ ${#plain} -gt $max_length ]; then
            max_length=${#plain}
        fi
    done < "$1"
    
    # center based on longest row
    local padding=$(( (term_width - max_length) / 2 ))
    
    while IFS= read -r line; do
        printf "%${padding}s%s\n" "" "$line"
    done < "$1"
}

centerfile fastfetch/tissla.txt
