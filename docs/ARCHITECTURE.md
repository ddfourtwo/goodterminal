# GoodTerminal Architecture

This document describes the system architecture, component interactions, and key technical decisions for GoodTerminal.

## System Overview

GoodTerminal is a **configuration management system** for remote development environments. It orchestrates multiple tools (neovim, tmux, shell, mosh) into a unified, seamless development experience.

```mermaid
flowchart TD
    User[Developer] -->|SSH/Mosh| Server[Remote Server]
    Server --> GT[GoodTerminal]

    subgraph GT[GoodTerminal System]
        Install[install.sh] --> Config[Configuration Layer]
        Config --> Tools[Tool Integration Layer]
        Tools --> Plugins[Plugin Management]

        subgraph Config[Configuration Layer]
            NvimCfg[Neovim Config]
            TmuxCfg[Tmux Config]
            ShellCfg[Shell Config]
            MoshCfg[Mosh Config]
        end

        subgraph Tools[Tool Integration Layer]
            Neovim[Neovim + LSP]
            Tmux[Tmux + TPM]
            Shell[Zsh + Plugins]
            Mosh[Mosh + OSC 52]
        end

        subgraph Plugins[Plugin Ecosystem]
            LazyNvim[Lazy.nvim]
            TPM[TPM]
            ZshPlugins[Zsh Plugins]
        end
    end

    GT --> DevEnv[Unified Dev Environment]
    DevEnv --> User
```

## Core Components

### 1. Installation System (install.sh)

The installation system is the entry point and orchestrator for all setup operations.

**File**: `install.sh` (1,308 lines)

**Responsibilities**:
- OS and package manager detection
- Dependency installation
- Tool compilation (tmux from source)
- Configuration deployment
- Plugin installation
- Health checking

```mermaid
flowchart LR
    Start([./install.sh]) --> Detect{Detect OS}
    Detect -->|Ubuntu/Debian| Apt[apt-get]
    Detect -->|RHEL/CentOS| Yum[yum]
    Detect -->|Arch| Pacman[pacman]
    Detect -->|macOS| Brew[brew]

    Apt --> WaitLock{APT locked?}
    WaitLock -->|Yes| Wait[Wait & Retry]
    Wait --> WaitLock
    WaitLock -->|No| InstallPkgs[Install Packages]

    Yum --> InstallPkgs
    Pacman --> InstallPkgs
    Brew --> InstallPkgs

    InstallPkgs --> CompileTmux{Tmux < 3.4?}
    CompileTmux -->|Yes| BuildTmux[Build from Source]
    CompileTmux -->|No| ConfigTools[Configure Tools]
    BuildTmux --> ConfigTools

    ConfigTools --> DeployConfigs[Deploy Configs]
    DeployConfigs --> InstallPlugins[Install Plugins]
    InstallPlugins --> HealthCheck[Health Check]
    HealthCheck --> Done([Complete])
```

**Key Technical Decisions**:
- **Compile tmux from source on Debian**: Ensures v3.4+ features available
- **APT lock handling**: Waits up to 5 minutes for locks to release (handles unattended-upgrades)
- **Symlinks for configs**: Allows live updates without manual sync
- **Headless plugin installation**: Uses `nvim --headless` to bypass interactive prompts

### 2. Configuration Layer

Each tool has its own configuration that follows tool-specific conventions while maintaining consistency.

```mermaid
graph TD
    subgraph Neovim[Neovim Configuration]
        InitLua[init.lua] --> LazySetup[Lazy.nvim Setup]
        LazySetup --> PluginSpecs[Plugin Specifications]
        PluginSpecs --> LSPConfig[LSP Configuration]
        PluginSpecs --> KeyMaps[Keybindings]
        PluginSpecs --> Options[Editor Options]
    end

    subgraph Tmux[Tmux Configuration]
        TmuxConf[tmux.conf] --> TPMSetup[TPM Setup]
        TmuxConf --> KeyBindings[Key Bindings]
        TmuxConf --> Theme[VSCode Theme]
        TPMSetup --> TmuxPlugins[Tmux Plugins]
    end

    subgraph Shell[Shell Configuration]
        ZshRC[.zshrc] --> OhMyZsh[oh-my-zsh Setup]
        ZshRC --> CustomConfig[config file]
        CustomConfig --> Aliases[Aliases]
        CustomConfig --> Functions[Functions]
        OhMyZsh --> ShellPlugins[Shell Plugins]
    end

    subgraph Mosh[Mosh Configuration]
        MoshConfig[config] --> EnvVars[Environment Variables]
        MoshConfig --> Helpers[Helper Functions]
        MoshConfig --> ClipboardSetup[Clipboard Setup]
    end
```

