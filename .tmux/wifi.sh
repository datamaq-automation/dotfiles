#!/bin/bash
# Script para mostrar conexión WiFi actual + potencia en tmux

get_wifi_info() {
    # Intentar con nmcli primero (NetworkManager)
    if command -v nmcli &> /dev/null; then
        wifi_data=$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep "^yes")
        if [ -n "$wifi_data" ]; then
            ssid=$(echo "$wifi_data" | cut -d: -f2)
            signal=$(echo "$wifi_data" | cut -d: -f3)
            echo "$ssid|$signal"
            return 0
        fi
    fi

    # Fallback a iwconfig si está disponible
    if command -v iwconfig &> /dev/null; then
        ssid=$(iwconfig 2>/dev/null | grep "ESSID" | grep -oP '(?<=ESSID:")[^"]*' | head -1)
        if [ -n "$ssid" ]; then
            # Extraer potencia de señal en dBm
            signal=$(iwconfig 2>/dev/null | grep "Signal level" | grep -oP '(?<=Signal level=)[^ ]*' | head -1)
            echo "$ssid|$signal"
            return 0
        fi
    fi

    return 1
}

# Determinar color según potencia
get_signal_color() {
    local signal=$1
    if [[ "$signal" =~ ^-?[0-9]+$ ]]; then
        # Si es dBm (negativo), convertir a porcentaje: -30 dBm = 100%, -90 dBm = 0%
        if [ "$signal" -gt 0 ]; then
            # Es porcentaje directo (0-100)
            if [ "$signal" -ge 70 ]; then
                echo "#98c379"  # Verde: fuerte
            elif [ "$signal" -ge 40 ]; then
                echo "#e5c07b"  # Amarillo: medio
            else
                echo "#e06c75"  # Rojo: débil
            fi
        else
            # Es dBm, convertir mentalmente pero mostrar tal cual
            echo "#98c379"
        fi
    else
        echo "#e0e0e0"  # Gris por defecto
    fi
}

wifi_info=$(get_wifi_info 2>/dev/null)

if [ -n "$wifi_info" ]; then
    ssid=$(echo "$wifi_info" | cut -d'|' -f1)
    signal=$(echo "$wifi_info" | cut -d'|' -f2)

    # Truncar SSID si es muy largo (máx 12 caracteres)
    if [ ${#ssid} -gt 12 ]; then
        ssid="...$(echo "$ssid" | rev | cut -c1-9 | rev)"
    fi

    signal_color=$(get_signal_color "$signal")
    echo "#[fg=#98c379]$ssid#[fg=$signal_color] ${signal}%"
else
    echo "#[fg=#e06c75]offline"
fi
