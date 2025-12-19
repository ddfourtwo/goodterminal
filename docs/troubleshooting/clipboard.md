# Clipboard Troubleshooting Guide

This document covers known issues and workarounds for clipboard handling in GoodTerminal, particularly with Mosh connections.

## Current Status

**Last Updated**: 2025-12-19

**Active Investigation**: OSC 52 clipboard sequences disabled in working copy while troubleshooting Mosh compatibility issues.

## Background

GoodTerminal aims to provide seamless clipboard integration across:
- Local terminal → Remote server
- Neovim → System clipboard
- Tmux buffer → System clipboard
- SSH connections
- Mosh connections

The primary mechanism for this is **OSC 52 escape sequences**, which allow terminal applications to write to the system clipboard.

## Known Issues

### 1. OSC 52 Not Working with Mosh

**Symptom**: Copying text in neovim or tmux over Mosh connection doesn't sync to local clipboard.

**Root Cause**: Mosh has inconsistent support for OSC 52 escape sequences depending on:
- Mosh version
- Local terminal emulator
- Remote server configuration

**Status**: ❌ Currently disabled in `config/tmux/tmux.conf`

**Workaround**: Use tmux buffer only:
```bash
# In tmux:
# 1. Enter copy mode: prefix + [
# 2. Select text with vim motions
# 3. Copy to tmux buffer: Enter
# 4. Paste from tmux buffer: prefix + ]
```

**Affected Files**:
- `config/tmux/tmux.conf` (OSC 52 settings commented out)
- `config/mosh/config` (clipboard warnings added)

### 2. Terminal-Specific OSC 52 Support

Different terminals have different levels of OSC 52 support:

| Terminal | OSC 52 Support | Configuration Required |
|----------|----------------|------------------------|
| iTerm2 (macOS) | ✅ Yes | Enable in Preferences → General → Applications in terminal may access clipboard |
| Alacritty | ✅ Yes | Works by default in recent versions |
| Terminal.app (macOS) | ❌ No | No support for OSC 52 |
| tmux | ✅ Yes | Requires `set -s set-clipboard on` |
| Mosh | ⚠️ Partial | Depends on terminal and version |

**Current Configuration**:
```bash
# config/tmux/tmux.conf (currently commented out)
# set -s set-clipboard on
# set -g @yank_selection_mouse 'clipboard'
# set -g @override_copy_command 'pbcopy'  # macOS only
```

### 3. Different Behavior Over SSH vs Mosh

**SSH**: OSC 52 generally works well when:
- Terminal supports OSC 52
- tmux configured with `set-clipboard on`
- No intermediate jump hosts

**Mosh**: OSC 52 reliability varies:
- ✅ Works: Direct mosh connection with iTerm2/Alacritty
- ❌ Fails: Through jump hosts, some VPN configurations
- ⚠️ Inconsistent: Older mosh versions (< 1.3.2)

## Debugging Steps

### 1. Test OSC 52 Support Manually

```bash
# On remote server, test if terminal supports OSC 52:
printf "\033]52;c;$(printf 'test' | base64)\a"

# If successful, "test" should appear in your local clipboard
# Try pasting (Cmd+V on macOS, Ctrl+V on Linux)
```

If this doesn't work, your terminal or connection doesn't support OSC 52.

### 2. Check Tmux Configuration

```bash
# In tmux session:
tmux show-options -s set-clipboard
# Should show: set-clipboard on

tmux show-options -g @yank_selection
# Should show configured value
```

### 3. Verify Mosh Version

```bash
# Check mosh version:
mosh --version

# Recommended: 1.3.2 or higher
# OSC 52 support improved in recent versions
```

### 4. Test Terminal Emulator

Open a **local** terminal (not SSH/Mosh) and run:
```bash
printf "\033]52;c;$(printf 'local test' | base64)\a"
```

If "local test" appears in clipboard: Terminal supports OSC 52.
If not: Your terminal doesn't support OSC 52 at all.

### 5. Enable Debug Logging

For detailed debugging:

```bash
# Enable tmux logging:
tmux set-option -g @logging-path "$HOME/tmux-logs"
tmux set-option -g @logging-filename "tmux-#{session_name}-#{window_index}-#{pane_index}-%Y%m%d%H%M%S.log"

# Check mosh connection:
MOSH_DEBUG=1 mosh user@server
```

## Workarounds

### Workaround 1: Use Tmux Buffer (Current Default)

**When to use**: Always works, no configuration needed.