**Configuration Files**:
- `config/nvim/init.lua` - Single-file neovim config (monolithic by design)
- `config/nvim/lazy-lock.json` - Locked plugin versions for reproducibility
- `config/tmux/tmux.conf` - Core tmux settings
- `config/tmux/vscode-theme.conf` - Theme with system monitoring
- `config/shell/config` - Shared aliases and functions
- `config/shell/zshrc.template` - Template for new installations
- `config/mosh/config` - Mosh-specific settings

### 3. Navigation Integration

The killer feature: seamless navigation across tmux panes and neovim splits with identical keybindings.

```mermaid
flowchart TD
    User[User Presses Ctrl+h/j/k/l] --> VimCheck{In Neovim?}

    VimCheck -->|Yes| VimNav{At Neovim Edge?}
    VimNav -->|No| VimSplit[Move to Neovim Split]
    VimNav -->|Yes| TmuxNav[Send to Tmux Navigator]

    VimCheck -->|No| TmuxPane[Move Tmux Pane]

    TmuxNav --> TmuxEdge{At Tmux Edge?}
    TmuxEdge -->|No| TmuxPane
    TmuxEdge -->|Yes| StayInPlace[Stay in Place]

    VimSplit --> Update[Update Cursor Position]
    TmuxPane --> Update
    StayInPlace --> Update
```

**Implementation**:
1. **vim-tmux-navigator** plugin in both neovim and tmux
2. **Neovim config** (`config/nvim/init.lua`):
   ```lua
   {
     'christoomey/vim-tmux-navigator',
     lazy = false,
     cmd = {
       "TmuxNavigateLeft",
       "TmuxNavigateDown",
       "TmuxNavigateUp",
       "TmuxNavigateRight",
     },
   }
   ```
3. **Tmux config** (`config/tmux/tmux.conf`):
   ```bash
   is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
   bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
   # ... similar for j, k, l
   ```

**Result**: Muscle memory works everywhere. No mental context switch between tools.

### 4. Session Persistence

Multiple strategies for session management depending on tool:

```mermaid
flowchart TD
    Start([Session Management]) --> Tool{Which Tool?}

    Tool -->|Neovim| PersistencePlugin[persistence.nvim]
    PersistencePlugin --> AutoRestore{Auto-restore?}
    AutoRestore -->|Yes| RestoreSession[Restore session.vim per directory]
    AutoRestore -->|No| ManualRestore[Space+qs to restore]

    Tool -->|Tmux| TWM[Tmux Workspace Manager]
    TWM --> ProjectBased[Project-based sessions]
    ProjectBased --> ConfigFile[.twm.conf in project root]

    Tool -->|Shell| History[Command History]
    History --> FZFIntegration[fzf + Ctrl+r]
```

**Key Decisions**:
- **Removed tmux-resurrect/continuum**: Too heavyweight, conflicts with TWM
- **persistence.nvim**: Lightweight, per-directory sessions
- **TWM for tmux**: Project-aware session management

### 5. Clipboard Handling

Complex due to remote nature and mosh constraints:

```mermaid
flowchart TD
    Copy[Copy Text] --> InNeovim{In Neovim?}

    InNeovim -->|Yes| UseYank[Use vim-tmux-yank]
    InNeovim -->|No| InTmux{In Tmux?}

    UseYank --> TmuxYank[tmux-yank plugin]
    InTmux -->|Yes| TmuxYank

    TmuxYank --> ConnectionType{Connection Type?}

    ConnectionType -->|SSH| OSC52{OSC 52 Enabled?}
    ConnectionType -->|Mosh| MoshClipboard[Mosh Clipboard]

    OSC52 -->|Yes| TerminalClipboard[Terminal Clipboard Integration]
    OSC52 -->|No| TmuxBuffer[Tmux Buffer Only]

    MoshClipboard --> OSC52Support{Terminal Supports OSC 52?}
    OSC52Support -->|Yes| TerminalClipboard
    OSC52Support -->|No| TmuxBuffer

    TerminalClipboard --> SystemClipboard[System Clipboard]
    TmuxBuffer --> PasteInTmux[Can Paste in Tmux Only]
```

