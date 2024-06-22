# Copy mode using vim keys. OS-specific clipboard. Uses xclip on Linux.
bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "xclip -selection clipboard -in"
