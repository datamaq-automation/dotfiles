#!/bin/bash
# Script para mostrar conexión a internet en tmux

check_internet() {
    # Usar timeout corto para no bloquear tmux
    # Intentar ping a múltiples servidores DNS públicos
    if timeout 2 ping -c 1 -W 1 8.8.8.8 &> /dev/null; then
        echo "online"
        return 0
    elif timeout 2 ping -c 1 -W 1 1.1.1.1 &> /dev/null; then
        echo "online"
        return 0
    else
        echo "offline"
        return 1
    fi
}

status=$(check_internet 2>/dev/null)

case "$status" in
    "online")
        echo "#[fg=#98c379]on"
        ;;
    *)
        echo "#[fg=#e06c75]off"
        ;;
esac