**Current Status** (from pending changes):
- OSC 52 **disabled** in working copy (troubleshooting Mosh issues)
- Using tmux buffer as primary clipboard mechanism
- Investigating terminal compatibility issues

**Known Issues**:
- Mosh doesn't support OSC 52 clipboard sequences consistently
- Some terminals (iTerm2, Alacritty) require specific settings
- Clipboard sync over SSH works better than over Mosh

### 6. Plugin Management

Each tool uses its own plugin manager:

```mermaid
graph LR
    subgraph Neovim
        LazyNvim[Lazy.nvim] --> NvimPlugins[19 Plugins]
        LazyLock[lazy-lock.json] -.->|Locks versions| NvimPlugins
    end

    subgraph Tmux
        TPM[TPM - Tmux Plugin Manager] --> TmuxPlugins[4 Essential Plugins]
    end

    subgraph Shell
        OhMyZsh[oh-my-zsh Framework] --> ZshPlugins[3 Enhancement Plugins]
    end

    Install[install.sh] -->|Installs & Updates| LazyNvim
    Install -->|Installs & Updates| TPM
    Install -->|Installs & Updates| OhMyZsh
```

**Neovim Plugins** (19 total):
1. **Navigation**: vim-tmux-navigator, nvim-tree
2. **LSP**: mason, mason-lspconfig, nvim-lspconfig
3. **Completion**: nvim-cmp, cmp-nvim-lsp, cmp-buffer, cmp-path, LuaSnip, cmp_luasnip
4. **Fuzzy Finding**: telescope, plenary
5. **Syntax**: nvim-treesitter
6. **Git**: gitsigns, lazygit.nvim
7. **UI**: lualine, bufferline, vscode.nvim (theme)
8. **Utilities**: Comment.nvim, nvim-autopairs, persistence.nvim
9. **AI**: Windsurf (by Codeium)

**Tmux Plugins** (4 essential):
1. tpm - Plugin manager
2. tmux-sensible - Sane defaults
3. vim-tmux-navigator - Seamless navigation
4. tmux-yank - Clipboard integration

**Shell Plugins** (3 enhancements):
1. zsh-autosuggestions - Fish-like suggestions
2. zsh-syntax-highlighting - Real-time syntax validation
3. zsh-autocomplete - Advanced completion

## Data Flow

### Installation Flow

```mermaid
sequenceDiagram
    participant User
    participant InstallScript as install.sh
    participant PackageManager as Package Manager
    participant Git
    participant ConfigFiles as Config Files
    participant Plugins as Plugin Managers

    User->>InstallScript: ./install.sh
    InstallScript->>InstallScript: Detect OS & Package Manager
    InstallScript->>PackageManager: Install dependencies
    PackageManager-->>InstallScript: Success

    InstallScript->>InstallScript: Check tmux version
    alt tmux < 3.4
        InstallScript->>InstallScript: Compile tmux from source
    end

    InstallScript->>Git: Clone TPM repository
    InstallScript->>ConfigFiles: Create symlinks
    ConfigFiles-->>InstallScript: Symlinks created

    InstallScript->>Plugins: Install Lazy.nvim
    InstallScript->>Plugins: nvim --headless "+Lazy! sync" +qa
    InstallScript->>Plugins: Install TPM plugins
    InstallScript->>Plugins: Install shell plugins

    Plugins-->>InstallScript: All plugins installed
    InstallScript->>User: Installation complete
```

### Update Flow

```mermaid
sequenceDiagram
    participant User
    participant InstallScript as install.sh --update
    participant Git
    participant ConfigFiles as Config Files
    participant Plugins as Plugin Managers

    User->>InstallScript: ./install.sh --update
    InstallScript->>Git: git stash (if changes)
    InstallScript->>Git: git pull
    Git-->>InstallScript: Latest changes

    InstallScript->>ConfigFiles: Re-create symlinks
    ConfigFiles-->>InstallScript: Updated

    InstallScript->>Plugins: Update Lazy.nvim plugins
    InstallScript->>Plugins: Update TPM plugins
    Plugins-->>InstallScript: All updated

    InstallScript->>Git: git stash pop (if needed)
    InstallScript->>User: Update complete
```

