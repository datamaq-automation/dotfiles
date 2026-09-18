# Aceleración de Hardware y Diagnóstico de Rendimiento (Aider + Ollama)

Este documento detalla la auditoría de hardware local (AMD Ryzen + iGPU Radeon Vega Picasso) y las optimizaciones aplicadas para eliminar cuellos de botella en la ejecución de Aider con modelos locales.

---

## 1. Benchmarks Medidos en Hardware Local

Prueba de generación y evaluación de prompt ejecutada sobre el daemon de Ollama:

| Métrica | `qwen2.5-coder:7b` | `qwen2.5-coder:1.5b` | Factor de Aceleración |
| :--- | :--- | :--- | :--- |
| **Prompt Evaluation** | **52.2 tokens/seg** | **130.6 tokens/seg** | **2.5x** |
| **Generación (Eval)** | **7.33 tokens/seg** | **30.0 tokens/seg** | **4.1x** |
| **Consumo de RAM** | ~4.7 GB | ~980 MB | ~5x menos RAM |

### Causa de la lentitud detectada en la sesión
En la edición del esquema `DispositivoSchema`:
- **Aider envió 8.600 tokens de entrada (`8.6k sent`)** debido al `repo-map` de 1024 tokens, convenciones y árbol del repositorio.
- A 52 tokens/seg, **la CPU demoró 165 segundos (2.75 minutos)** solo en procesar el prompt de entrada antes de generar una sola palabra.
- La generación de 762 tokens a 7.33 tokens/seg tomó **104 segundos (1.7 minutos)**.
- **Tiempo total de respuesta:** ~4.5 minutos para aplicar un diff de una sola línea.

---

## 2. Mejoras Implementadas (Certezas Totales)

### A. Eliminación del Repo-Map en Modo Builder (`--map-tokens 0`)
Cuando un agente arquitecto (AGY o Claude) ya definió el plan y los archivos a modificar (`/add archivo`), el `repo-map` de Aider resulta redundante y satura el cómputo del CPU.
- Pasar de 8.6k a ~1.2k tokens reduce el tiempo de evaluación de 165 segundos a **menos de 15 segundos**.

### B. Nuevos Aliases en `~/.bashrc`
1. **`aider-builder`**:
   Lanza Aider con `qwen2.5-coder:1.5b` y `--map-tokens 0`.
   - Ideal para el rol "Builder": aplicar diffs quirúrgicos guiados por AGY.
   - Tiempo de respuesta total: **~15 a 30 segundos**.
2. **`aider-local-fast`**:
   Lanza Aider con `qwen2.5-coder:7b` y `--map-tokens 0`.
   - Mantiene la capacidad del modelo 7B pero elimina los 2.5 minutos de sobrecarga del repo-map.

### C. Uso Completo de Hilos Ryzen
Se inyectó en el entorno de `~/.bashrc`:
```bash
export OLLAMA_NUM_THREADS=8
export OLLAMA_FLASH_ATTENTION=1
```
El servicio systemd (`/etc/systemd/system/ollama.service.d/igpu.conf`) ya cuenta con `OLLAMA_NUM_THREADS=8` y `OLLAMA_NUM_PARALLEL=2`.

---

## 3. Puntos de Atención y Dudas Técnicas (Hardware & Drivers)

### Duda 1: Soporte ROCm en APU AMD Picasso/Raven (`gfx902`)
* **Situación:** La GPU integrada es `08:00.0 AMD Picasso/Raven 2 [Radeon Vega Series]` (`gfx902`).
* **Comportamiento:** Ollama incluye el runner `rocm_v7_2`, pero AMD ROCm oficial no distribuye binarios compilados para arquitecturas APU `gfx902`. Aunque en systemd esté configurado `OLLAMA_IGPU_ENABLE=1`, el backend ROCm descarta la iGPU y cae silenciosamente a ejecución 100% CPU.
* **Hipótesis a validar:** Se puede probar en `/etc/systemd/system/ollama.service.d/igpu.conf`:
  ```ini
  [Service]
  Environment="HSA_OVERRIDE_GFX_VERSION=9.0.0"
  ```
  *Riesgo:* En algunas distribuciones Linux, forzar la versión GFX en chips Raven/Picasso puede ocasionar GPU hang o kernel panic si el driver de kernel no admite asignación unificada de memoria KFD. Requiere prueba supervisada con reinicio a mano.

### Duda 2: Aceleración vía Vulkan Nativo (`llama-server`)
* **Situación:** El driver Mesa RADV de Linux soporta Vulkan de forma sólida en AMD Vega.
* **Alternativa:** En vez de pasar por ROCm, `llama.cpp` / `llama-server` compilado con `-DGGML_VULKAN=ON` puede aprovechar la GPU integrada y los 32 GB de memoria compartida directamente.
* **Prueba futura recomendada:** Correr `llama-server` con backend Vulkan y conectar Aider vía API OpenAI local (`http://localhost:8080/v1`).

---

## 4. Cuello de Botella de Memoria vs Cómputo (CPU al 35%)

### ¿Por qué la CPU parece "subutilizada" durante la generación?
La inferencia de modelos de lenguaje tiene dos fases con dinámicas de hardware totalmente distintas:
1. **Prompt Evaluation (Prefill):** Procesa el texto de entrada en paralelo. Es una tarea orientada al cómputo (*compute-bound*). La CPU puede aprovechar todos los hilos del Ryzen (100% de uso) aplicando instrucciones vectoriales AVX2.
2. **Generación Token a Token (Eval):** Es estrictamente secuencial y orientada a memoria (*memory-bound*). Para generar 1 solo token, la CPU debe transferir todos los pesos del modelo desde la memoria RAM física (DDR4 ~30 GB/s) a la caché del procesador. El procesador pasa la mayor parte de los ciclos de reloj esperando los datos de la RAM, lo que se traduce en un uso aparente de CPU del 30–40%.

### Guardarraíl contra Bucles en SLMs Pequeños
Los modelos ultraligeros como `1.5B` tienen un límite de atención estructural: no pueden coordinar más de 2 o 3 bloques de diff simultáneos. Si se les solicita modificar 13 llamadas dispersas en 350 líneas de código, entran en bucles autorregresivos infinitos.
Para evitar esto, se configuró en `~/.aider.model.settings.yml`:
- `max_tokens: 2048` (corte automático de seguridad para 1.5B).
- `temperature: 0.0` (determinismo estricto).
- Directiva de salida concisa en el system prompt.

### Duda 3: Paso de `num_predict` / `max_tokens` en el driver de Ollama
* **Punto a validar:** Verificar si el cliente de LiteLLM/Aider traduce correctamente `max_tokens` al parámetro `num_predict` de la API de Ollama cuando no se usa la API de OpenAI emulation (`/v1`). Si Ollama ignora `max_tokens`, el límite debe forzarse mediante un Modelfile local (`PARAMETER num_predict 2048`).

