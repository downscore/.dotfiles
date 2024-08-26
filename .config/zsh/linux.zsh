# Bind ctrl-v to copy the tmux buffer to the clipboard. This is used to help opening urls from the
# terminal in a remote tmux session. ctrl-v should be a no-op in local sessions as we can directly
# access the system clipboard.
bindkey '^v' zle_tmux_buffer_to_clipboard
