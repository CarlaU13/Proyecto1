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

See [`docs/architecture.md`](docs/architecture.md) for the current project
structure and boundaries.
