# dotfiles - Setup CLI para desarrollo

Configuración minimalista para desarrolladores que usan **TMUX**, **Neovim** y **Firefox desde terminal**.

## 📋 Incluye

- ✅ **Aliases & funciones para Firefox** — lanzar navegador desde TTY/TMUX
- ✅ **Configuración Neovim minimalista** — 0 plugins, keybindings TMUX-friendly
- ✅ **Configuración TMUX** — layout 3 paneles, navegación rápida
- ✅ **Referencia de lenguaje técnico** — para enseñanza

## 🚀 Instalación rápida

### 1. Clonar o descargar

```bash
git clone <repo> ~/proyectos_software/dotfiles
cd ~/proyectos_software/dotfiles
```

### 2. Instalar aliases

Agregar al final de `~/.bashrc` o `~/.zshrc`:

```bash
if [ -f ~/proyectos_software/dotfiles/.bash_aliases.public ]; then
    . ~/proyectos_software/dotfiles/.bash_aliases.public
fi
```

O copiar directamente:

```bash
cat ~/proyectos_software/dotfiles/.bash_aliases.public >> ~/.bash_aliases
```

Recargar shell:
```bash
source ~/.bashrc
```

### 3. Instalar Neovim config

```bash
mkdir -p ~/.config/nvim
cp ~/proyectos_software/dotfiles/.config/nvim/init.lua ~/.config/nvim/init.lua
```

### 4. Instalar TMUX config

```bash
cp ~/proyectos_software/dotfiles/.tmux.conf ~/.tmux.conf
```

Recargar TMUX:
```bash
tmux source-file ~/.tmux.conf
```

## 📖 Uso

### Firefox desde CLI

```bash
# Lanzar en DISPLAY actual (no bloquea terminal)
ff

# Lanzar con URL
ff https://example.com

# Lanzar desde TTY (hacia X11 en :0)
ff-remote https://example.com

# Ver logs en consola
ff-debug
```

### TMUX

```bash
# Crear sesión dev con 3 paneles
tmux-dev

# Listar sesiones
tmux-list

# Attacharse (crea si no existe)
tmux-attach dev
```

Keybindings en TMUX (desde config):
- `Ctrl+H/J/K/L` — navegar entre paneles
- `Ctrl+B D` — crear layout dev
- `Ctrl+B C-H/J/K/L` — redimensionar paneles

### Neovim

```bash
# Abrir con tu nueva config
vi archivo.txt
vim archivo.txt
nvim archivo.txt
```

Keybindings principales (dentro de Neovim):
- `<Space>n` / `<Space>p` — siguiente/anterior buffer
- `<Space>h/j/k/l` — navegar entre ventanas
- `<Space>vs` / `<Space>hs` — split vertical/horizontal
- `<Space>w` — guardar
- `<Space>q` — salir
- `<Space>?` — ver todos los keybindings

**Nota**: Usamos `<Space>` en lugar de `Ctrl+H/J/K/L` para **no conflictuar con TMUX**.

### Lenguaje técnico

```bash
# Ver referencia de términos
terminos
```

Muestra tabla de:
- TTY vs DISPLAY
- Instanciar vs "Abrir"
- Términos TMUX/Neovim correctos

## 📚 Referencia completa

Ver `../../../.claude/projects/-home-agustin/memory/tech-language-guide.md` para:
- Explicación completa de TTY, DISPLAY, X11, Wayland
- Casos de uso (Firefox desde TTY, SSH remoto, etc)
- Errores comunes
- Cheat sheet

## 🎯 Para estudiantes

Esta configuración está diseñada para aprender:
1. Trabajo en terminal sin interfaz gráfica
2. Multiplexación de sesiones (TMUX)
3. Edición eficiente (Neovim)
4. Lenguaje técnico correcto

**Ejercicio recomendado**:
```bash
# 1. Abrir Firefox desde TMUX
ff

# 2. Ver DISPLAY activo
echo $DISPLAY

# 3. Presionar Ctrl+Alt+F1 (ir a TTY)
# 4. Intentar lanzar Firefox (falla - sin servidor gráfico)
# 5. Especificar DISPLAY
DISPLAY=:0 firefox &

# 6. Presionar Ctrl+Alt+F7 (volver a X11)
# → Firefox aparece
```

## 🔧 Personalización

Todos los archivos son editable. Algunos puntos útiles:

### `.bash_aliases.public`
- Cambiar DISPLAY default (línea `echo ":0"`)
- Agregar más aliases para herramientas personales
- Ajustar keybindings de TMUX

### `.config/nvim/init.lua`
- Cambiar ancho de indentación (línea `shiftwidth = 4`)
- Agregar más keybindings
- Personalizar colores (sección COLORES)

### `.tmux.conf`
- Cambiar prefijo (default: `Ctrl+B`)
- Ajustar layout de paneles
- Agregar plugins (en futuras versiones)

## ❓ FAQ

### ¿Puedo usar esto en Mac?
Sí, pero:
- TMUX keybindings funcionan igual
- Firefox no necesita `DISPLAY` en Mac (tiene Quartz)
- Algunos paths pueden variar

### ¿Y en Windows (WSL)?
Sí:
- Aliases funcionan en Bash/Zsh
- TMUX funciona normal
- Neovim funciona normal
- Firefox desde WSL puede necesitar X11 Server instalado (VcXsrv, etc)

### ¿Cómo agrego plugins a Neovim después?
Esta es la versión minimalista. Para agregar plugins:
1. Instalar un plugin manager (vim-plug, packer.nvim, etc)
2. Copiar la config a tu propio `init.lua`
3. Agregar plugins según necesites

## 📝 Licencia

Estos dotfiles son públicos. Úsalos, modifícalos, comparte.

## 👨‍🏫 Notas de enseñanza

Esta configuración sirve para enseñar:
- **CLI profunda**: TTY, DISPLAY, X11/Wayland, SSH remoto
- **Automatización**: Aliases, funciones, scripts
- **Herramientas profesionales**: TMUX, Neovim, Firefox
- **Lenguaje técnico correcto**: Más importante de lo que parece

Usar con alumnos en ejercicios prácticos es recomendado.

---

**Última actualización**: 2026-10-04