### Typical Development Session

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Mosh
    participant Tmux
    participant Shell
    participant Neovim

    Dev->>Mosh: mosh user@server
    Mosh->>Shell: Start zsh session
    Shell->>Tmux: tmux attach (or new)
    Tmux->>Shell: Restore session

    Dev->>Shell: cd ~/project
    Shell->>Neovim: nvim .
    Neovim->>Neovim: Load persistence.nvim session

    loop Development Work
        Dev->>Neovim: Edit files
        Dev->>Neovim: Ctrl+h (navigate)
        Neovim->>Tmux: Send navigation to tmux
        Tmux->>Shell: Focus shell pane
        Dev->>Shell: git status
        Dev->>Shell: Ctrl+l (navigate)
        Shell->>Neovim: Focus neovim pane
    end

    Dev->>Neovim: :wqa
    Neovim->>Neovim: Save session
    Dev->>Shell: exit
    Tmux->>TWM: Save workspace state
```

## Key Technical Decisions

### 1. Single-File Neovim Config

**Decision**: Use one `init.lua` file instead of modular structure.

**Rationale**:
- Lazy.nvim supports single-file configs well
- Easier to understand for new users
- Simpler to maintain and update
- All plugin specs in one place
- Currently 400 lines - manageable size

**Trade-offs**:
- ✅ Simplicity
- ✅ Easy to navigate
- ❌ Can become large (mitigated by Lazy's organization)

### 2. Compile Tmux from Source (Debian)

**Decision**: Build tmux 3.4 from source on Debian/Ubuntu systems.

**Rationale**:
- Debian stable ships tmux 3.0-3.2
- Features needed: OSC 52 improvements, better clipboard, popup support
- Backports often lag behind

**Implementation** (`install.sh:490-530`):
```bash
if [ "$tmux_version" -lt 304 ]; then
    echo "Installing tmux from source..."
    # Download, compile, install