**How**:
1. In tmux: `prefix + [` (enter copy mode)
2. Navigate with vim motions (h/j/k/l)
3. Start selection: `Space` or `v`
4. Copy: `Enter` or `y`
5. Paste in tmux: `prefix + ]`

**Limitation**: Can't paste to local applications outside tmux.

### Workaround 2: Use SSH Instead of Mosh

**When to use**: When clipboard sync is critical.

**How**:
```bash
# Instead of:
mosh user@server

# Use:
ssh user@server
```

**Trade-off**: Lose Mosh's connection resilience and roaming features.

### Workaround 3: Terminal-Specific Configurations

#### iTerm2 (macOS)
Enable clipboard access:
1. iTerm2 → Preferences → General
2. Check "Applications in terminal may access clipboard"
3. Restart iTerm2

Then in `config/tmux/tmux.conf`:
```bash
set -s set-clipboard on
set -g @override_copy_command 'pbcopy'
```

#### Alacritty
In `~/.config/alacritty/alacritty.yml`:
```yaml
selection:
  save_to_clipboard: true
```

### Workaround 4: Use External Clipboard Tool

Install `xclip` (Linux) or `pbcopy` (macOS) and configure tmux:

```bash
# macOS
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'pbcopy'

# Linux
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -selection clipboard'
```

**Limitation**: Requires X11 forwarding for X-based systems.

## Configuration Files Reference

### Current State (OSC 52 Disabled)

**config/tmux/tmux.conf**:
```bash
# OSC 52 clipboard support (currently disabled - investigating Mosh issues)
# set -s set-clipboard on
# set -g @yank_selection_mouse 'clipboard'

# Using tmux buffer as primary clipboard
set -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
```

### Previous State (OSC 52 Enabled)

```bash
# OSC 52 clipboard support
set -s set-clipboard on
set -g @yank_selection_mouse 'clipboard'
set -g @override_copy_command 'pbcopy'  # macOS
```

## Resolution Roadmap

### Short-term (Current)
- [x] Disable OSC 52 to establish baseline
- [ ] Document all clipboard workflows
- [ ] Test tmux buffer-only approach with users
- [ ] Gather feedback on clipboard needs

### Medium-term (Investigation)
- [ ] Test OSC 52 with different Mosh versions
- [ ] Create compatibility matrix (terminal × connection type × OS)
- [ ] Identify minimum working configuration
- [ ] Document per-terminal setup guides

### Long-term (Future Enhancement)
- [ ] Implement automatic detection of OSC 52 support
- [ ] Provide multiple clipboard strategies with auto-fallback
- [ ] Add clipboard sync health check to install.sh
- [ ] Create troubleshooting wizard: `./install.sh --fix-clipboard`

## Related Issues

- Recent commits removed tmux-resurrect/continuum (simplified session management)
- OSC 52 sequences disabled in commit [reference needed]
- Mosh config updated with clipboard warnings

## Community Solutions

### From Mosh Documentation
Mosh states OSC 52 support is "experimental and depends on terminal."

### From tmux Documentation
tmux recommends `set-clipboard on` but notes it requires terminal support.

### From vim-tmux-navigator
Plugin focuses on navigation, clipboard is separate concern (uses tmux-yank).

## Testing Checklist

When re-enabling OSC 52:

- [ ] Test on iTerm2 with Mosh
- [ ] Test on Alacritty with Mosh
- [ ] Test on iTerm2 with SSH
- [ ] Test on Alacritty with SSH
- [ ] Test copy in neovim
- [ ] Test copy in tmux copy mode
- [ ] Test paste to local application
- [ ] Test with VPN active
- [ ] Test after laptop sleep/wake
- [ ] Test with tmux nested sessions

## Getting Help

If you experience clipboard issues:

1. Check your terminal in the compatibility matrix above
2. Try the workarounds in order
3. Run the debugging steps
4. Report findings with:
   - Terminal emulator and version
   - Connection type (SSH/Mosh)
   - Mosh version (if applicable)
   - OS (local and remote)
   - Output from test commands

## References

- [OSC 52 Specification](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Operating-System-Commands)
- [Mosh OSC 52 Support Discussion](https://github.com/mobile-shell/mosh/issues/1054)
- [tmux set-clipboard Documentation](https://man.openbsd.org/tmux.1#set-clipboard)
- [tmux-yank Plugin](https://github.com/tmux-plugins/tmux-yank)

---

**Next Steps**: Continue testing terminal compatibility and gather user feedback on current tmux-buffer-only approach.
