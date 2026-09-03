# Move color setting to a separate function that runs only when needed

if status is-interactive
    set fish_greeting
    # Only run starship init if it exists
    type -q starship; and starship init fish | source
end

# Your aliases here
alias pamcan=pacman
alias settings="gjs ~/.config/ags/assets/settings.js"
alias bar="nvim ~/.config/ags/modules/bar/main.js"
alias barmodes="nvim ~/.config/ags/modules/bar/modes"
alias config="nvim ~/.ags/config.json"
alias default="micro ~/.config/ags/modules/.configuration/user_options.default.json"
alias colors="kitty @ set-colors -a -c ~/.cache/ags/user/generated/kitty-colors.conf"
