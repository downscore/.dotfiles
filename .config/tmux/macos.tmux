# Copy mode using vim keys. OS-specific clipboard.
bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "pbcopy"

# Render LaTeX expressions from pane in Preview.app
bind-key L run-shell "~/.config/tmux/latex-popup/latex_popup.sh"
