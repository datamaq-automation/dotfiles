# 📋 Hallazgos, Dudas y Tareas por Hacer

Documento de auditoría técnica, decisiones de diseño y hoja de ruta para la optimización de terminal (**TMUX**, **Atuin**, **Zoxide**) y la gestión de dotfiles multi-entorno (Desktop vs. Laptop).

---

## 1. Hallazgos Técnicos

### 1.1. Arquitectura y Sincronización Git
* **Divergencia de entornos:**
  * **Remoto (`origin/master`):** Corresponde a la laptop. Implementado con el patrón *bare repository* directamente sobre `$HOME`, gestionando entorno gráfico X11/LXQt/KDE, temas de iconos Windows-7, scripts de hardware (`battery.sh`, `wifi.sh`), y un `.gitignore` con `/*` que ignora la raíz por defecto.
  * **Local (`origin/main`):** Corresponde a la máquina de escritorio. Implementado como un repositorio modular enfocado en terminal pura (*CLI Development Setup*): Neovim minimalista sin plugins, TMUX de 3 paneles, aliases públicos y guías pedagógicas.
* **Resolución aplicada:** Se vinculó el remoto `origin` y se configuró upstream tracking en `main` (`git push -u origin main`). Se preservó intacta la rama `origin/master` para evitar colisiones entre el hardware móvil y la estación de trabajo.

