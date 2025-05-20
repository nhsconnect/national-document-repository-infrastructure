#!/bin/bash
readonly os_type=$(uname)

if [[ "$os_type" == "Darwin"* ]]; then
    for directory in $(gfind ./ -regex '\./.[^.]*\/*.tf' -printf '%h\n' | sort -u)
    do
        terraform-docs markdown table --output-file "$directory/README.md" --output-mode inject "$directory"
    done
else
    for directory in $(find ./ -regex '\./.[^.]*\/*.tf' -printf '%h\n' | sort -u)
    do
        terraform-docs markdown table --output-file "$directory/README.md" --output-mode inject "$directory"
    done
fi