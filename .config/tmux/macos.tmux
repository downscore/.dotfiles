# Copy mode using vim keys. OS-specific clipboard.
bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "pbcopy"
