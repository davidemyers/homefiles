# Manage my common home directory files, which I store on GitHub for easy
# access by both internal and external systems. GNU stow is used to symlink
# the files into their proper locations.
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
        switch (uname)
            case Linux
                set stow_args bash fish nano sup tmux
                set stat_args -c %Y
            case Darwin
                set stow_args fish
                set stat_args -f %m
        end
        set before (stat $stat_args .git/index)
        git pull
        if test (stat $stat_args .git/index) -gt $before
            stow --verbose --no-folding $stow_args
        end
    end
    popd

end
