# Architecture

## Current scope

Proyecto1 is currently a minimal Godot desktop application. Its eventual product
purpose is a small interactive experience that delivers a personalized birthday
surprise. Gameplay, visual style, duration, content, and personalization remain
to be defined.

The current architecture deliberately covers only application startup and a
neutral bootstrap screen.

## Structure

```text
project.godot
src/
`-- app/
    `-- main.tscn
docs/
|-- architecture.md
`-- decisions/
    `-- 0001-technology-stack.md
```

- `project.godot` is the project entry configuration and selects the main scene.
- `src/app/main.tscn` is the single application scene and owns the current static
  bootstrap UI.
- `docs/` records current architecture and decisions with lasting consequences.

No script is present because the bootstrap screen requires no runtime behavior.
No autoloads, managers, shared abstractions, feature modules, or external
dependencies are justified at this stage.

## Runtime flow

Godot loads `src/app/main.tscn` as the main scene. The scene displays two static
labels on a neutral background. Closing the application uses the normal window
controls provided by the operating system and Godot.

## Provisional settings

The viewport and initial window size are set to 1152 x 648 only to provide a
consistent bootstrap window. This is not a product requirement and may change
after the visual and interaction requirements are known.

## Growth rule

New folders, scripts, and abstractions should be introduced only for concrete
behavior. Features should remain locally organized until genuine sharing or a
cross-cutting responsibility appears. GDScript should use gradual static typing
when scripts become necessary.
