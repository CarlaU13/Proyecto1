# Proyecto1

Proyecto1 is an early-stage desktop software project built with Godot and GDScript.
Its eventual purpose is to provide a small interactive experience that delivers a
personalized birthday surprise.

The gameplay, visual style, duration, content, and personalization system are not
defined yet. The current repository contains only the technical bootstrap: a
minimal application with a neutral startup screen and no game mechanics or final
content.

## Technology

- Engine: Godot 4.7.1 stable
- Language: GDScript
- Initial target platform: Windows x86_64
- Renderer: Compatibility

The technology choice and its consequences are recorded in
[`docs/decisions/0001-technology-stack.md`](docs/decisions/0001-technology-stack.md).

## Development requirements

- Godot 4.7.1 stable, including the editor
- Git
- Windows is the initial target platform; export support is not configured yet

No third-party dependencies are required.

## Run locally

1. Open Godot 4.7.1 stable.
2. Import `project.godot` from this repository.
3. Run the project with **F5** or the editor's **Run Project** action.

The application should open a neutral bootstrap screen and close normally through
the operating system window controls.

## Current quality expectations

- The project opens and runs without startup errors in the pinned Godot version.
- Generated Godot metadata and local build output remain outside version control.
- Changes stay small, reviewable, and free of unnecessary dependencies.
- Architectural decisions with meaningful consequences are documented.
- Game mechanics and abstractions are added only when supported by concrete needs.

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

See [`docs/architecture.md`](docs/architecture.md) for the current project
structure and boundaries.
