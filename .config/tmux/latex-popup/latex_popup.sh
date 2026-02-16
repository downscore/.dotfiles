#!/bin/bash
#
# Capture tmux pane, extract and render LaTeX, display image
#
# Usage: latex_popup.sh
# Bind in tmux.conf: bind-key L run-shell "~/.config/tmux/latex-popup/latex_popup.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Capture the current pane content (last 100 lines)
PANE_CONTENT=$(tmux capture-pane -p -S -100)

# Render LaTeX to image using uv run
IMAGE_PATH=$(echo "$PANE_CONTENT" | uv run "$SCRIPT_DIR/render_latex.py" 2>/dev/null)

if [ -z "$IMAGE_PATH" ] || [ ! -f "$IMAGE_PATH" ]; then
    tmux display-message "No LaTeX found in pane"
    exit 1
fi

# Open in Preview.app (macOS)
open "$IMAGE_PATH"
