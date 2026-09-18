#!/usr/bin/env python3
"""
Script de Observabilidad y Análisis de Logs de Aider (~/.aider/log_analyzer.py)
Filtra el ruido y genera un resumen estructurado de uso, costos y eficiencia.
"""

import json
from datetime import datetime
from pathlib import Path

LOG_FILE = Path.home() / ".aider" / "analytics.log"


def analyze_logs():
    if not LOG_FILE.exists():
        print(f"⚠️ No se encontró el archivo de log en {LOG_FILE}")
        return

    sessions = 0
    total_tokens_sent = 0
    total_tokens_received = 0
    total_cost = 0.0
    models_used = {}

    print("\n📊 --- REPORTES DE OBSERVABILIDAD Y METRICAS DE AIDER ---")
    print(f"📅 Fecha de informe: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"📁 Log Origen: {LOG_FILE}\n" + "-" * 55)

    with open(LOG_FILE, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                data = json.loads(line)
                sessions += 1

                # Extraer modelo
                model = data.get("model", "desconocido")
                models_used[model] = models_used.get(model, 0) + 1

                # Extraer tokens y costo
                prompt_tokens = data.get("prompt_tokens", 0) or 0
                completion_tokens = data.get("completion_tokens", 0) or 0
                cost = data.get("cost", 0.0) or 0.0

                total_tokens_sent += prompt_tokens
                total_tokens_received += completion_tokens
                total_cost += cost

            except json.JSONDecodeError:
                # Si la línea no es JSON estructurado, se ignora el ruido no formateado
                continue

    print(f"🔢 Sesiones Registradas: {sessions}")
    print(f"⬆️  Tokens de Entrada (Sent): {total_tokens_sent:,}")
    print(f"⬇️  Tokens de Salida (Received): {total_tokens_received:,}")
    print(f"💰 Costo Total Acumulado: ${total_cost:.4f} USD")
    print("\n🤖 Distribución por Modelo:")
    for model, count in models_used.items():
        print(f"   • {model}: {count} sesión(es)")

    print("\n💡 Recomendación de Iteración:")
    if total_tokens_sent > 50000:
        print("   ⚠️ Los tokens de entrada son elevados. Considera ejecutar /clear frecuentemente dentro de Aider.")
    else:
        print("   ✅ El consumo de tokens se mantiene en rangos óptimos.")
    print("-" * 55)


if __name__ == "__main__":
    analyze_logs()
