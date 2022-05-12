#!/bin/bash

if [[ -z $1 ]]
then
    echo "Usage: ./setup-hopper-tunnel.sh <OTHER-DEVICE-IP> [<HTTP-HTTPS-IP>]"
    exit 1
fi
IP=$1
HTTP_HTTPS_IP=$2
USER=${3:-other-device}
HTTP_USER=${4:-http-user}

DEVICE_PORTS=(
    9091 \
    8008 \
    8243 \
    6078
)

HTTP_PORTS=(
    8080 \
    8443
)

echo "Setting up device port forwards. IP: $IP"
# First do the device ports above
for PORT in ${DEVICE_PORTS[@]}; do
    echo "Killing existing port forwards for $PORT..."
    lsof -ti @localhost:$PORT | xargs kill -9
    echo "Setting up port forwards for $PORT..."
    ssh -o ServerAliveInterval=50 -L $PORT:localhost:$PORT $USER@$IP -fN
done

if [[ ! -z $HTTP_HTTPS_IP ]]
then
    echo "Setting up HTTP_HTTPS_IP other device port forwards. IP: $HTTP_HTTPS_IP"
    # Now do fortpoint-specific ports
    for PORT in ${HTTP_PORTS[@]}; do
        echo "Killing existing port forwards for $PORT..."
        lsof -ti @localhost:$PORT | xargs kill -9
        echo "Setting up port forwards for $PORT..."
        ssh -o ServerAliveInterval=50 -L $PORT:localhost:$PORT $HTTP_USER@$HTTP_HTTPS_IP -fN
    done
fi

echo "Completed setup!"
