# Function for finding files 
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
  cd (echo $path | rg '^(.+)/([^/]+)$' -r '$1')
  ls 
end
