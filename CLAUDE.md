# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Defender** is a twin-stick incremental horde game built in Godot 4.6 (Forward Plus rendering, Jolt Physics, D3D12 on Windows). The game is set inside a computer — dark materials with glowy neon lines. The player defends a developing AGI from enemy attacks, collecting "bits" from enemies to spend on a 50-60 node upgrade tree. Target playtime: ~1 hour.

## Running the Project

Open in Godot 4.6 and press Play. The main scene is `system/main.tscn`. There is no CLI build command — all development happens through the Godot editor.

## Architecture

### Entry Point & Flow

`system/main.gd` initializes `MenuManager` with its CanvasLayer and calls `show_menu(Menu.Type.MAIN)`. All scenes are loaded via UIDs registered in `system/prefabs.gd`.

### Menu System (`menu_system/`)

- `menu.gd` — Base `Menu` class (extends `Control`). Defines `Menu.Type` enum: `{TITLE, MAIN, SETTINGS, EXITCONFIRM, PAUSE}`. Provides `show_menu()` / `hide_menu()`.
- `menu_manager.gd` — Singleton accessed via `MenuManager`. Manages a `Dictionary` of `Menu.Type → Menu` instances. Call `MenuManager.show_menu(type)` from anywhere.
- Individual screens (`menus/`) extend `Menu` and override behavior per screen type.

### Gameplay (`gameplay/`)

Component-based architecture. Each entity (`Player`, `Enemy`, `Projectile`, `Pickup`) is a `Node3D` with child component nodes:

- `components/health_component/` — manages HP
- `components/damage_component/` — handles dealing damage
- `components/movement_component/` — handles movement

`gameplay/levels/` contains the `Level` controller and `debug_level.tscn` for testing.

### Prefab Registry

`system/prefabs.gd` is a static resource class holding UIDs for all instantiable scenes. Always add new scenes here rather than using hardcoded paths elsewhere.

## Directives (from README)

1. **Never create UIDs manually** — let Godot generate UIDs when scenes are opened in the editor.
2. **Code must be human-readable** — use verbose variable and function names.
3. **Keep scripts small and focused** — break scenes into nodes, one responsibility per script.
