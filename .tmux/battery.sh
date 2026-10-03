#!/bin/bash
# Script para mostrar porcentaje, estado y tiempo restante de batería en tmux

get_battery_info() {
    for bat in /sys/class/power_supply/BAT*; do
        if [ -r "$bat/capacity" ] && [ -r "$bat/status" ]; then
            capacity=$(cat "$bat/capacity")
            status=$(cat "$bat/status")

            # Intentar leer energy_now/energy_full primero
            if [ -r "$bat/energy_now" ] && [ -r "$bat/energy_full" ]; then
                energy_now=$(cat "$bat/energy_now")
                energy_full=$(cat "$bat/energy_full")
                power_now=$(cat "$bat/power_now" 2>/dev/null || echo "0")
            # Si no, intentar con charge_now/charge_full
            elif [ -r "$bat/charge_now" ] && [ -r "$bat/charge_full" ]; then
                energy_now=$(cat "$bat/charge_now")
                energy_full=$(cat "$bat/charge_full")
                power_now=$(cat "$bat/current_now" 2>/dev/null || echo "0")
            else
                echo "0:$status:0:0:0"
                return 0
            fi

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

    if [ "$power_now" -eq 0 ] 2>/dev/null; then
        echo "0m"
        return
    fi

    local energy_remaining
    if [ "$status" = "Discharging" ]; then
        energy_remaining=$energy_now
    else
        energy_remaining=$((energy_full - energy_now))
    fi

    # Calcular minutos usando awk para evitar pérdida en división entera
    local minutes=$(awk "BEGIN {printf \"%.0f\", ($energy_remaining / $power_now) * 60}")
    printf "%dm" "$minutes"
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
        echo "#[fg=#98c379]+${capacity}% ${time_str}"
        ;;
    "Discharging")
        echo "#[fg=#e06c75]-${capacity}% ${time_str}"
        ;;
    "Full"|"Not charging")
        echo "#[fg=#56b6c2]=${capacity}%"
        ;;
    *)
        echo "#[fg=#56b6c2]?${capacity}% ${time_str}"
        ;;
esac
