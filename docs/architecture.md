# Architecture

## Current scope

Proyecto1 is currently a small playable Godot desktop slice. Its eventual product
purpose is an interactive experience that delivers a personalized birthday
surprise. Final gameplay, visual style, duration, content, and personalization
remain to be defined.

The current architecture covers a single top-down room, player movement,
collisions, nearby-object interaction, reusable dialogue presentation, and one
complete exploration-linked newspaper crossword.

## Structure

```text
project.godot
export_presets.cfg
src/
|-- app/
|   |-- main.gd
|   `-- main.tscn
|-- player/
|   |-- player.gd
|   `-- player.tscn
|-- puzzles/
|   |-- newspaper_crossword.gd
|   `-- newspaper_crossword.tscn
|-- ui/
|   |-- dialogue_box.gd
|   `-- dialogue_box.tscn
`-- world/
    |-- exit_door.gd
    `-- interactable.gd
docs/
|-- architecture.md
`-- decisions/
    `-- 0001-technology-stack.md
.github/
`-- workflows/
    `-- validate.yml
```

- `project.godot` is the project entry configuration and selects the main scene.
- `export_presets.cfg` defines the reproducible Windows x86_64 export settings.
- `src/app/` composes the room and coordinates player interaction with dialogue.
- `src/player/` owns movement, collision, camera follow, and nearby-object
  detection.
- `src/puzzles/newspaper_crossword.*` owns the crossword grid, answer validation,
  unlimited retries, progressive requested hints, and puzzle-local presentation.
- `src/ui/` presents dialogue and accepts keyboard or mouse progression.
- `src/world/interactable.gd` stores the identity, optional clue identity, prompt,
  speaker, and dialogue attached to an inspectable `Area2D`.
- `src/world/exit_door.gd` owns the door's locked/unlocked state and visual change.
- `docs/` records current architecture and decisions with lasting consequences.
- `.github/workflows/validate.yml` performs reproducible project import and startup
  checks with the pinned Godot version.

Scene composition and signals keep responsibilities separated without global
state. `Main` retains only the current room's discovered clues and coordinates the
newspaper result with the door. The crossword is intentionally a concrete feature,
not a generic minigame framework. No autoloads, managers, inventory, or external
dependencies are justified at this stage.

## Automated validation

The validation workflow downloads the official Godot 4.7.1 Linux editor and
checks its SHA-256 digest before execution. It confirms the exact engine build,
imports and parses the project in headless mode, then starts the main scene for a
bounded number of iterations.

The workflow has read-only repository permissions. It does not run tests, create
exports, publish artifacts, or validate the Windows distribution. Runtime checks
on Windows and visual presentation remain local responsibilities.

## Windows distribution

The `Windows x86_64` preset produces a release executable and separate project
data package under `build/windows/`. Build artifacts are ignored by Git. The
preset does not enable code signing, an installer, remote deployment, or automated
publishing. Those concerns remain deferred until a concrete distribution channel
requires them.

## Runtime flow

Godot loads `src/app/main.tscn` as the main scene. The player moves through one
provisional room and detects nearby interactable areas. Inspecting the cup, clock,
and portrait records three local clues. Reading *La Gaceta Imposible* opens the
crossword and temporarily disables movement. Correct answers emit a completion
signal; `Main` uses it to unlock the north door. Dialogue and the puzzle remain
separate UI scenes, and closing either restores movement. Closing the application
uses the normal window controls provided by the operating system and Godot.

## Provisional settings

The viewport and initial window size are set to 1152 x 648 only to provide a
consistent bootstrap window. This is not a product requirement and may change
after the visual and interaction requirements are known.

## Growth rule

New folders, scripts, and abstractions should be introduced only for concrete
behavior. Features should remain locally organized until genuine sharing or a
cross-cutting responsibility appears. GDScript should use gradual static typing
when scripts become necessary.
