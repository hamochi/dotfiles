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
### Uncomment only one of these!

### "bat" as manpager
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

### "vim" as manpager
# set -x MANPAGER '/bin/bash -c "vim -MRn -c \"set buftype=nofile showtabline=0 ft=man ts=8 nomod nolist norelativenumber nonu noma\" -c \"normal L\" -c \"nmap q :qa<CR>\"</dev/tty <(col -b)"'

### "nvim" as manpager
# set -x MANPAGER "nvim -c 'set ft=man' -"

### SET EITHER DEFAULT EMACS MODE OR VI MODE ###
function fish_user_key_bindings
	fish_vi_key_bindings
end
### END OF VI MODE ###

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

# Function for creating a backup file
# ex: backup file.txt
# result: copies file as file.txt.bak
function backup --argument filename
    cp $filename $filename.bak
end

# Function for copying files and directories, even recursively.
# ex: copy DIRNAME LOCATIONS
# result: copies the directory and all of its contents.
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
	set from (echo $argv[1] | trim-right /)
	set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

# Function for printing a column (splits input on whitespace)
# ex: echo 1 2 3 | coln 3
# output: 3
function coln
    while read -l input
        echo $input | awk '{print $'$argv[1]'}'
    end
end

# Function for printing a row
# ex: seq 3 | rown 3
# output: 3
function rown --argument index
    sed -n "$index p"
end

# Function for ignoring the first 'n' lines
# ex: seq 10 | skip 5
# results: prints everything but the first 5 lines
function skip --argument n
    tail +(math 1 + $n)
end

# Function for taking the first 'n' lines
# ex: seq 10 | take 5
# results: prints only the first 5 lines
function take --argument number
    head -$number
end

function spark --description Sparklines
    argparse --ignore-unknown --name=spark v/version h/help m/min= M/max= -- $argv || return

    if set --query _flag_version[1]
        echo "spark, version 1.1.0"
    else if set --query _flag_help[1]
        echo "Usage: spark <numbers ...>"
        echo "       stdin | spark"
        echo "Options:"
        echo "       --min=<number>   Minimum range"
        echo "       --max=<number>   Maximum range"
        echo "       -v or --version  Print version"
        echo "       -h or --help     Print this help message"
        echo "Examples:"
        echo "       spark 1 1 2 5 14 42"
        echo "       seq 64 | sort --random-sort | spark"
    else if set --query argv[1]
        printf "%s\n" $argv | spark --min="$_flag_min" --max="$_flag_max"
    else
        command awk -v min="$_flag_min" -v max="$_flag_max" '
            {
                m = min == "" ? m == "" ? $0 : m > $0 ? $0 : m : min
                M = max == "" ? M == "" ? $0 : M < $0 ? $0 : M : max
                nums[NR] = $0
            }
            END {
                n = split("▁ ▂ ▃ ▄ ▅ ▆ ▇ █", sparks, " ") - 1
                while (++i <= NR) 
                    printf("%s", sparks[(M == m) ? 3 : sprintf("%.f", (1 + (nums[i] - m) * n / (M - m)))])
            }
        ' && echo
    end
end

# Function for handling snippets
function __snippets
  set SNIPPET $HOME/.config/fish/snippets.txt
  set insert (rg (__awk $SNIPPET 1 | fzf --preview "rg {} $SNIPPET | __awk 2 | dotacat" --height=5% --min-height=5 --preview-window=top:20%,border-sharp) $SNIPPET | __awk 2)
  commandline -i $insert
end
bind -Minsert \cx __snippets


function __awk
  if not set -q argv[2]
    awk -F ';' "{print \$$argv[1]}"
  else
    awk -F ';' "{print \$$argv[2]}" $argv[1]
  end
end

# Function for finding and cd into folder
# ex vd
# results: fuzzy search for all dir in current dir
# ex vd foo
# results: fuzzy search for directory "foo" in current dir
# ex vd Downloads
# results: fozzy search for all directories in directory "Downloads"
# ex vd Downloads foo
# results: fuzzy search for directory "foo" in "Downloads"
function vd
  if not set -q argv[1]
    cd (fd --type directory . $PWD --hidden| fzf --preview 'exa --tree {}' --height=20%)
    ls
  else
    if set -q argv[1]; and not set -q argv[2] #if just one arg
      if not test -d $argv[1] #if arg is not directory in current path use arg as query for fzf
        cd (fd --type directory . $PWD --hidden | fzf --preview 'exa -tree {}' --height=20% -q $argv[1])
        ls
      else #if arg is a dir serach in there instead
        cd (fd --type directory . $argv[1] --hidden| fzf --preview 'exa --tree {}' --height=20%)
        ls
      end
    end
    if set -q argv[1]; and set -q argv[2] #if two arguments first is path second query
      cd (fd --type directory . $argv[1] --hidden | fzf --preview 'exa -tree {}' --height=20% -q $argv[2])
      ls
    end
  end
end

