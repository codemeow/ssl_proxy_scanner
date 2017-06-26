#!/bin/bash

# Disclaimer:
#     This script is supposed to be used to help with
#     accessing corporate nodes and security servers.
#     Any illegal actions are punished by law.

# This script scans available proxy list from
# https://www.sslproxies.org, parses them
# and tries to connect to desired website/address via
# disguised wget. Non "#" marked line of output is
# the available proxy address.
#     ex.:
# ┌──────────────────────────────────────────────────────────────┐
# │ $script.sh aHR0cHM6Ly9zcG9ydC53YnVrLmJldGNpdHlydS5wdy9uZXcv  │
# │ # downloading ssl proxy list                                 │
# │ # filtering list of proxies                                  │
# │ # load list of proxies                                       │
# │ # checking 13.73.26.248:3128                                 │
# │ # connection failed                                          │
# │ # checking 144.217.170.87:3128                               │
# │ # connection failed                                          │
# │ # checking 35.196.8.4:80                                     │
# │ # connection established                                     │
# │ 35.196.8.4:80                                                │
# └──────────────────────────────────────────────────────────────┘

# ARGUMENTS:
#     script.sh <BASE64ENCODEDADDRESS>
#     ex.:
#         script.sh aHR0cHM6Ly9zcG9ydC53YnVrLmJldGNpdHlydS5wdy9uZXcv
#         which stands for "https://sport.wbuk.betcityru.pw/new/"
#         (without quotes).

# NOTE:
#     As ssl proxies are used, script can be used ONLY 
#     for https websites and sslized addresses.
# NOTE:
#     Base64 encoding has been added for security purposes.
# NOTE:
#     Proxies marked as "Russian Federation" are filtered.
#     Comment the line marked with "[!1]" to disable this.

site_index="https://www.sslproxies.org/"
site_target=$( echo "$1" | base64 -d )

net_useragent="AmigaVoyager/3.2 (AmigaOS/MC680x0) "`
             `"Mozilla/5.0 (X11; Linux x86_64) "`
             `"AppleWebKit/537.36 (KHTML, like Gecko) "`
             `"Chrome/56.0.2924.87 Safari/537.36"
net_wget_options_down=( -q --show-progress  --progress=bar )
net_wget_options_scan=( -q --show-progress  --progress=bar
                        --timeout=1         --dns-timeout=1                  
                        --connect-timeout=1 --read-timeout=1               
                        --spider            --tries=1      )
file_ssl_list="/tmp/ssl_list.html"

declare -a proxy_list

function shell_die()
{
    kill -SIGPIPE $$
}

function echo_rollback()
{
    echo -en "\e[1A\e[K"
}

function net_download_page()
# address destfile
{
    wget "${net_wget_options_down[@]}" --user-agent="$net_useragent" "$1" -O "$2"
    echo_rollback
}

function net_check()
# address proxy
{
    https_proxy=$2 \
        wget "${net_wget_options_scan[@]}" --user-agent="$net_useragent" $1

    if [ $? -eq 0 ]
    then
        echo "# connection established"
        echo $2
        shell_die
    else
        echo "# connection failed"
    fi
}

function main_download_proxylist()
{
    net_download_page $site_index "$file_ssl_list"
}

function main_filter_proxylist()
{
    sed -i -e 's/<tr><td>/\'$'\n''<tr><td>/g' "$file_ssl_list"
    sed -i -e '/^\(<tr><td>\)/!d'             "$file_ssl_list"
    sed -i -e '/Russian\ Federation/d'        "$file_ssl_list" # [!1]
    sed -i -e 's/<tr><td>//g'                 "$file_ssl_list"
    sed -i -e 's/<\/td><td>/:/g'              "$file_ssl_list"
    sed -i -r 's/([^:]+:[^:]*).*/\1/'         "$file_ssl_list"
}

function main_load_proxylist()
{
    proxy_list=( $(cat "$file_ssl_list") )

    local _i
    for (( _i=0; _i < ${#proxy_list[@]}; _i++ ))
    do
        echo "# checking ${proxy_list[$_i]}"
        net_check "$site_target" "${proxy_list[$_i]}"
    done
}

if [ $# -lt 1 ]
then
    echo "# Error: need to point the target https website (in base64)"
    shell_die
fi

echo "# downloading ssl proxy list"
main_download_proxylist
echo "# filtering list of proxies"
main_filter_proxylist
echo "# load list of proxies"
main_load_proxylist

