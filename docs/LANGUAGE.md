---
name: tech-language-cli
description: "Referencia de lenguaje técnico correcto para CLI, X11/Wayland, TMUX, Neovim"
metadata:
  node_type: memory
  type: reference
  originSessionId: 3edf3d9a-1ea0-4e07-8b10-ce089e0f9c2d
  modified: 2026-10-04T17:16:56.879Z
---

# Guía de Lenguaje Técnico para Desarrollo CLI

Referencia de términos correctos para usar en enseñanza y documentación técnica.

## Sistema Operativo & Consolas

### TTY (Terminal Virtual / Consola)
- **Correcto**: "TTY", "Virtual Terminal", "Consola text-only", "Teletipo"
- **Incorrecto**: "Pantalla negra", "Terminal de comandos", "Consola"
- **Acceso**: Ctrl+Alt+F1-F6 (Linux)
- **Comando para ver**: `tty`
- **Ejemplo de uso**: "Estamos en una TTY, sin servidor gráfico"

### DISPLAY & Protocolo Gráfico
- **Correcto**: "Servidor X11", "Servidor Wayland", "Protocolo gráfico", "DISPLAY"
- **Incorrecto**: "Pantalla", "Interfaz", "Ventanas del sistema"
- **Variable**: `$DISPLAY` (ej: `:0`, `:1`)
- **Verificar**: `echo $DISPLAY` o `echo $WAYLAND_DISPLAY`
- **Ejemplo correcto**: "Firefox requiere un servidor gráfico activo (X11 o Wayland)"

### Sesión Gráfica
- **Correcto**: "Sesión X11", "Sesión Wayland", "Instanciar un display"
- **Incorrecto**: "Abrir el escritorio", "Iniciar la GUI"
- **Iniciar**: `startx` (lanza X11 + window manager)
- **Login manager**: GDM, SDDM, LightDM (inicia automáticamente la sesión gráfica)

---

## Terminal & Shell

### Lanzar/Instanciar Procesos
- **Correcto**: "Instanciar", "Lanzar", "Ejecutar", "Invocar"
- **Incorrecto**: "Abrir", "Activar", "Prender"
- **Ejemplo**: `ff &` = "Lanzar Firefox en background"

### Background & Foreground (Procesos)
- **Background**: Proceso que corre sin bloquear la terminal (`&`)
- **Foreground**: Proceso que bloquea hasta terminarse
- **Forkear**: Crear un proceso hijo que se ejecuta independientemente
- **Desvincularse (disown)**: Separar un proceso del shell actual
- **Comando**: `firefox &` + `disown` = Lanzar en background y desvincularse

```bash
# Lanzar en background
firefox &

# Desvincularse (para que no cierre al cerrar terminal)
disown

# Juntos
firefox & disown
```

### Redirección & Piping
- **Redirección `>`**: "Redirigir salida a archivo"
  - `ls > archivos.txt` = Guardar listado en archivo
- **Redirección `2>`**: "Redirigir errores a archivo"
  - `command 2> errores.txt` = Guardar errores
- **Redirección `>/dev/null`**: "Descartar salida"
  - `firefox >/dev/null 2>&1 &` = Lanzar sin ver logs
- **Pipe `|`**: "Pasar salida a otro comando"
  - `ps aux | grep firefox` = Buscar firefox en procesos

### Variables de Entorno
- **Correcto**: "Exportar variable", "Variable de entorno", "Heredar variable"
- **Comando**: `export VAR=valor`
- **Verificar**: `echo $VAR`
- **Ejemplo**: `DISPLAY=:0 firefox` = Ejecutar firefox con DISPLAY específico

---

## TMUX (Terminal Multiplexer)

### Conceptos Base
| Término | Descripción | Acceso |
|---------|-------------|--------|
| **Sesión** | Contexto independiente con múltiples ventanas | `tmux new-session -s nombre` |
| **Ventana** | Pestaña dentro de una sesión | `Ctrl+B c` (crear), `Ctrl+B n` (siguiente) |
| **Pane (Panel)** | Subdivisión de ventana (split) | `Ctrl+B %` (vertical), `Ctrl+B "` (horizontal) |
| **Prefijo (Prefix)** | Atajo que activa comandos TMUX | `Ctrl+B` (default) |

### Acciones Comunes
- **Instanciar sesión**: `tmux new-session -s dev`
- **Attacharse**: `tmux attach-session -t dev`
- **Crear ventana**: `Ctrl+B c`
- **Split vertical**: `Ctrl+B %`
- **Split horizontal**: `Ctrl+B "`
- **Navegar paneles**: `Ctrl+B <flecha>`
- **Redimensionar**: `Ctrl+B Ctrl+<flecha>`
- **Ver sesiones**: `tmux list-sessions`

### Lenguaje Correcto
- **Correcto**: "Crear una sesión TMUX", "Attacharse a una sesión", "Split vertical/horizontal"
- **Incorrecto**: "Abrir una ventana", "Partir la pantalla", "Conectarse a TMUX"

