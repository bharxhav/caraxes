# caraxes

hostname := `hostname -s`

# List all recipes
default:
    @just --list --unsorted

# ───────────────────────────── config ─────────────────────────────

# Validate the flake (eval all outputs)
[group('config')]
check:
    nix flake check

# Update ALL flake inputs and commit the lock
[group('config')]
update:
    nix flake update --commit-lock-file

# Update a SINGLE input, e.g. `just upp nixpkgs`
[group('config')]
upp input:
    nix flake update {{ input }} --commit-lock-file

# Drop into a Nix REPL with this flake loaded
[group('config')]
repl:
    nix repl .#

# Format all Nix files
[group('config')]
fmt:
    nixfmt **/*.nix

# Lint Nix files
[group('config')]
lint:
    statix check .
    deadnix .

# ───────────────────────────── system ─────────────────────────────

# Apply config to the running system
[group('system')]
[macos]
switch:
    sudo darwin-rebuild switch --flake .#{{ hostname }}

[group('system')]
[linux]
switch:
    sudo nixos-rebuild switch --flake .#{{ hostname }}

# Build config without activating it
[group('system')]
[macos]
build:
    darwin-rebuild build --flake .#{{ hostname }}

[group('system')]
[linux]
build:
    nixos-rebuild build --flake .#{{ hostname }}

# Show system generation history
[group('system')]
[macos]
history:
    darwin-rebuild --list-generations

[group('system')]
[linux]
history:
    nix profile history --profile /nix/var/nix/profiles/system

# ───────────────────────────── maint ──────────────────────────────

# Garbage-collect store entries older than 7 days
[group('maint')]
gc:
    sudo nix-collect-garbage --delete-older-than 7d
    nix-collect-garbage --delete-older-than 7d

# ───────────────────────────── secrets ────────────────────────────

# Edit an encrypted secret with sops, e.g. `just edit-secret secrets/secrets.yaml`
[group('secrets')]
edit-secret file:
    sops {{ file }}
