#!/usr/bin/env python3
"""
Evaluador y Selector Inteligente de Proveedor / Ventana Tarifaria (~/.aider/provider_selector.py)
Determina si conviene usar DeepSeek Cloud (tarifa no pico 50% OFF) o fallback a Ollama local ($0).
Reglas DeepSeek (Agosto 2026):
- Fines de semana (Sábado y Domingo): Tarifa no pico las 24 hs (100% elegible).
- Lunes a Viernes:
    * Pico: 01:00-04:00 UTC y 06:00-10:00 UTC (En Argentina UTC-3: 22:00-01:00 y 03:00-07:00)
    * No Pico (50% OFF): 07:00 a 22:00 ART y 01:00 a 03:00 ART
"""

import sys
from datetime import datetime, timezone


def is_deepseek_offpeak():
    now_utc = datetime.now(timezone.utc)
    # weekday: 0=Lunes, 6=Domingo
    weekday = now_utc.weekday()

    # 1. Fines de semana: siempre no pico (desde 23 de agosto de 2026)
    if weekday in (5, 6):
        return True, "Fin de semana (24h tarifa reducida 50% OFF)"

    hour = now_utc.hour
    minute = now_utc.minute
    total_minutes = hour * 60 + minute

    # Ventanas pico en UTC:
    # 01:00 - 04:00 UTC -> [60, 240) min
    # 06:00 - 10:00 UTC -> [360, 600) min
    is_peak = (60 <= total_minutes < 240) or (360 <= total_minutes < 600)

    if not is_peak:
        return True, "Día hábil en horario NO pico (50% OFF)"
    else:
        return False, "Día hábil en HORARIO PICO (Tarifa estándar)"


def main():
    offpeak, reason = is_deepseek_offpeak()
    now_local = datetime.now()
    time_str = now_local.strftime("%H:%M:%S")

    if "--check" in sys.argv:
        print(f"[{time_str}] {reason}")
        sys.exit(0 if offpeak else 1)

    # Retornar flags para Aider
    if offpeak:
        # En horario no pico es conveniente DeepSeek Cloud
        print("--model deepseek/deepseek-chat")
    else:
        # En horario pico, usar Ollama local para ahorrar créditos
        print("--model ollama/qwen2.5-coder:7b")


if __name__ == "__main__":
    main()
