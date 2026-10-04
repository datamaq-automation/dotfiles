#!/bin/bash
# Script para mostrar estado del sistema en Zelij

show_status() {
    while true; do
        clear

        # Hora y fecha
        echo -n "📅 "
        date "+%H:%M %d/%m"
        echo

        # Batería
        echo -n "🔋 "
        bash /home/agustin/.tmux/battery.sh | sed 's/#\[fg=[^]]*\]//g'

        # WiFi
        echo -n "📡 "
        bash /home/agustin/.tmux/wifi.sh | sed 's/#\[fg=[^]]*\]//g'

        # Internet
        echo -n "🌐 "
        bash /home/agustin/.tmux/internet.sh | sed 's/#\[fg=[^]]*\]//g'

        echo
        echo "---"

        sleep 5
    done
}

show_status
