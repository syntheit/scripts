#!/bin/bash

# Sets the scheduler and power profile.  check() will apply depending on the AC power state.  Useful for laptops
# udev rules that trigger this script on AC connect and disconnect are located in this same folder

# Tested on Fedora 36

function performance() {
    powerprofilesctl set performance
    output=$(echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor)
    status
}

function balanced() {
    powerprofilesctl set balanced
    output=$(echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor)
    status
}

function powersaver() {
    powerprofilesctl set power-saver
    output=$(echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor)
    status
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

function status() {
    cpu_power_profile=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    powerprofilesctl_profile=$(powerprofilesctl get)
    if [[ "$cpu_power_profile" == "$powerprofilesctl_profile" ]]; then
        echo "$cpu_power_profile"
        elif [[ $cpu_power_profile == "powersave" && $powerprofilesctl_profile == "power-saver" ]]; then
        echo "powersave"
        elif [[ $cpu_power_profile == "schedutil" && $powerprofilesctl_profile == "balanced" ]]; then
        echo "balanced"
    else
        echo "CPU scaling governor: $cpu_power_profile
powerprofilesctl: $powerprofilesctl_profile"
    fi
}

function helpMessage() {
    echo "Usage:

Power profiles:
    - performance
    - balanced
{ power-profile-name } - sets the power profile, look above for available profiles
status - view the in use power profile
check - set the power profile based on AC power state
    help - display this help message"
}

case "$@" in
    "performance" | "perf" | "0")
        performance
    ;;
    "balanced" | "bal" | "1")
        balanced
    ;;
    "powersave" | "powersaver" | "saver" | "save" | "2")
        powersaver
    ;;
    "check" | "c")
        check
    ;;
    "status" | "s")
        status
    ;;
    "help" | "h")
        helpMessage
    ;;
    *)
        echo "Invalid argument
        "
        helpMessage
    ;;
esac