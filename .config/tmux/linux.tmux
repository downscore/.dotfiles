# We can't open a browser on the local machine from the remote linux machine and clipboard
# forwarding is fiddly (X11 forwarding doesn't work at all and OSC52 doesn't work in tmux run-shell
# commands) so default to copying urls into the tmux buffer. We can copy them into the system
# clipboard from there using OSC52 in a normal tmux window.
set -g @fzf-url-open copy_to_tmux_buffer

# Copy mode using vim keys. OS-specific clipboard. Uses xclip on Linux.
# Note: Copying to the local system clipboard does work from a remote tmux session, but I don't
# believe it's actually using this xclip invocation.
bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "xclip -selection clipboard -in"
