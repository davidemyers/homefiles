# Manage my common home directory files, which I store on GitHub for easy
# external access.
function dots --description 'Make sure .homefiles are current'
    if path is -d ~/.homefiles; and command -q stow
        pushd ~/.homefiles
        if path is .gitignore
            # This is the master copy, just print status.
            git status
        else
            git pull
            switch (uname)
                case Linux
                    stow --no-folding bash fish nano sup tmux
                case Darwin
                    stow --no-folding fish
            end
        end
        popd
    else
        echo This function is not available on this system.
    end
end
