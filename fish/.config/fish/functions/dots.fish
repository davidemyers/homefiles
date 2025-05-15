# Manage my common home directory files, which I store on GitHub for easy
# external access.
function dots --description 'Make sure .homefiles are current'
    set repo ~/.homefiles
    if not path is -d $repo
        echo Directory $repo is missing.
        return 1
    end
    if not command -q stow
        echo Command \'stow\' is not installed.
        return 1
    end
    pushd $repo
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
end
