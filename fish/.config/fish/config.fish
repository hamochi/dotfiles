### ADDING TO THE PATH
# First line removes the path; second line sets it.  Without the first line,
# your path gets massive and fish becomes very slow.
set -e fish_user_paths
set -U fish_user_paths $HOME/.local/bin $HOME/Applications $fish_user_paths

### EXPORT ###
set fish_greeting                                 # Supresses fish's intro message
set TERM "xterm-256color"                         # Sets the terminal type
set EDITOR lvim

### SET MANPAGER
### "bat" as manpager
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
### "vim" as manpager
# set -x MANPAGER '/bin/bash -c "vim -MRn -c \"set buftype=nofile showtabline=0 ft=man ts=8 nomod nolist norelativenumber nonu noma\" -c \"normal L\" -c \"nmap q :qa<CR>\"</dev/tty <(col -b)"'
### "nvim" as manpager
# set -x MANPAGER "nvim -c 'set ft=man' -"

### SET VI MODE ###
function fish_user_key_bindings
	fish_vi_key_bindings
end

### AUTOCOMPLETE AND HIGHLIGHT COLORS ###
set fish_color_normal brcyan
set fish_color_autosuggestion '#7d7d7d'
set fish_color_command brcyan
set fish_color_error '#ff6c6b'
set fish_color_param brcyan

### FUNCTIONS
# Functions needed for !! and !$
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end
# The bindings for !! and !$
bind -Minsert ! __history_previous_command
bind -Minsert '$' __history_previous_command_arguments

# Function for handling snippets
function __snippets
  set SNIPPET $HOME/.config/fish/snippets.txt
  set fzf_args --height=40% --min-height=5 --preview-window=top:20%,border-sharp 
  set insert (rg ( awk -F ';' "{print \$1}" $SNIPPET | \
    fzf --preview "rg {} $SNIPPET |
    awk -F ';' '{print \$2}' | dotacat" \
    $fzf_args) \
    $SNIPPET | \
    awk -F ';' "{print \$2}")
  commandline -i $insert
end
bind -Minsert \cx __snippets

### ALIASES ###
# alias clear='/bin/clear; echo; colorscript random'
alias clear='/bin/clear; echo; seq 30 | sort --random-sort | spark | dotacat'

# root privileges
alias doas="doas --"

# navigation
alias ..='cd ..'
alias D='cd ~/Downloads'

# Changing "ls" to "exa"
alias ls='exa -al --color=always --group-directories-first --icons' # my preferred listing
alias lsd='exa -aDl --color=always --group-directories-first --icons' # just dirs
alias la='exa -a --color=always --group-directories-first --icons' # all files and dirs
alias ll='exa -l --color=always --group-directories-first --icons'  # long format
alias lt='exa -aT --color=always --group-directories-first --icons' # tree listing
alias l.='exa -a | egrep "^\."'

# pacman and yay
alias pacsyu='sudo pacman -Syyu'                 # update only standard pkgs
alias yaysua='yay -Sua --noconfirm'              # update only AUR pkgs (yay)
alias yaysyu='yay -Syu --noconfirm'              # update standard pkgs and AUR pkgs (yay)
alias unlock='sudo rm /var/lib/pacman/db.lck'    # remove pacman lock
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'  # remove orphaned packages

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

# adding flags
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB

## get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

## get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# switch between shells
# I do not recommend switching default SHELL from bash.
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"
alias tofish="sudo chsh $USER -s /bin/fish && echo 'Now log out.'"

# termbin
alias tb="nc termbin.com 9999"

# tmux
alias tmux="tmux -u"
### SETTING THE STARSHIP PROMPT ###
starship init fish | source
