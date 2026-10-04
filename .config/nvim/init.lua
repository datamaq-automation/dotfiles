-- ============================================================================
-- NEOVIM CONFIG - Minimalista para aprender
-- ============================================================================
-- Enfoque: Simple, sin plugins
-- Keybindings: Compatible con TMUX (evitar Ctrl+H/J/K/L)
-- ============================================================================

-- ============================================================================
-- CONFIGURACIÓN BASE
-- ===========================================================================

-- Número de línea (relativo para movimiento rápido)
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentación
vim.opt.expandtab = true      -- Usar espacios en lugar de tabs
vim.opt.shiftwidth = 4        -- Ancho de indentación
vim.opt.tabstop = 4           -- Ancho visual de tab
vim.opt.softtabstop = 4       -- Comportamiento de tab en insert

-- Búsqueda
vim.opt.ignorecase = true     -- Búsqueda insensible a mayúsculas
vim.opt.smartcase = true      -- Pero sensible si hay mayúsculas
vim.opt.hlsearch = true       -- Resaltar resultados
vim.opt.incsearch = true      -- Buscar mientras escribes

-- Interface
vim.opt.cursorline = true     -- Resaltar línea actual
vim.opt.signcolumn = "yes"    -- Columna para signos (git, errores)
vim.opt.wrap = true           -- Envolver líneas largas
vim.opt.linebreak = true      -- Envolver en palabras completas
vim.opt.mouse = "a"           -- Soporte mouse en todos modos

-- Clipboard (copiar/pegar con sistema)
vim.opt.clipboard:append("unnamedplus")

-- Comportamiento
vim.opt.backspace = "indent,eol,start"
vim.opt.undofile = true                 -- Persistir undo
vim.opt.swapfile = false                -- Sin archivos swap
vim.opt.splitright = true               -- Nuevas ventanas a la derecha
vim.opt.splitbelow = true               -- Nuevas ventanas abajo

-- Tiempo para actualizar
vim.opt.updatetime = 250

-- ============================================================================
-- KEYBINDINGS
-- ============================================================================
-- Prefijo: <Leader> = Espacio
-- Evitamos Ctrl+H/J/K/L para NO conflictuar con TMUX

local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Navegación entre buffers
vim.keymap.set("n", "<Leader>n", ":bnext<CR>", opts)           -- siguiente buffer
vim.keymap.set("n", "<Leader>p", ":bprevious<CR>", opts)       -- anterior
vim.keymap.set("n", "<Leader>d", ":bdelete<CR>", opts)         -- cerrar buffer

-- Navegación entre ventanas (NO Ctrl+H/J/K/L)
vim.keymap.set("n", "<Leader>w", "<C-w>w", opts)               -- siguiente ventana
vim.keymap.set("n", "<Leader>h", "<C-w>h", opts)               -- izquierda
vim.keymap.set("n", "<Leader>l", "<C-w>l", opts)               -- derecha
vim.keymap.set("n", "<Leader>j", "<C-w>j", opts)               -- abajo
vim.keymap.set("n", "<Leader>k", "<C-w>k", opts)               -- arriba

-- Split de ventanas
vim.keymap.set("n", "<Leader>vs", ":vsplit<CR>", opts)         -- split vertical
vim.keymap.set("n", "<Leader>hs", ":split<CR>", opts)          -- split horizontal

-- Guardar y salir
vim.keymap.set("n", "<Leader>w", ":write<CR>", opts)           -- guardar
vim.keymap.set("n", "<Leader>q", ":quit<CR>", opts)            -- salir

-- Toggle línea de números
vim.keymap.set("n", "<Leader>nu", ":set number!<CR>", opts)

-- Toggle resaltado de búsqueda
vim.keymap.set("n", "<Leader>/", ":set hlsearch!<CR>", opts)

-- Deshacer/Repetir (amigable para nuevos usuarios)
vim.keymap.set("n", "<C-z>", "u", opts)
vim.keymap.set("n", "<C-S-z>", "<C-r>", opts)

-- ============================================================================
-- AUTOCOMANDOS
-- ============================================================================

-- Auto-expandir tabs a espacios
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt_local.expandtab = true
        vim.opt_local.shiftwidth = 4
    end
})

-- Guardar posición del cursor al cerrar archivo
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local line = vim.fn.line("'\"")
        if line > 1 and line <= vim.fn.line("$") then
            vim.cmd("normal! g'\"")
        end
    end
})

-- ============================================================================
-- COLORES
-- ============================================================================

vim.opt.termguicolors = false  -- Colores del terminal
vim.cmd("syntax on")

-- ============================================================================
-- SESIONES
-- ============================================================================

local session_dir = vim.fn.expand("~/.config/nvim/sessions")
if vim.fn.isdirectory(session_dir) == 0 then
    vim.fn.mkdir(session_dir, "p")
end

vim.keymap.set("n", "<Leader>ss", function()
    local session_file = session_dir .. "/session.vim"
    vim.cmd("mksession! " .. session_file)
    print("✓ Sesión guardada")
end, opts)

vim.keymap.set("n", "<Leader>sr", function()
    local session_file = session_dir .. "/session.vim"
    if vim.fn.filereadable(session_file) == 1 then
        vim.cmd("source " .. session_file)
        print("✓ Sesión restaurada")
    else
        print("✗ No hay sesión guardada")
    end
end, opts)

-- ============================================================================
-- REFERENCIA DE MODOS
-- ============================================================================
-- NORMAL (Esc)     : navegación y comandos
-- INSERT (i)       : escribir texto
-- VISUAL (v)       : seleccionar texto
-- COMMAND (:)      : comandos de Neovim
--
-- Movimientos sin flechas:
--   w = siguiente palabra, e = fin palabra, b = atrás
--   $ = fin línea, ^ = inicio línea
--
-- Edición:
--   d + movimiento = borrar   (dd = línea)
--   c + movimiento = cambiar  (cc = línea)
--   y + movimiento = copiar   (yy = línea)
--   p / P = pegar después/antes
-- ============================================================================

print("✓ Neovim config cargada")
