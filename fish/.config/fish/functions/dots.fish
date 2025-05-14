# Manage my common home directory files, which I store on GitHub for easy
# external access.
function dots --description 'Make sure .homefiles are current'
    if path is -d ~/.homefiles; and command -q stow
        pushd ~/.homefiles
        if path is .gitignore
            # This is the master copy, just print status.
            git status
        else
            git pull && stow --no-folding bash fish nano sup tmux
        end
        popd
    end
end
