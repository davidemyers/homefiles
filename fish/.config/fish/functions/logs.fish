# Print the most recent system log entries without pagination and with less
# useful entries filtered out.
function logs --description 'Print filtered list of most recent system log entries'
    if command -q journalctl
        SYSTEMD_COLORS=1 journalctl --boot --no-pager --system | grep -E -v -e CRON \
            -e 'systemd.*Started' \
            -e 'systemd.*Starting' \
            -e 'systemd.*Finished' \
            -e 'systemd.*Deactivated' \
            -e 'systemd.*Consumed' \
            -e 'INFO.*ubuntupro.timer' \
            -e RTR-ADVERT \
            -e 'sanoid.*INFO' | tail -$LINES
    else
        echo This function is not available on this system.
    end
end
