# 🔧 dotfiles - CLI Development Setup

![License](https://img.shields.io/badge/license-MIT-green)
![Language](https://img.shields.io/badge/shell-bash%2Fzsh-blue)
![Status](https://img.shields.io/badge/status-active-success)

Configuración minimalista para desarrolladores que viven en la terminal.

## ✨ Características

| Herramienta | Descripción |
|-----------|-------------|
| **Firefox CLI** | Lanzar navegador desde terminal sin bloquear |
| **TMUX** | Session multiplexing con layout pre-configurado |
| **Neovim** | Editor modal sin plugins, TMUX-friendly |
| **Aliases** | Utilidades para X11, TTY, VT, shell |
| **Lenguaje técnico** | Referencia para enseñanza |

## 🎯 Para quién es esto

✅ Developers que usan **TMUX** + **Neovim** + CLI  
✅ Educadores que enseñan herramientas de terminal  
✅ Personas que quieren minimizar UI gráfica  
✅ Estudiantes aprendiendo workflows profesionales  

## 📦 Qué incluye

```
dotfiles/
├── .bash_aliases.public     # Firefox + TMUX + Neovim aliases
├── .config/nvim/init.lua    # Neovim minimalista (0 plugins)
├── .tmux.conf               # TMUX: 3 paneles + keybindings
├── INSTALL.md               # Guía de instalación completa
├── README.md                # Este archivo
└── docs/
    └── LANGUAGE.md          # Referencia técnica (TTY, DISPLAY, etc)
```

## 🚀 Quick Start

### 1. Instalar aliases

```bash
# Opción A: Agregar a tu shell config
echo "source ~/path/to/dotfiles/.bash_aliases.public" >> ~/.bashrc

# Opción B: Copiar directo
cat ~/dotfiles/.bash_aliases.public >> ~/.bash_aliases
source ~/.bashrc
```

### 2. Instalar Neovim

```bash
mkdir -p ~/.config/nvim
cp dotfiles/.config/nvim/init.lua ~/.config/nvim/init.lua
```

### 3. Instalar TMUX

```bash
cp dotfiles/.tmux.conf ~/.tmux.conf
tmux source-file ~/.tmux.conf
```

## 💻 Uso

### Firefox desde terminal (lo nuevo)

```bash
# No bloquea, en background automático
ff                        # Abre Firefox

# Con URL
ff https://google.com     # Abre en Google

# Desde una TTY (hacia X11 en display :0)
ff-remote                 # Lanza hacia display :0

# Con logs visibles
ff-debug                  # Firefox mostrando console logs
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

**Keybindings**:
- `Ctrl+H/J/K/L` — navegar paneles
- `Ctrl+Alt+H/J/K/L` — redimensionar paneles
- `Ctrl+B D` — crear layout dev

### Neovim

```bash
vi archivo.txt              # Abre con tu config
<Space>n / <Space>p        # Siguiente/anterior buffer
<Space>h/j/k/l             # Navegar ventanas
<Space>vs / <Space>hs      # Split vertical/horizontal
<Space>w                   # Guardar
<Space>q                   # Salir
```

### Ver términos técnicos

```bash
terminos
```

Muestra tabla de términos correctos (TTY vs DISPLAY, instanciar vs "abrir", etc).

## 📚 Documentación

- **[INSTALL.md](INSTALL.md)** — Instalación paso a paso, FAQ
- **[LANGUAGE.md](docs/LANGUAGE.md)** — Referencia técnica completa (X11, Wayland, TTY, TMUX, Neovim)

## 🎓 Para Estudiantes

Ejercicio práctico para entender TTY vs X11:

```bash
# 1. Ver DISPLAY actual
echo $DISPLAY

# 2. Lanzar Firefox
ff

# 3. Presionar Ctrl+Alt+F1 (ir a TTY)
# 4. Intentar lanzar Firefox nuevamente
firefox                    # ❌ Falla (sin servidor gráfico)

# 5. Pero si especificas DISPLAY:
DISPLAY=:0 firefox &       # ✅ Funciona (se renderiza en X11)

# 6. Presionar Ctrl+Alt+F7 (volver a X11)
# → Firefox aparece en X11
```

**Aprenderás**: Diferencia entre TTY (text-only) y sesión gráfica, DISPLAY, protocolos X11/Wayland.

## 🔄 Comparación con alternativas

| Característica | dotfiles | Config manual | Full DE |
|---|---|---|---|
| **Setup time** | ~5 min | ~30 min | ~15 min |
| **Disk usage** | ~50KB | varies | ~500MB |
| **Learning curve** | Low | High | Medium |
| **Control** | High | Full | Low |
| **CLI focus** | ✅ Yes | ✅ Yes | ❌ No |

## 🛠️ Personalización

Todos los archivos son editable y comentados:

- Cambiar keybindings en `.tmux.conf`
- Ajustar colores en `.config/nvim/init.lua`
- Agregar más aliases en `.bash_aliases.public`

**Recomendación**: Copia a tu config personal y personaliza.

## ⚙️ Compatibilidad

| Sistema | Status |
|---------|--------|
| **Linux** | ✅ Full |
| **macOS** | ⚠️ Partial (Firefox no necesita DISPLAY) |
| **WSL** | ✅ Full (con X11 server) |
| **BSD** | ✅ Likely works |

## 📝 Licencia

MIT — Úsalo, modifícalo, comparte.

## 👨‍💻 Contributing

Pull requests bienvenidos. Especialmente:
- Bug fixes
- Documentación mejorada
- Ejemplos adicionales
- Soporte para más shells (fish, etc)

No agregamos plugins a Neovim (ese es el punto: minimalista).

## 📞 Preguntas

Ver [INSTALL.md#FAQ](INSTALL.md#faq) para preguntas comunes.

## 🔗 Enlaces útiles

- [Neovim docs](https://neovim.io/)
- [TMUX manual](https://man.openbsd.org/tmux)
- [X11 protocol](https://www.x.org/)
- [Bash scripting](https://www.gnu.org/software/bash/manual/)

---

**Made for developers who prefer terminal over GUI.**

*Last updated: 2026-10-04*
