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

## Rationale for the new bindings

- **Uppercase = structural ops, lowercase = navigation.** Uppercase keys
  (K, L, S, J) are session-level structural operations — kill, link, swap,
  join. Lowercase keys stay navigation and window/pane ops: `l` = last
  session (pure navigation, like vim's `l`), `s` = synchronize-panes,
  `&`/`x` = kill window/pane. Mirrors the existing style: lowercase for
  everyday ops, uppercase reserved for bigger structural actions.
- **Mnemonic letters.** K = Kill, L = Link, S = Swap, J = Join, l = last.
  No memorization table needed.
- **One interaction pattern.** All structural ops prompt for the target
  session (`command-prompt`), exactly like the existing `M-; .`
  move-window: press key → type session name → Enter. No new interaction
  model to learn.
- **Destructive ops get confirmation.** K and C-K wrap `kill-session` in
  `confirm-before` — killing a session destroys all its windows, so a
  stray keystroke shouldn't be fatal. Non-destructive ops (L, S, J, l)
  prompt only for the target, not for confirmation.
- **No collisions.** K, L, S, J are unbound in the prefix table; C-K is
  free (only `C-k` is bound, to resize-pane). Verified against config +
  tilish + tmux-fzf + tmux defaults.
- **Covers the actual gap.** These six are exactly the session operations
  not reachable by a key today — everything else (create, switch, rename,
  detach, move-window) already has a binding.

Optional extras:

- Make `C-t` prompt for a name (`command-prompt -p "new session:" "new-session -s '%%'"`)
  instead of creating unnamed numbered sessions — or keep quick-create and add
  `M-; C-T` for named
- From the shell, `tmux new -A -s name` attaches-or-creates — a nice habit
  for project sessions
