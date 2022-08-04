#!/bin/bash

dns_dir=/home/daniel/Nextcloud/Projects/scripts/SSHSwitcher

personal_ssh=$dns_dir/personal_ssh.config
work_ssh=$dns_dir/work_ssh.config

ssh_file=/home/daniel/.ssh/config

function personal() {
    cp $personal_ssh $ssh_file
    status
}

function work() {
    cp $work_ssh $ssh_file
    status
}

function status(){
    hash_current=$( sha256sum $ssh_file | grep -o "^\w*\b")
    case $hash_current in
        "$( sha256sum $personal_ssh | grep -o "^\w*\b")")
            echo "SSH key in use is personal"
        ;;
        "$(sha256sum $work_ssh | grep -o "^\w*\b")")
            echo "SSH key in use is work"
        ;;
        *)
            echo "Unknown hash for config"
        ;;
    esac
}

function verify(){
    status
    echo $(ssh -T git@github.com)
}

function helpMessage(){
    echo "personal - use personal SSH key"
    echo "work - use work SSH key"
    echo "status - see which SSH key is currently configured"
    echo "verify - SSH to GitHub to verify that the correct SSH key is in use"
    echo "help - display this help message"
}

case "$@" in
    "personal" | "p")
        personal
    ;;
    "work" | "w")
        work
    ;;
    "status" | "s")
        status
    ;;
    "verify" | "v")
        verify
    ;;
    "help" | "h")
        helpMessage
    ;;
    *)
        echo "Invalid argument"
        helpMessage
    ;;
esac