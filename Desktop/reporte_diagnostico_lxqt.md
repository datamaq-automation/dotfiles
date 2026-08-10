# Reporte Técnico Detallado: Diagnóstico y Configuración de LXQt

**Fecha:** 9 de Agosto de 2026
**Usuario:** agustin
**Entorno:** LXQt / KWin 6.7.2 / PCManFM-Qt (X11)
**Ubicación del reporte:** `/home/agustin/Desktop/reporte_diagnostico_lxqt.md` (y `/home/agustin/Escritorio/reporte_diagnostico_lxqt.md`)

---

## 1. Resumen Ejecutivo

Se realizaron diagnósticos y correcciones sobre la tecla física Super (Windows) para togglear el menú FancyMenu de LXQt. El diagnóstico inicial identificó dos problemas (fondo de pantalla y tecla Super). El fondo de pantalla se resolvió. La tecla Super presentó una regresión el 9-ago-2026: abría el menú pero no lo cerraba.

### Diagnóstico final (confirmado con investigación)

**Causa raíz:** El daemon `lxqt-superkey` usa `XGrabKey` (passive grab). Cuando FancyMenu está abierto, Qt ejecuta `XGrabKeyboard` (active grab). La especificación X11 establece que *los passive grabs no se activan si hay un active grab vigente*. Por lo tanto:

- **Menú cerrado:** sin grab activo → `XGrabKey` recibe Super → inyecta Alt+F1 → abre ✅
- **Menú abierto:** Qt tiene `XGrabKeyboard` → `XGrabKey` no se activa → el daemon nunca ve la segunda pulsación de Super → no puede inyectar nada para cerrar ❌

**Solución correcta:** Reescribir el daemon usando **XRecord** (como lo hacen `xcape` y `ksuperkey`), que observa pasivamente todos los eventos de teclado incluso durante grabs activos, en lugar de `XGrabKey` que compite por ellos.

### Línea de tiempo de la regresión

| Hora | Evento |
|---|---|
| 18:49 | Creado `lxqt-superkey.desktop` (autostart) |
| **18:57** | **Creado `plasma-kglobalaccel.desktop`** — kglobalacceld interfiere con el inicio del daemon |
| 21:01 | Sesión actual: daemon NO arranca |
| 21:21 | Agregado `[ModifierOnlyShortcuts] Meta=` en kwinrc (INERTE en KWin 6, fue pista falsa) |
| 22:02 | Detenido kglobalacceld (`systemctl --user stop`) |
| 22:06 | Daemon vivo: Super abre el menú (pero no cierra — problema del XGrabKey vs XGrabKeyboard) |

---

## 2. Corrección del Fondo de Pantalla (PCManFM-Qt)

### Diagnóstico Inicial
- **Resolución total del escritorio extendido:** `3286x1080` dividida en dos pantallas:
  - `HDMI-A-0` (Primario, 1920x1080)
  - `DisplayPort-0` (Secundario, 1366x768)
- **Configuración previa:** En `~/.config/pcmanfm-qt/lxqt/settings.conf`, el parámetro `PerScreenWallpaper` estaba en `false`. En este modo, PCManFM-Qt calcula el centro de la imagen sobre el canvas combinado (`3286x1080`), lo que provocaba que la imagen quedara dividida justo en el borde de separación entre ambos monitores.

### Solución Definitiva Aplicada
Se utilizó la API nativa de Qt mediante `PyQt6.QtCore.QSettings` para escribir la estructura exacta que requiere PCManFM-Qt:
```ini
[Desktop]
PerScreenWallpaper=true
ScreenNames=HDMI-A-0, DisplayPort-0
TransformWallpaper=false
Wallpaper=/home/agustin/Imágenes/wallhaven-486l61.jpg
Wallpaper\DisplayPort-0=/home/agustin/Imágenes/wallhaven-486l61.jpg
Wallpaper\HDMI-A-0=/home/agustin/Imágenes/wallhaven-486l61.jpg
WallpaperMode=center
WallpaperMode\DisplayPort-0=center
WallpaperMode\HDMI-A-0=center
```

---

## 3. Diagnóstico de la Tecla Super — Segunda Iteración (9-ago-2026 22:15)

### 3.1 Correcciones al diagnóstico inicial

1. **`[ModifierOnlyShortcuts] Meta=` en kwinrc es INERTE.** Verificación: la cadena `ModifierOnlyShortcuts` no existe en ningún binario de KWin 6.7.2 (`kwin_x11`, `libkwin.so.6.7.2`, plugins). Es un mecanismo de KWin 5 eliminado en KWin 6. Fue una coincidencia temporal, no la causa.

2. **La verdadera causa del daemon muerto fue `kglobalacceld`.** Creado su autostart a las 18:57. Aunque `kglobalacceld` rechaza explícitamente teclas Meta/Super en su código (`kglobalaccel_x11.cpp`), su presencia mediante XRecord interfería con el inicio del daemon. Al detenerlo (22:02), el daemon pudo iniciar (22:06).

