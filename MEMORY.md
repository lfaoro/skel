# MEMORY.md

## Process rules

- To inspect the Helix runtime setup (config file, runtime directories, per-language LSP/grammar/formatter status), run `hx --health` / `hx --health <lang>`. Do **not** search `/nix/store` for the helix runtime — that trips the permission gate.
