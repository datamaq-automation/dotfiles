#!/bin/bash
# Script para mostrar porcentaje, estado y tiempo restante de batería en tmux

get_battery_info() {
    for bat in /sys/class/power_supply/BAT*; do
        if [ -r "$bat/capacity" ] && [ -r "$bat/status" ]; then
            capacity=$(cat "$bat/capacity")
            status=$(cat "$bat/status")
            energy_now=$(cat "$bat/energy_now" 2>/dev/null || echo "0")
            energy_full=$(cat "$bat/energy_full" 2>/dev/null || echo "0")
            power_now=$(cat "$bat/power_now" 2>/dev/null || echo "1")
            echo "$capacity:$status:$energy_now:$energy_full:$power_now"
            return 0
        fi
    done
    return 1
}

calculate_time() {
    local energy_now=$1
    local energy_full=$2
    local power_now=$3
    local status=$4

    [ "$power_now" -eq 0 ] && echo "0h 0m" && return

    local energy_remaining
    if [ "$status" = "Discharging" ]; then
        energy_remaining=$energy_now
    else
        energy_remaining=$((energy_full - energy_now))
    fi

    local minutes=$(( energy_remaining / power_now ))
    local hours=$(( minutes / 60 ))
    local mins=$(( minutes % 60 ))
    printf "%dh %dm" "$hours" "$mins"
}

info=$(get_battery_info 2>/dev/null) || exit 0
capacity="${info%%:*}"
status="${info#*:}"; status="${status%%:*}"
energy_now="${info#*:*:}"; energy_now="${energy_now%%:*}"
energy_full="${info#*:*:*:}"; energy_full="${energy_full%%:*}"
power_now="${info##*:}"

time_str=$(calculate_time "$energy_now" "$energy_full" "$power_now" "$status")

case "$status" in
    "Charging")
        echo "#[fg=#98c379]⬆ ${capacity}% (${time_str})"
        ;;
    "Discharging")
        echo "#[fg=#e06c75]⬇ ${capacity}% (${time_str})"
        ;;
    "Full"|"Not charging")
        echo "#[fg=#61afef]= ${capacity}%"
        ;;
    *)
        echo "#[fg=#abb2bf]? ${capacity}% (${time_str})"
        ;;
esac