fi
```

### 3. Symlinks vs. Copies for Configs

**Decision**: Use symlinks to goodterminal repo for all configs.

**Rationale**:
- Live updates: `git pull` immediately affects all tools
- Single source of truth
- Easy rollback: `git checkout` previous version
- Version control benefits

**Implementation**:
```bash
ln -sf "$GOODTERMINAL_DIR/config/nvim/init.lua" ~/.config/nvim/init.lua
ln -sf "$GOODTERMINAL_DIR/config/tmux/tmux.conf" ~/.tmux.conf
```

**Trade-off**: Requires goodterminal directory to stay in place.

### 4. Lazy.nvim Over Other Plugin Managers

**Decision**: Use Lazy.nvim instead of Packer, vim-plug, or others.

**Rationale**:
- Modern, actively maintained (2023+)
- Lazy loading by default (faster startup)
- Lock file for reproducibility (`lazy-lock.json`)
- Great UI for plugin management
- Single-file config support

### 5. No tmux-resurrect/continuum

**Decision**: Removed tmux-resurrect and tmux-continuum plugins.

**Rationale** (from recent commits):
- Conflicts with TWM (Tmux Workspace Manager)
- persistence.nvim handles neovim sessions better
- Simpler mental model: one tool per job
- Reduces plugin complexity

**Current State**: Using TWM + persistence.nvim instead.

### 6. OSC 52 Clipboard (Currently Disabled)

**Decision**: Temporarily disabled OSC 52 sequences.

**Rationale**:
- Mosh doesn't consistently support OSC 52
- Terminal compatibility varies (iTerm2 yes, some others no)
- Causes issues with copy/paste in certain scenarios
- Using tmux buffer as fallback

**Status**: Under investigation (see troubleshooting/clipboard.md).

### 7. Minimal Shell Framework

**Decision**: Use oh-my-zsh but with minimal plugins.

**Rationale**:
- oh-my-zsh provides solid foundation
- Only load essential plugins (3 total)
- Faster startup than full oh-my-zsh installations
- Balance between features and performance

**Not Using**: Frameworks like Prezto, zim, or antibody (oh-my-zsh is ubiquitous).

### 8. TWM for Project Management

**Decision**: Integrate TWM (Tmux Workspace Manager) for project-based sessions.

**Rationale**:
- Developers work on multiple projects
- Each project needs its own layout
- `.twm.conf` files in project roots define layouts
- Complements tmux sessions nicely

**Implementation**: Compiled from Rust source, bound to prefix+P.

## Security Considerations

### Input Validation
- User paths are quoted to prevent injection
- No `eval` of user input
- Package manager commands use fixed arguments

### Backup Strategy
- All existing configs backed up before modification
- Backups timestamped: `~/.config/nvim/init.lua.backup-YYYYMMDDHHMMSS`
- Git repository changes stashed before updates

### Network Safety
- All downloads over HTTPS
- TPM cloned from official GitHub
- Lazy.nvim plugins from curated list
- No arbitrary code execution from configs

### Privilege Requirements
- **Does NOT require root** for most operations
- Only uses sudo for:
  - Package installation
  - Tmux compilation (install to /usr/local)
- User configs in home directory only

## Performance Characteristics

### Installation Time
- **Full Install**: 5-10 minutes (varies by network and CPU for tmux compilation)
- **Config Update**: 30-60 seconds
- **Plugin Update**: 1-2 minutes

### Startup Times
- **Zsh**: ~200ms (with plugins)
- **Tmux**: ~100ms
- **Neovim**: ~300ms (with lazy loading)

**Total time to productive**: < 1 second after `nvim` command.

### Resource Usage
- **Memory**: ~50MB for tmux + neovim + shell combined
- **Disk**: ~200MB including all plugins
- **CPU**: Negligible when idle

## Extension Points

### Adding New Plugins

**Neovim** (`config/nvim/init.lua`):
```lua
{
  'author/plugin-name',
  lazy = true,  -- optional lazy loading
  config = function()
    -- plugin configuration
  end,
}
```

**Tmux** (`config/tmux/tmux.conf`):
```bash
set -g @plugin 'author/plugin-name'
```

**Shell** (`config/shell/config`):
```bash
# Add to plugins array
plugins=(git zsh-autosuggestions new-plugin)
```

### Custom Keybindings

All keybindings centralized in respective config files:
- Neovim: `config/nvim/init.lua` (search for `vim.keymap.set`)
- Tmux: `config/tmux/tmux.conf` (search for `bind-key`)
- Shell: `config/shell/config` (search for `bindkey`)

### Per-User Customizations

Users can add:
- `~/.config/nvim/after/` directory for neovim overrides
- `~/.tmux.conf.local` for tmux additions
- `~/.zshrc.local` for shell additions

These are **not** overwritten by updates.

## Testing Strategy

### Manual Testing Checklist
- [ ] Full installation on fresh VM (per OS)
- [ ] Update from previous version
- [ ] Navigation works (Ctrl-hjkl)
- [ ] Clipboard works in SSH
- [ ] Clipboard works in Mosh
- [ ] LSP autocomplete works
- [ ] Session persistence works
- [ ] TWM project switching works
- [ ] All keybindings responsive

### Automated Testing
See `tests/` directory for integration tests (TODO: implement per high-priority action #4).

## Future Architecture Considerations

### Modularity
As install.sh grows beyond 1,500 lines, consider:
```
scripts/
├── lib/
│   ├── os-detection.sh
│   ├── package-manager.sh
│   ├── installers/
│   │   ├── tmux.sh
│   │   ├── neovim.sh
│   │   └── shell.sh
│   └── config-deployer.sh
└── install.sh (orchestrator)
```

### Remote Config Management
Potential future: pull configs from central server instead of git clone.

### Health Monitoring
Dashboard showing status across multiple servers.

### Declarative Profiles
YAML/JSON config to define tool versions and plugins instead of bash script.

## References

- [Lazy.nvim Documentation](https://github.com/folke/lazy.nvim)
- [TPM Documentation](https://github.com/tmux-plugins/tpm)
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
- [TWM (Tmux Workspace Manager)](https://github.com/vinnymeller/twm)
- [Mosh Documentation](https://mosh.org/)

---

**Last Updated**: 2025-12-19
**Architecture Version**: 1.0
