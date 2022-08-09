# Function for finding and cd into folder
# ex vd
# results: fuzzy search for all dir in current dir
# ex vd foo
# results: fuzzy search for directory "foo" in current dir
# ex vd Downloads
# results: fuzzy search for all directories in directory "Downloads"
# ex vd Downloads foo
# results: fuzzy search for directory "foo" in "Downloads"
function vd
  if not set -q argv[1]
    set path (fd --type directory . $PWD --hidden -E ".git" | fzf --preview 'exa --tree {}' --height=20% || return)
    cd $path
    ls
  else
    if set -q argv[1]; and not set -q argv[2] #if just one arg
      if not test -d $argv[1] #if arg is not directory in current path use arg as query for fzf
        set path (fd --type directory . $PWD --hidden -E ".git" | fzf --preview 'exa -tree {}' --height=20% -q $argv[1] || return)
        cd $path
        ls
      else #if arg is a dir serach in there instead
        set path (fd --type directory . $argv[1] --hidden -E ".git" | fzf --preview 'exa --tree {}' --height=20% || return)
        cd $path
        ls
      end
    end
    if set -q argv[1]; and set -q argv[2] #if two arguments first is path second query
      set path (fd --type directory . $argv[1] --hidden -E ".git"| fzf --preview 'exa -tree {}' --height=20% -q $argv[2] || return)
      cd $path
      ls
    end
  end
end

