#!/bin/bash
# Script para mostrar porcentaje y estado de batería en tmux

get_battery_info() {
    for bat in /sys/class/power_supply/BAT*; do
        if [ -r "$bat/capacity" ] && [ -r "$bat/status" ]; then
            capacity=$(cat "$bat/capacity")
            status=$(cat "$bat/status")
            echo "$capacity:$status"
            return 0
        fi
    done
    return 1
}

info=$(get_battery_info 2>/dev/null) || exit 0
capacity="${info%%:*}"
status="${info##*:}"

case "$status" in
    "Charging")
        echo "#[fg=#98c379]⬆ ${capacity}%"
        ;;
    "Discharging")
        echo "#[fg=#e06c75]⬇ ${capacity}%"
        ;;
    "Full"|"Not charging")
        echo "#[fg=#61afef]= ${capacity}%"
        ;;
    *)
        echo "#[fg=#abb2bf]? ${capacity}%"
        ;;
esac
