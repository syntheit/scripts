#!/bin/bash

# Sets the scheduler and power profile.  check() will apply depending on the AC power state.  Useful for laptops
# udev rules that trigger this script on AC connect and disconnect are located in this same folder

# Tested on Fedora 36

function performance(){
    powerprofilesctl set performance
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
}

function balanced(){
    powerprofilesctl set balanced
    echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
}

function check(){
    ac_adapter=$(acpi -a | cut -d' ' -f3 | cut -d- -f1)
    if [ "$ac_adapter" = "on" ]; then
        logger "AC connected.  Setting power profile to performance."
        performance
    else
        logger "AC disconnected.  Setting power profile to balanced."
        balanced
    fi
}

if [[ "$@" == "performance" || "$@" == "perf" ]]; then
    performance
    elif [[ "$@" == "balanced" || "$@" == "bal" ]]; then
    balanced
    elif [[ "$@" == "help" ]]; then
    echo "Power options: "
    echo "performance"
    echo "balanced"
    elif [[ -z "$@" ]]; then
    echo "No argument provided"
else
    echo "Invalid argument"
fi
