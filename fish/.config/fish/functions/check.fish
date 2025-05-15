# For this to work you need keep fish config files formatted the way
# fish_indent tells you to.
function check --description 'Check the fish config file(s)'
    for config in $__fish_config_dir/config.fish $__fish_config_dir/conf.d/*.fish $__fish_config_dir/functions/*.fish
        if not fish_indent --check $config
            diff $config (fish_indent $config | psub)
            break
        end
    end
end
