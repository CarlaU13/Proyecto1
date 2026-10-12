# Architecture

## Current scope

Proyecto1 is currently a small playable Godot desktop slice. Its eventual product
purpose is an interactive experience that delivers a personalized birthday
surprise. Final gameplay, visual style, duration, content, and personalization
remain to be defined.

The current architecture covers a single top-down room, player movement,
collisions, nearby-object interaction, and reusable dialogue presentation.

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
|-- ui/
|   |-- dialogue_box.gd
|   `-- dialogue_box.tscn
`-- world/
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
- `src/ui/` presents dialogue and accepts keyboard or mouse progression.
- `src/world/interactable.gd` stores the prompt, speaker, and provisional dialogue
  attached to an inspectable `Area2D`.
- `docs/` records current architecture and decisions with lasting consequences.
- `.github/workflows/validate.yml` performs reproducible project import and startup
  checks with the pinned Godot version.

Scene composition and signals keep responsibilities separated without global
state. No autoloads, managers, generic minigame framework, inventory, or external
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
provisional room and detects nearby interactable areas. `Main` converts interaction
requests into dialogue presentation and temporarily disables movement. Closing the
application uses the normal window controls provided by the operating system and
Godot.

## Provisional settings

The viewport and initial window size are set to 1152 x 648 only to provide a
consistent bootstrap window. This is not a product requirement and may change
after the visual and interaction requirements are known.

## Growth rule

New folders, scripts, and abstractions should be introduced only for concrete
behavior. Features should remain locally organized until genuine sharing or a
cross-cutting responsibility appears. GDScript should use gradual static typing
when scripts become necessary.
