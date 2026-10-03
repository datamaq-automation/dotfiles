#!/bin/bash
# Script para mostrar conexión WiFi actual en tmux

get_wifi() {
    # Intentar con nmcli primero (NetworkManager)
    if command -v nmcli &> /dev/null; then
        ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep "^yes" | cut -d: -f2)
        if [ -n "$ssid" ]; then
            echo "$ssid"
            return 0
        fi
    fi

    # Fallback a iwconfig si está disponible
    if command -v iwconfig &> /dev/null; then
        ssid=$(iwconfig 2>/dev/null | grep "ESSID" | grep -oP '(?<=ESSID:")[^"]*' | head -1)
        if [ -n "$ssid" ]; then
            echo "$ssid"
            return 0
        fi
    fi

    # Si no hay conexión WiFi, retornar estado offline
    echo "offline"
    return 1
}

ssid=$(get_wifi 2>/dev/null)

case "$ssid" in
    "offline")
        echo "#[fg=#e06c75]📡 disconnected"
        ;;
    "")
        echo "#[fg=#e06c75]📡 unknown"
        ;;
    *)
        echo "#[fg=#61afef]📡 $ssid"
        ;;
esac
