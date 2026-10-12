# Proyecto1

Proyecto1 is an early-stage desktop software project built with Godot and GDScript.
Its eventual purpose is to provide a small interactive experience that delivers a
personalized birthday surprise.

The final visual style, duration, broader gameplay, content, and personalization
system remain open. The current playable slice contains one provisional top-down
room, free WASD movement, simple collisions, inspectable objects, narrator
dialogue, and one complete newspaper crossword. It contains no birthday content
or final assets yet.

## Technology

- Engine: Godot 4.7.1 stable
- Language: GDScript
- Initial target platform: Windows x86_64
- Renderer: Compatibility

The technology choice and its consequences are recorded in
[`docs/decisions/0001-technology-stack.md`](docs/decisions/0001-technology-stack.md).

## Development requirements

- Godot 4.7.1 stable, including the editor
- Official Godot 4.7.1 stable export templates for local Windows builds
- Git
- Windows x86_64 is the initial target platform

No third-party dependencies are required.

## Run locally

1. Open Godot 4.7.1 stable.
2. Import `project.godot` from this repository.
3. Run the project with **F5** or the editor's **Run Project** action.

The application should open the provisional room and close normally through the
operating system window controls.

Current controls:

- `WASD`: move the character;
- `E`: inspect a nearby object;
- `Enter` or the on-screen button: advance dialogue.
- `H` or the on-screen button: request a hint while reading the crossword;
- `Escape`: close the crossword.

Inspect the cup, clock, and portrait to reveal the crossword clues. The puzzle
allows unlimited retries and unlocks the provisional north door when solved.

## Current quality expectations

- The project opens and runs without startup errors in the pinned Godot version.
- Generated Godot metadata and local build output remain outside version control.
- Changes stay small, reviewable, and free of unnecessary dependencies.
- Architectural decisions with meaningful consequences are documented.
- Game mechanics and abstractions are added only when supported by concrete needs.
- Player-facing text is currently written in Spanish; technical names and
  repository documentation remain in English.

## Validation

Run the same project checks locally before committing. On Windows PowerShell,
replace `<godot>` with the path to the Godot 4.7.1 stable executable:

```powershell
& <godot> --version
& <godot> --headless --path . --import --verbose
& <godot> --headless --path . --quit-after 120 --verbose
git diff --check
```

The first Godot command must report `4.7.1.stable.official.a13da4feb`. All commands
must exit successfully without parser, resource, startup, or runtime errors.

GitHub Actions repeats the import and startup checks on every pull request and on
every push to `main`. The workflow validates the project only; it does not export
or publish an application.

## Windows build

The repository includes a `Windows x86_64` export preset. Install the official
Godot 4.7.1 stable export templates, create the output directory, and export a
release build from Windows PowerShell:

```powershell
New-Item -ItemType Directory -Force build/windows | Out-Null
& <godot> --headless --path . --export-release "Windows x86_64"
```

The build is written to `build/windows/Proyecto1.exe` with its accompanying data
package. The entire `build/` directory is local and ignored by Git. Code signing,
an installer, release publishing, and automated export are not configured yet.

See [`docs/architecture.md`](docs/architecture.md) for the current project
structure and boundaries.
