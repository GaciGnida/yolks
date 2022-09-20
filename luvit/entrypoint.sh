#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

## if auto_update is not set or to 1 update
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then
    echo -e "updating lit"
    ./lit update
    
    echo -e "fetching luvi version"
    GET_LIT=$(curl -L https://github.com/luvit/lit/raw/master/get-lit.sh)

    LUVI_VERSION=$(echo ${GET_LIT} | grep -o -P "(?<=LUVI_VERSION:-).*(?=})")

    if [$(luvi -v | grep ${LUVI_VERSION})]; then
        echo -e "the installed luvi instance has the latest version"
    else
        echo -e "updating luvi"
        eval ${GET_LIT}
    fi
    
    if [ -e "package.lua" ]; then
        echo -e "updating deps from package.lua"
        ./lit install
    fi
else
    echo -e "Not updating luvit server as auto update was set to 0. Starting Server"
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