3. **kglobalacceld es innecesario en LXQt.** KWin 6.7 procesa sus atajos in-process (`KGLOBALACCELD_PLATFORM=org.kde.kwin`). Alt+Tab, Meta+Left/Right, tiling, etc. no dependen del daemon externo.

### 3.2 ¿Por qué abre pero no cierra? (Investigación X11)

#### El problema: XGrabKey vs XGrabKeyboard

FancyMenu es un `QMenu` de Qt. En X11, Qt implementa los popups mediante **`XGrabKeyboard` activo** (confirmado en QTBUG-10508: *"The mechanism provided by X11 to implement popup menus is the global keyboard and mouse grab. All modern applications and toolkits use this mechanism, Qt included."*).

La especificación de X11 es clara (man page `XGrabKey(3)` y lista xorg):

> *"Passive grabs may only activate if there is no active grab on the device."*

**Consecuencia directa:**

| Estado del menú | Grab vigente | ¿El daemon recibe Super? | Resultado |
|---|---|---|---|
| CERRADO | Ninguno | Sí (XGrabKey se activa) | Inyecta Alt+F1 → ABRE ✅ |
| ABIERTO | XGrabKeyboard (Qt) | **No** (passive grab no se activa) | No puede inyectar nada ❌ |

`owner_events=False/True` no afecta esto: solo rige el comportamiento *durante* el grab activo del propio daemon, no durante grabs de otros clientes.

#### ¿Por qué XTest no ayuda?

Los eventos inyectados con `XTestFakeKeyEvent` **sí** llegan durante un active grab — pero al cliente que graba (el menú), no al daemon. Peor aún: `XTestFakeKeyEvent` para liberar Super antes de inyectar Escape/Alt+F1 **tampoco funciona** porque el evento de release va al grabador (Qt), no al daemon, y el estado de modificadores queda desincronizado.

### 3.3 La solución correcta: XRecord

**xcape** y **ksuperkey** (referencias canónicas para este problema) **no usan XGrabKey**. Usan **XRecord**:

- `XRecordCreateContext` + `XRecordEnableContext` observan **pasivamente** todos los eventos de teclado
- El spec de RECORD (sección 2.1.4): *"the recording of selected device events is not affected by server grabs"*
- XRecord no compite por grabs: ve los eventos pero no los consume
- Al detectar un tap de Super (press + release en <500ms sin otra tecla), inyecta Alt+F1 vía XTest

**Ventajas:**
- Ve todas las teclas incluso cuando Qt tiene XGrabKeyboard
- No genera BadAccess
- No interfiere con el estado de modificadores
- No requiere `XSetErrorHandler`
- Es el enfoque probado de `ksuperkey` (el usuario clonó el repo a `/tmp/ksuperkey_build/`)

### 3.4 Plan de implementación

#### Fase 1 — Mantener kglobalacceld fuera (ya hecho ✅)
- `~/.config/autostart/plasma-kglobalaccel.desktop` → `Enabled=false` ✅
- `systemctl --user stop plasma-kglobalaccel.service` ✅
- KWin 6.7 procesa atajos in-process, no necesita el daemon externo

#### Fase 2 — Reescribir el daemon con XRecord
- **Archivo:** `/home/agustin/.local/bin/lxqt-superkey`
- Reemplazar `XGrabKey` + `XNextEvent` por `XRecordCreateContext` + callback
- Detectar Super tap: press + release en <500ms sin otra tecla intermedia
- Inyectar Alt+F1 vía `XTestFakeKeyEvent` (con `XFlush`)
- Ignorar eventos auto-generados (marcar los keycodes que inyectamos)
- Agregar `XSetErrorHandler` como safety net
- Logging a stderr con timestamp

#### Fase 3 — Limpiar kwinrc (higiene)
- Eliminar `[ModifierOnlyShortcuts] Meta=` de `~/.config/kwinrc` (inerte en KWin 6)

#### Fase 4 — Verificación
- Super abre FancyMenu ✅
- Super cierra FancyMenu ✅
- Super togglea repetidamente (abrir→cerrar→abrir) ✅
- Alt+F1 físico sigue funcionando ✅
- Alt+Tab, Meta+Left/Right/Down/Up (tiling), Meta+D funcionan ✅
- Sin nuevos BadAccess en `.xsession-errors`

---

## 4. Comandos Útiles para Verificación y Control

- **Verificar que el daemon esté corriendo:**
  ```bash
  ps aux | grep lxqt-superkey | grep -v grep
  ```
- **Reiniciar el daemon manualmente:**
  ```bash
  pkill -9 -f lxqt-superkey
  /home/agustin/.local/bin/lxqt-superkey &
  ```
- **Verificar la configuración del fondo de pantalla:**
  ```bash
  grep -i -E 'wallpaper|screen' ~/.config/pcmanfm-qt/lxqt/settings.conf
  ```