### 1.2. TMUX (v3.7c instalado)
* **Latencia de tecla Escape:** En ↗ [~/.tmux.conf](file:///home/agustin/.tmux.conf) no está configurado `escape-time`. TMUX aplica el valor por defecto (500 ms), produciendo un retraso perceptible al alternar modos en Neovim o cancelar comandos.
* **Capacidades de terminal y color:** Está configurado con `screen-256color` en lugar de True Color (24-bit RGB) y `tmux-256color`, limitando el renderizado de esquemas de color modernos en terminal.
* **Eventos de foco:** Falta activar `focus-events on`, impidiendo que Neovim y editores detecten cuándo un panel gana o pierde foco (ej: autoreload de archivos).
* **Consumo innecesario en Desktop:** La barra de estado ejecuta periódicamente `#(/home/agustin/.tmux/battery.sh)`, lo cual en esta máquina de escritorio realiza forks de subshell cada 30 segundos sin aportar datos.
* **Modo Copia Vi incompleto:** Posee bindings para `y` y `Enter` con `xclip`, pero carece de selección visual con `v` y selección en bloque con `Ctrl+V`.
* **Desalineación local vs repo:** Existe una discrepancia entre ↗ [~/.tmux.conf](file:///home/agustin/.tmux.conf) (prefijo `Ctrl+A`, paneles con `|` y `-`, scripts de estado) y ↗ [.tmux.conf](file:///home/agustin/proyectos_software/dotfiles/.tmux.conf) (prefijo `Ctrl+B`, layout de 3 paneles fijos).

### 1.3. Atuin (v18.19.0 instalado)
* **Soporte de Popups flotantes disponible pero inactivo:** La configuración en ↗ [~/.config/atuin/config.toml](file:///home/agustin/.config/atuin/config.toml) mantiene el valor por defecto (`[tmux] enabled = false`). En TMUX 3.7c, habilitarlo permite que la búsqueda interactiva se despliegue en un popup flotante centrado sin romper el layout ni el scrollback del panel.
* **Sin aislamiento contextual:** La navegación con flecha arriba (`Up`) busca en todo el historial global en lugar de aislar los comandos de la sesión actual de TMUX (`filter_mode_shell_up_key_binding = "session"`).
* **Búsqueda secuencial:** No tiene activado `search_mode = "fuzzy"`, limitando la búsqueda a coincidencias exactas o de prefijo.

### 1.4. Zoxide (v0.10.0 instalado)
* **Inicialización estándar sin captura de `cd`:** Se inicializa mediante `eval "$(zoxide init bash)"`, dependiendo de escribir `z <ruta>` manualmente en lugar de registrar automáticamente cada salto de directorio con `cd`.
* **Ausencia de `fzf`:** El comando `zi` (modo interactivo) falla o no está disponible porque el binario `fzf` no se encuentra instalado en el sistema (`which fzf` retorna error).
* **Sin integración con TMUX:** No existe un enlace entre la base de datos de frecuencias de Zoxide y la creación o conmutación de sesiones en TMUX (*TMUX-Zoxide Sessionizer*).

---

## 2. Dudas y Decisiones Abiertas

| # | Área | Duda / Decisión | Opciones en Consideración |
|---|------|-----------------|---------------------------|
| **D1** | **Zoxide** | ¿Intercepción automática de `cd`? | **A:** `eval "$(zoxide init bash --cmd cd)"` para que todo `cd` alimente zoxide.<br>**B:** Mantener `cd` nativo y usar alias cortos (`z`, `j`). |
| **D2** | **FZF** | ¿Instalar buscador interactivo `fzf`? | **A:** Instalar vía `apt` (requiere sudo).<br>**B:** Descargar binario estático directo a `~/.local/bin/fzf` (sin root ni sudo).<br>**C:** Prescindir de `fzf` y operar zoxide de forma determinista por argumentos. |
| **D3** | **TMUX Config** | ¿Unificación de `.tmux.conf`? | **A:** Actualizar el archivo versionado en este repositorio con la versión moderna de `~/.tmux.conf`.<br>**B:** Mantener el layout de 3 paneles como perfil educativo y documentar las diferencias. |
| **D4** | **Multi-host** | Estrategia futura para Laptop vs Desktop | **A:** Ramas separadas permanentes (`master` = laptop, `main` = desktop).<br>**B:** Migrar a futuro a un esquema modular unificado con **GNU Stow** (`dotfiles/common/`, `dotfiles/hosts/laptop/`, `dotfiles/hosts/desktop/`). |
| **D5** | **Laptop (Heredadas)** | 6 dudas registradas en `origin/master:PENDIENTES.md` | Confirmar en la laptop: utilidad de `qlipper`, `wasistlos`, `xclip`, `wmctrl`, necesidad de `firmware-*` y método de autenticación GitHub con Falkon. |

---

## 3. Tareas por Hacer (Backlog Priorizado)

### Fase 1: Optimización de TMUX (Inmediata / Sin riesgos)
- [ ] Configurar `escape-time 10` en `~/.tmux.conf` para eliminar lag en modo Vi / Neovim.
- [ ] Configurar `set -as terminal-features ",xterm-256color:RGB"` y `default-terminal "tmux-256color"` para True Color.
- [ ] Habilitar `set -g focus-events on`.
- [ ] Habilitar `set -g renumber-windows on`.
- [ ] Completar keybindings de vi-mode en selección visual (`v` y `Ctrl+V`).
- [ ] Condicionar o remover la llamada a `battery.sh` en la status bar si no existe batería de hardware.
- [ ] Configurar `bind c new-window -c "#{pane_current_path}"` para preservar el directorio al abrir ventanas.

### Fase 2: Optimización de Atuin (Inmediata / Sin riesgos)
- [ ] Habilitar `[tmux] enabled = true`, `width = "85%"`, `height = "65%"` en `~/.config/atuin/config.toml`.
- [ ] Configurar `search_mode = "fuzzy"`.
- [ ] Configurar `filter_mode_shell_up_key_binding = "session"` (la flecha arriba busca en el contexto de la sesión actual de TMUX).
- [ ] Activar `style = "compact"` y `show_preview = true`.

### Fase 3: Integración Zoxide + TMUX (Sinergia del Trío)
- [ ] Evaluar y aplicar `eval "$(zoxide init bash --cmd cd)"` en `~/.bashrc`.
- [ ] Agregar alias `alias j="z"` en `~/.bash_aliases`.
- [ ] Implementar la función `tz()` (*TMUX-Zoxide Sessionizer*) en ↗ [~/.bash_aliases](file:///home/agustin/.bash_aliases) y en ↗ [.bash_aliases.public](file:///home/agustin/proyectos_software/dotfiles/.bash_aliases.public).
- [ ] Instalar o descargar `fzf` en `~/.local/bin/fzf` para desbloquear `zi` y selectores interactivos flotantes en TMUX.

### Fase 4: Limpieza y Mantenimiento del Repositorio
- [ ] Reemplazar placeholder `<repo>` por `https://github.com/datamaq-automation/dotfiles.git` en ↗ [INSTALL.md](file:///home/agustin/proyectos_software/dotfiles/INSTALL.md#L17).
- [ ] Unificar el `.tmux.conf` del repositorio con las mejoras aplicadas en `~/.tmux.conf`.
- [ ] Documentar en ↗ [README.md](file:///home/agustin/proyectos_software/dotfiles/README.md) el uso conjunto de TMUX, Atuin y Zoxide.
- [ ] Commit y push a `origin/main`.
