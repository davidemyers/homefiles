function myip --description 'Print public IP addresses'
    curl -4 icanhazip.com
    curl -6 icanhazip.com
end