- **Verificar que kglobalacceld NO está corriendo:**
  ```bash
  systemctl --user status plasma-kglobalaccel.service
  ```
- **Simular Alt+F1 para pruebas:**
  ```bash
  DISPLAY=:0 xdotool key "alt+F1"
  ```

---

## 5. Referencias

- [XGrabKey(3) man page](https://xorg.freedesktop.org/archive/X11R6.8.2/doc/XGrabKey.3.html)
- [xcape — XRecord-based modifier key daemon](https://github.com/peara/xcape)
- [ksuperkey — fork of xcape](https://github.com/hanschen/ksuperkey)
- [XRecord spec — events not affected by server grabs](https://www.x.org/releases/X11R7.6/doc/lib/Xext/recordlib.html)
- [QTBUG-10508 — Qt popup menus use XGrabKeyboard](https://bugreports.qt.io/browse/QTBUG-10508)
- [KWin 6.7.2 globalshortcuts.cpp — in-process shortcuts](https://sources.debian.org/src/kwin/4%3A6.7.2-1/src/globalshortcuts.cpp/)
- [kglobalacceld x11 plugin — rejects Meta/Super keys](https://sources.debian.org/src/kglobalacceld/6.7.2-2/src/plugins/xcb/kglobalaccel_x11.cpp/)

---

## 6. Tercera Iteración: XRecord (22:15–23:17) — FRACASÓ

### 6.1 Hipótesis

Tras confirmar que `XGrabKey` no recibe eventos durante `XGrabKeyboard` de Qt (sección 3.2), se investigó `XRecord` como alternativa. `XRecord` observa pasivamente eventos sin competir por grabs, y es el mecanismo usado por `xcape`/`ksuperkey`.

### 6.2 Intentos realizados

| Intento | Tecnología | Resultado |
|---|---|---|
| XRecord vía ctypes (1 conexión, async) | `XRecordEnableContextAsync` + polling | Callback llamado 1 vez (inicial vacía), nunca más |
| XRecord vía ctypes (2 conexiones, bloqueante) | `XRecordEnableContext` con hilo separado | Idem: solo el evento inicial `cat=0 len=0` |
| XRecord vía ctypes + `XRecordAllocRange` | Estructura asignada en C, offsets manuales | Idem: callback nunca recibe eventos de teclado |
| XRecord vía `python3-xlib` | `dpy.record_create_context()` | Error de serialización: `Record_Range8` espera dicts anidados que no coinciden con la API de `rq.Struct.to_binary` |
| Compilar `ksuperkey` desde `/tmp/ksuperkey_build/` | `gcc` + `libx11-dev` + `libxtst-dev` | Faltan headers de desarrollo (-dev); `sudo apt-get` bloqueado |

### 6.3 Causa del fracaso

La callback de XRecord vía ctypes **nunca recibe eventos de teclado reales**, solo un evento inicial vacío. La causa más probable es una incompatibilidad entre la callback de ctypes y el mecanismo interno de entrega de eventos de `XRecordEnableContext`. Las callbacks de XRecord se invocan desde el contexto de procesamiento de eventos de Xlib, y es posible que ctypes no maneje correctamente la readquisición del GIL en este pathway específico. La alternativa `python3-xlib` tiene un bug/limitación en la serialización de `Record_Range` que impide crear el contexto.

### 6.4 Conclusión

**XRecord no es viable desde Python sin bindings nativos compilados.** La solución correcta requiere compilar `ksuperkey` en C (necesita `sudo apt-get install libx11-dev libxtst-dev pkg-config`) o usar el mecanismo nativo de LXQt.

---

## 7. Solución Final Aplicada: Atajo Nativo LXQt `Meta`

### 7.1 Fundamentos

`lxqt-globalkeysd` soporta teclas modifier-only (solo Meta/Super sin combinación) como caso especial. El código fuente (`daemon/core.cpp`) contiene la regla: *"Only the meta keys are allowed"* para atajos sin tecla acompañante.

### 7.2 Cambio realizado

**Archivo:** `~/.config/lxqt/globalkeyshortcuts.conf`

Se agregó la sección:

```ini
[Meta.43]
Comment=Mostrar/ocultar el menú principal (tecla Super)
Enabled=true
path=/panel/fancymenu/show_hide
```

Esto vincula la tecla Super sola (Meta) al toggle de FancyMenu usando el mecanismo nativo de LXQt, **sin necesidad de daemon externo**.

### 7.3 Activación

Para que el cambio tome efecto:
```bash
pkill lxqt-globalkeysd
# lxqt-session lo relanza automáticamente
```
O cerrar y reabrir sesión.

### 7.4 Verificación

- [ ] Super abre FancyMenu
- [ ] Super cierra FancyMenu (problema potencial: mismo bug de XGrabKeyboard que afectaba al daemon)
- [ ] Alt+F1 físico sigue funcionando como respaldo
- [ ] El daemon `lxqt-superkey` ya no es necesario y puede desactivarse en autostart
