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

    return 1
}

ssid=$(get_wifi 2>/dev/null)

if [ -n "$ssid" ]; then
    # Truncar SSID si es muy largo (máx 15 caracteres)
    if [ ${#ssid} -gt 15 ]; then
        ssid="${ssid:0:12}..."
    fi
    echo "#[fg=#61afef]$ssid"
else
    echo "#[fg=#e06c75]⚠"
fi
