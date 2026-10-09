# C Development Setup in Neovim

## What's Configured

### 1. LSP (Language Server Protocol)
- **clangd**: Provides code completion, go-to-definition, find references, etc.
- Standard: C11 (you can change this in `init.lua` if needed)

### 2. Formatting
- **clang-format**: Automatically formats code on save
- Copy `.clang-format` to your project root to customize formatting style

### 3. Syntax Highlighting
- **Treesitter**: Advanced syntax highlighting for C

## Key Features

### Code Navigation
- `gd` - Go to definition
- `gr` - Go to references
- `gI` - Go to implementation
- `gD` - Go to declaration
- `<C-t>` - Jump back

### Code Actions
- `<leader>ca` - Code actions (in normal or visual mode)
- `<leader>rn` - Rename symbol

### Formatting
- `<leader>ff` - Format current buffer manually
- Auto-formats on save (already enabled)

### Diagnostics
- `<leader>q` - Open diagnostic quickfix list
- Hover over errors to see details

## Getting Started

1. Open any `.c` file
2. Wait a moment for LSP to attach (you'll see "LSP attached" in the status)
3. Start coding!

## Project Setup

When starting a new C project:

1. Copy `.clang-format` to your project root:
   ```bash
   cp ~/.config/nvim/templates/c/.clang-format /path/to/your/project/
   ```

2. (Optional) Create a `compile_commands.json` for better LSP support:
   ```bash
   # Using CMake:
   cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
   
   # Using Bear (for Makefiles):
   bear -- make
   ```

## Customization

### Change C Standard
Edit `init.lua` and modify the clangd settings:
```lua
clangd = {
  settings = {
    clangd = {
      fallbackFlags = { '-std=c17' }, -- Change to c99, c11, c17, c23, etc.
    },
  },
},
```

### Adjust Formatting Style
Edit `.clang-format` in your project root. Common styles:
- LLVM
- Google
- Chromium
- Mozilla
- WebKit

## Tips

- Use `:Mason` to check if clangd and clang-format are installed
- Use `:LspInfo` to check LSP status
- Use `:ConformInfo` to check formatter status
- For compile errors, ensure you have a `compile_commands.json` in your project root

