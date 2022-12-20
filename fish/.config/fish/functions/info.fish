# Function for displaying file info
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
