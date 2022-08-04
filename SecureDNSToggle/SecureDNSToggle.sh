#!/bin/bash

dns_dir=/home/daniel/Nextcloud/Projects/scripts/SecureDNSToggle

main_dns_file=$dns_dir/main.resolved.conf
off_dns_file=$dns_dir/off.resolved.conf

resolved_file=/etc/systemd/resolved.conf

function off() {
    sudo cp $off_dns_file $resolved_file
    restartSystemdResolved
    status
}

function on() {
    sudo cp $main_dns_file $resolved_file
    restartSystemdResolved
    status
}

function status(){
    hash_current=$( sha256sum $resolved_file | grep -o "^\w*\b")
    case $hash_current in
        "$( sha256sum $main_dns_file | grep -o "^\w*\b")")
            echo "Secure DNS is enabled"
        ;;
        "$(sha256sum $off_dns_file | grep -o "^\w*\b")")
            echo "Secure DNS is disabled"
        ;;
        *)
            echo "Unknown hash for resolved.conf"
        ;;
    esac
}

function restartSystemdResolved() {
    sudo systemctl restart systemd-resolved
}

function helpMessage(){
    echo "on - enable secure DNS"
    echo "off - disable secure DNS"
    echo "status - see the if secure DNS is enabled or disabled"
    echo "help - display this help message"
}

case "$@" in
    "on" | "1")
        on
    ;;
    "off" | "0")
        off
    ;;
    "status" | "s")
        status
    ;;
    "help" | "h")
        helpMessage
    ;;
    *)
        echo "Invalid argument"
        helpMessage
    ;;
esac