function ff 
  set stdArgs --hidden --type file -E "*.mozilla" -E "*.cache" -E "*npm" -E "*java*" -E ".cargo"  
  if not set -q argv[1]
    set args $stdArgs . $HOME 
  else
    if test $argv[1] = "."
      set args $stdArgs . $PWD 
    else
      set args $argv
    end
  end
  set path (fd $args | fzf --preview "bat --style=numbers --color=always {}")
  echo ">>>" $path | dotacat
  action $path
end

function action
  set file $HOME/.config/fish/file-actions.txt
  eval (rg (__awk $file 1 | fzf --height=25%) $file | __awk 2) $argv[1] 
end

function __rename 
  set dir (echo $argv[1] | rg '^(.+)/([^/]+)$' -r '$1')
  #echo Rename $argv[1] to
  read -l -P "New filename: " filename
  echo mv $argv[1] "$dir/$filename" | dotacat
  mv $argv[1] "$dir/$filename" 
  ls "$dir/$filename"
end

function __gotoFolder
  cd (echo $argv[1] | rg '^(.+)/([^/]+)$' -r '$1')
  ls
end

function __move
  set filename (echo $argv[1] | rg '^(.+)/([^/]+)$' -r '$2')
  set newPath (fd --hidden --type directory . $HOME | fzf --preview "exa --tree {}" --height=20%)
  echo move to "$newPath$filename"
end

function __zip
  set dir (echo $argv[1] | rg '^(.+)/([^/]+)$' -r '$1')
  read -l -P "New filename (something.zip): " filename
  cd $dir
  zip -e $filename $argv[1]
  ls $filename
end

function info
  set command (exa -la -g --octal-permissions --time-style long-iso $argv[1])
  set octalPerm (echo $command | coln 1)
  set perm (string trim -l -c "." (echo $command | coln 2))
  set size (du -sh $argv[1] | coln 1)
  set user (echo $command | coln 4)
  set group (echo $command | coln 5)
  set modDate (echo $command | coln 6)
  set modTime (echo $command | coln 7)

  printf "%-20s %s (%s)\n" "Permissions:" $perm $octalPerm
  printf "%-20s %s\n" "Size:" $size
  printf "%-20s %s\n" "User:" $user
  printf "%-20s %s\n" "Group" $group
  printf "%-20s %s %s\n" "Date Modified" $modDate $modTime  
  
  if not test -d $argv 
    printf "%-20s %s\n" "Lines:" (cat $argv[1] | wc -l) 
    printf "%-20s %s\n" "Words:" (cat $argv[1] | wc -w) 
    printf "%-20s %s\n" "Chars:" (cat $argv[1] | wc -c) 
  end
  printf "%-20s %s\n" "Info:" (string replace "$argv[1]: " "" (file $argv[1]))
end

function ttest
  while read -l line
    echo processing $line
  end
end

## FILE EXPLORER
function fe
  while true
    set exa_all exa  --icons --group-directories-first --color=always -la -all
    set exa_folder exa  --icons --color=always -D -la -all
    set fd_command fd . $PWD
    set fzf_command fzf --ansi -m --preview "__fe_preview {}" --header "<F1> All | <F3> Folders | <F3> Search | <F4> Select" --bind "f1:reload($exa_all),f2:reload($exa_folder),f3:reload($fd_command)"
    set output (FZF_DEFAULT_COMMAND="$exa_all" $fzf_command | string split0 | string escape) 
    echo $output
    set c (count $output)
    set c (math "$c - 1")
    set output $output[1..$c]
    if not test (count $output) = "1"  
      echo "multi line selected"
      echo $output
      break
    end
    if not test -n "$output" #if esc
      break
    else if not test -e $output #if file or folder does not exist, output of exa
      set newOutput (echo $output[1] | __fe_coln 8)
      if not test -d $newOutput #if file
        echo $newOutput
        echo $output
        break
      else #if folder
        cd $newOutput
      end
    else #from search results 
      if not test -d $output #if file 
        echo $output
        break
      else #folder
        cd $output  
      end
    end
  end
end

function __fe_coln
  while read -l input
    echo (string replace -a "'" "" (echo $input | awk '{ s = ""; for (i = '$argv[1]'; i <= NF; i++) s = s $i " "; print s }'))
  end
end

function __fe_preview
  if not test -e $argv[1]
    set input (echo $argv[1] | __fe_coln 8)
  else
    set input $argv[1]
  end
  
  set sp (string split -r "." $input )
  set ext $sp[(count $sp)]
  
  if test -d $input
    kitty icat --clear --transfer-mode file
    exa --tree $input
  else if test $ext = "jpg"
    kitty icat --clear --transfer-mode file
    kitty icat  --place 80x120@120x10 --transfer-mode file $input
  else
    kitty icat --clear --transfer-mode file
    bat --style=numbers --color=always "$input"
  end
end

### end of file explorer
### END OF FUNCTIONS ###


### ALIASES ###
# alias clear='/bin/clear; echo; colorscript random'
alias clear='/bin/clear; echo; seq 30 | sort --random-sort | spark | dotacat'

# root privileges
alias doas="doas --"

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# broot
alias br='broot -dhp'
alias bs='broot --sizes'

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

### SETTING THE STARSHIP PROMPT ###
starship init fish | source
