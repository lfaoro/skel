# tmux keybinds — session management

Prefix: `M-;` (Alt+;). Status-left shows `session_name[#sessions]` via `#{server_sessions}`.

## Session operations — current bindings

| Op | Key | Source |
|---|---|---|
| Create session | `M-; C-t` | config |
| Create session (yazi popup) | `M-; f` | config |
| List + switch (fzf picker) | `M-; F` | tmux-fzf |
| Next / prev session | `C-M-j` / `C-M-k` | config |
| Next / prev session (defaults) | `M-; )` / `M-; (` | tmux default |
| Rename session | `M-; $` | tmux default |
| Detach | `M-; d` (also `Alt+Shift+e` via tilish) | default / tilish |
| Move window → another session | `M-; .` | tmux default (prompts for target) |
| Detach other clients | `M-; D` | tmux default |

Note: the default session picker `M-; s` is unbound — `s` is rebound to
synchronize-panes. Use `M-; F` for list + switch.

## Missing (only reachable via `M-; :` command prompt)

- Kill session (`kill-session`) — `M-; &` only kills the window; the session
  dies only if it was the last window
- Kill all other sessions (`kill-session -a`)
- Link window to another session (`link-window`) — window appears in both
- Swap window with another session (`swap-window`)
- Join pane into another session (`join-pane`)
- Jump to last session (`switch-client -l`)

## Proposal (discussed, not yet applied)

| Op | Key | Command |
|---|---|---|
| Kill current session | `M-; K` | `confirm-before kill-session` |
| Kill all other sessions | `M-; C-K` | `confirm-before kill-session -a` |
| Link window | `M-; L` | `command-prompt` → `link-window` |
| Swap window | `M-; S` | `command-prompt` → `swap-window` |
| Join pane | `M-; J` | `command-prompt` → `join-pane` |
| Last session | `M-; l` | `switch-client -l` |

Design: uppercase = session-level ops, lowercase = window/pane ops (matches
existing style: `&` kill-window, `x` kill-pane, `s` synchronize). K/L/S/J are
mnemonic (Kill, Link, Swap, Join) and all prompt-based like the existing
`M-; .` move-window — one consistent interaction pattern. K gets
confirm-before since it nukes all windows in the session.

Optional extras:

- Make `C-t` prompt for a name (`command-prompt -p "new session:" "new-session -s '%%'"`)
  instead of creating unnamed numbered sessions — or keep quick-create and add
  `M-; C-T` for named
- From the shell, `tmux new -A -s name` attaches-or-creates — a nice habit
  for project sessions
