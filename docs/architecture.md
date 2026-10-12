# Architecture

## Current scope

Proyecto1 is currently a small playable Godot desktop slice. Its eventual product
purpose is an interactive experience that delivers a personalized birthday
surprise. Final gameplay, visual style, duration, content, and personalization
remain to be defined.

The current architecture covers two connected top-down rooms, player movement,
collisions, nearby-object interaction, reusable dialogue presentation, one
complete exploration-linked newspaper crossword, and persistent in-session room
state. A second concrete puzzle provides a complete hangman round in the library.

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
|   |-- hangman.gd
|   |-- hangman.tscn
|   |-- newspaper_crossword.gd
|   `-- newspaper_crossword.tscn
|-- rooms/
|   `-- library.tscn
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
- `src/puzzles/hangman.*` owns its fixed word, alphabet input, mistake drawing,
  optional hints, round retry, completion state, and puzzle-local presentation.
- `src/rooms/library.tscn` defines the second room, its physical boundaries,
  provisional librarian, word board, and return door.
- `src/ui/` presents dialogue and accepts keyboard or mouse progression.
- `src/world/interactable.gd` stores the identity, optional clue identity, prompt,
  speaker, and dialogue attached to an inspectable `Area2D`.
- `src/world/exit_door.gd` owns the door's locked/unlocked state and visual change.
- `docs/` records current architecture and decisions with lasting consequences.
- `.github/workflows/validate.yml` performs reproducible project import and startup
  checks with the pinned Godot version.

Scene composition and signals keep responsibilities separated without global
state. `Main` retains only the current session's discovered clues and visit state,
and coordinates puzzle results with their immediate world consequences. Both
puzzles remain concrete features rather than implementations of a generic
minigame framework. No autoloads, managers, inventory, or external dependencies
are justified at this stage.

Both rooms currently coexist at separate coordinates in one persistent world.
`Main` moves the persistent player between explicit spawn markers and asks the
player scene to update its camera bounds. This small arrangement preserves local
state without an autoload or room manager. It is provisional: scene loading should
only replace it if room count, memory use, or independent room lifecycles create a
concrete need.

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

Godot loads `src/app/main.tscn` as the main scene. The player moves through two
provisional rooms and detects nearby interactable areas. Inspecting the cup,
clock, and portrait records three local clues. Reading *La Gaceta Imposible* opens
the crossword and temporarily disables movement. Correct answers emit a completion
signal; `Main` uses it to unlock the north door. The unlocked door moves the same
player instance to the library, updates camera bounds, and shows an introductory
dialogue only on the first visit. The return door reverses the transition without
recreating either room, so the crossword and unlocked door retain their state.
Interacting with the library word board opens the hangman scene and disables
movement. Solving it updates the physical board and librarian dialogue; failing a
round only enables a local retry. Dialogue and both puzzle scenes remain separate
UI scenes, and closing any of them restores movement. Closing the application
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
