# Dotfiles 

1. Install GNU Stow
2. Run: 
```
stow fish
stow kitty
etc
```
To see what stow will do (simulation) run
```
stow -nv fish 
```
To unstow
```
stow --delete fish
```
To restow (unstow and restow again)
```
stow --restow fish
```