---

## Neovim (Editor Modal)

### Modos
| Modo | Entrada | Salida | Propósito |
|------|---------|--------|-----------|
| **NORMAL** | Esc | Edición y navegación |
| **INSERT** | `i`, `a`, `o` | Esc | Escribir texto |
| **VISUAL** | `v`, `V` | Esc | Seleccionar texto |
| **COMMAND** | `:` | Esc | Ejecutar comandos |

### Acciones Fundamentales
- **Navegar**: `h/j/k/l` (NO con Ctrl, para no conflictuar con TMUX)
  - Alternativas: `w` (palabra), `e` (fin), `b` (atrás), `$` (fin línea), `^` (inicio)
- **Borrar**: `d` + movimiento (ej: `dd` = línea completa)
- **Cambiar**: `c` + movimiento (ej: `cc` = reemplazar línea)
- **Copiar**: `y` + movimiento (ej: `yy` = copiar línea)
- **Pegar**: `p` (después) / `P` (antes)
- **Buscar**: `/texto` (adelante) o `?texto` (atrás)
- **Reemplazar**: `:%s/viejo/nuevo/g` (toda el archivo)

### Lenguaje Correcto
- **Correcto**: "Modo normal", "Modo insert", "Modo visual", "Entrar en insert mode"
- **Incorrecto**: "Modo de edición", "Modo de navegación", "Modo comandos"
- **Acción**: `yy` = "Copiar línea" (no "copia línea", es un comando)

---

## X11 & DISPLAY - Casos de Uso

### Caso 1: Firefox desde TMUX (X11 activo)
```bash
# Simplemente:
firefox &
```

### Caso 2: Firefox desde TTY (X11 corre en otra TTY)
```bash
# Especificar DISPLAY:
DISPLAY=:0 firefox &
disown
```

### Caso 3: Firefox desde TMUX en máquina remota (ssh)
```bash
# Exportar DISPLAY local:
ssh -X usuario@host
firefox &  # Abrirá en tu máquina local
```

### Lenguaje para Enseñar
- "Firefox **requiere** un servidor gráfico activo"
- "El DISPLAY señala **dónde** renderizar ventanas"
- "Con Ctrl+Alt+F1 entras a una TTY (sin protocolo gráfico)"
- "Ctrl+Alt+F7 regresa a X11/Wayland"

---

## Errores Comunes & Correcciones

### Error 1: "No se puede abrir Firefox desde la consola"
- **Raíz**: TTY literal (sin servidor X11/Wayland)
- **Solución correcta**: "No puedes instanciar Firefox desde una TTY text-only; necesitas una sesión X11 activa"
- **Comando**: `Ctrl+Alt+F7` para volver a X11

### Error 2: "¿Cómo hago que Firefox no bloquee la terminal?"
- **Respuesta correcta**: "Forkea el proceso usando `&` y desvinculalo con `disown`"
- **Comando**: `firefox & disown`

### Error 3: "¿Cómo veo dónde está Firefox si lo lancé en background?"
- **Respuesta**: "Usa `ps aux | grep firefox` para ver procesos, o `pgrep -l firefox`"

---

## Resumen Rápido - Cheat Sheet

```bash
# DISPLAY & X11
echo $DISPLAY                          # Ver servidor gráfico activo
DISPLAY=:0 comando &                   # Ejecutar hacia otro DISPLAY
Ctrl+Alt+F7                            # Ir a sesión X11 (desde TTY)
Ctrl+Alt+F1                            # Ir a TTY1 (desde X11)

# PROCESOS EN BACKGROUND
firefox &                              # Forkear
disown                                 # Desvincularse
firefox >/dev/null 2>&1 &             # Ocultar logs

# TMUX
tmux new-session -s dev               # Instanciar sesión
tmux attach -t dev                    # Attacharse
Ctrl+B c                              # Crear ventana
Ctrl+B %                              # Split vertical

# NEOVIM
:wq                                    # Guardar y salir
:q!                                    # Salir sin guardar
/patrón                               # Buscar
:%s/viejo/nuevo/g                     # Reemplazar todo
```

---

## Para Enseñanza

**Punto clave**: Entender la **diferencia entre TTY (text-only) y servidor gráfico** es fundamental para dominar el workflow CLI profesional.

- **Alumnos confunden**: terminal (programa) con TTY (consola del sistema)
- **Alumnos confunden**: "abrir" con "instanciar" / "lanzar"
- **Alumnos confunden**: "pantalla" con "DISPLAY" o "servidor X11"

**Recomendación**: Hacer ejercicio práctico:
1. Abrir Firefox desde TMUX ✓
2. Ver DISPLAY con `echo $DISPLAY` ✓
3. Presionar Ctrl+Alt+F1 → TTY literal
4. Intentar lanzar Firefox → Falla (sin servidor gráfico)
5. Especificar DISPLAY explícitamente `DISPLAY=:0 firefox &`
6. Volver a X11 con Ctrl+Alt+F7 → ¡Firefox aparece!
