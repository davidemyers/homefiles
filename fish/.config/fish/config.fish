# ~/.config/fish/config.fish (https://fishshell.com)
#
# My fish config file for use on Ubuntu and macOS. Began transitioning to fish
# on 2025-03-24 after 36 years of using bash.
#
# A few more complicated functions are kept in separate files.
#
# Install fish 4 on Ubuntu Server 24.04 LTS with:
#
# sudo add-apt-repository -y ppa:fish-shell/release-4
# sudo apt install -y --no-install-recommends fish
# chsh -s /usr/bin/fish
#
# As of Ubuntu Server 25.04, fish 4 is part of the standard repositories but
# still not installed by default.
#

if status is-interactive

    # Use different settings based on the OS.
    switch (uname)

        case Linux
            # Functions specific to (Ubuntu) Linux.

            # Use a more modern, shorter PATH.
            set -gx PATH /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin
            # Append /snap/bin to PATH if it exists.
            fish_add_path --path --append /snap/bin
            # Prepend ~/bin to PATH if it exists.
            fish_add_path --path ~/bin
            # Set up environment variables for Homebrew if installed.
            if path is -x /home/linuxbrew/.linuxbrew/bin/brew
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"
            end

            # Make adjustments based on the terminal type.
            if test "$TERM" = xterm-ghostty; or test "$TERM" = tmux-256color
                # We're probably on a terminal that can do truecolor.
                set -gx COLORTERM truecolor
            end
            if not infocmp &>/dev/null
                # If we're logging in from a terminal with missing terminfo
                # set TERM to a safe fallback. This can happen with Ghostty
                # (macOS) if the terminfo file has not been installed.
                set -gx TERM xterm-256color
            else if test "$TERM" = xterm-256color; and command -q btop
                # Work around color problems with btop.
                # This is necessary when using Shelly (iOS) or Terminal (macOS).
                # Not needed for Ghostty (macOS) or tmux (Linux).
                function btop --description 'Run btop with the "low color" option'
                    command btop --low-color $argv
                end
            else if test "$TERM" = vt220
                # If we're on a serial console we're probably using screen.
                set -gx TERM screen-256color
            end

            # If the console is on a JetKVM, change the system font if
            # ~/.console-setup exists.
            if status is-login; and path is ~/.console-setup; and test "$(tty)" = /dev/tty1; and lsusb -d 1d6b:0104 &>/dev/null
                setupcon -f
            end

            # I prefer 24-hour time on a server.
            set -gx LC_TIME C.UTF-8

            # If NUT is installed set a variable to suppress SSL warnings from upsc.
            if command -q upsc
                set -gx NUT_QUIET_INIT_SSL TRUE
            end

            # This is needed for signing git commits.
            if path is ~/.gnupg/pubring.gpg
                set -gx GPG_TTY (tty)
            end

            # Make ls colors look like the Ubuntu bash defaults.
            if command -q dircolors
                eval (dircolors -c) || true
            end

            function df --description 'Omit certain filesystems from df'
                command df -Th -x squashfs -x tmpfs -x devtmpfs -x fuse.snapfuse -x efivarfs $argv
            end

            function free --description 'alias free free -ht'
                command free -ht $argv
            end

            function last --description 'alias last last -a'
                command last -a $argv
            end

            function clear --description 'alias clear=clear -x'
                command clear -x $argv
            end

            function p1ng --wraps='ping -c1' --description 'Ping once'
                ping -c1 $argv
            end

            # Functions to simplify package management.
            if command -q apt
                function _do_apt_update --description 'Update the apt package list unless recently updated'
                    if not path is /var/cache/apt/pkgcache.bin;
                        or test (math (date +%s) - (stat -c %Y /var/cache/apt/pkgcache.bin)) -gt 600
                        sudo apt update
                    end
                end

                function _check_for_reboot --description 'Print a notice if a reboot is pending'
                    if path is /run/reboot-required
                        echo Reboot required
                    end
                end

                function update --description 'Update the apt package list'
                    _do_apt_update
                    apt list --upgradable
                    _check_for_reboot
                end

                function upgrade --description 'Upgrade packages'
                    _do_apt_update
                    sudo apt upgrade $argv
                    _check_for_reboot
                end

                function aptlog --description 'Tail the apt history log'
                    tail --lines=$LINES /var/log/apt/history.log
                end

                function kclean --description 'Clean up files left over from removed kernels'
                    sudo apt purge (dpkg-query -l 'linux-*' | awk '/^rc/ {print $2}')
                end
            end

            if set -q TMUX
                # We're running directly under tmux.
                function tssh --description 'Open new SSH connections in new tmux windows'
                    for destination in $argv
                        tmux new-window -n (string replace -r '(\w+@)?(\w+)(\.\w+)*' '$2' $destination) ssh $destination
                    end
                end
            end

        case Darwin
            # Functions specific to macOS.

            # Wait a bit longer to read "escape" as "alt" when using Terminal.
            # When using Ghostty "option" works as "alt".
            if test "$TERM_PROGRAM" = Apple_Terminal
                set -g fish_escape_delay_ms 500
            end

            # Set up environment variables for Homebrew.
            if path is -x /opt/homebrew/bin/brew
                eval "$(/opt/homebrew/bin/brew shellenv fish)"
            end

            function df --description 'alias df df -H'
                command df -H $argv
            end

    end

    # Settings not specific to the OS.

    # Modify the fish greeting.
    set -g fish_greeting fish, version $version

    # Truncate fewer directory names in prompts.
    set -g fish_prompt_pwd_full_dirs 3 # default: 1

    # Tweak some colors in the default prompt.
    # 0088FF is a luminance-boosted version of Duke Royal Blue 00539B.
    # https://brand.duke.edu/colors https://htmlcolorcodes.com
    set -g fish_color_user 08F brcyan # default: brgreen
    set -g fish_color_host 08F brcyan # default: normal
    # Can't abide the red comments in the default theme.
    set -g fish_color_comment brblack # default: red
    # I don't like the white '@' in the default prompt.
    function prompt_login --description 'display user name for the prompt, customized'
        echo -n -s (set_color $fish_color_user) "$USER" (set_color $fish_color_host) @ (prompt_hostname) (set_color normal)
    end

    # Show more detail in the git prompt.
    set -g __fish_git_prompt_show_informative_status yes
    set -g __fish_git_prompt_showcolorhints yes
    set -g __fish_git_prompt_showuntrackedfiles yes

    # Need to set EDITOR in order to edit command lines using alt-e.
    set -g EDITOR nano

    # Use "less" even though I habitually type "more".
    function more --wraps=less --description 'alias more less'
        less $argv
    end
    # These are the options used by systemd commands.
    set -gx LESS FRSXMK

    function which --wraps='type --all --short' --description 'alias which type --all --short'
        if isatty stdout
            type --all --short $argv
        else
            command which $argv
        end
    end

    function psg --description 'grep the output of ps'
        ps wwaux | grep --color=always $argv | grep -v grep
    end

    if command -q speedtest
        function st --wraps=speedtest --description 'alias st speedtest'
            speedtest $argv
        end
    end

end
