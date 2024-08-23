# Use batcat for man pages.
export MANPAGER="sh -c 'col -bx | batcat -l man -p'"

# Use batcat (not "bat") as the default pager on linux.
export PAGER="batcat --paging=always"
