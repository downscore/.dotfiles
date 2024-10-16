#!/bin/sh

filetype=$(file -b -L --mime-type "$1")

if echo "$filetype" | grep -qvE 'text|json'; then
    echo "File: $filetype"
    exit
fi

# Try to use bat for previews if it is installed.
if command -v bat > /dev/null; then
    bat --paging=never --style=numbers --wrap=never --terminal-width $(($2-5)) -f "$1"
else
    cat "$1"
fi
