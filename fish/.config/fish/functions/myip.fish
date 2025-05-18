# Find this system's public IP addresses.
function myip --description 'Print public IP addresses'
    set target icanhazip.com
    if not command -q curl
        echo Command \'curl\' is not installed.
        return 1
    end
    curl -4 $target
    switch (uname)
        case Linux
            if ip -6 route get ::/128 &>/dev/null
                curl -6 $target
            end
        case Darwin
            if route get -inet6 ::/128 &>/dev/null
                curl -6 $target
            end
    end
end
