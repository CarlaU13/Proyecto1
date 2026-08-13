# ADR 0001: Initial technology stack

- Status: Accepted
- Date: 2026-08-09

## Context

The repository needs a small, maintainable foundation for an early-stage desktop
interactive experience. The gameplay and content are not defined, so the initial
stack should support fast iteration without introducing infrastructure for
hypothetical requirements.

## Decision

Use:

- Godot 4.7.1 stable as the engine;
- GDScript as the implementation language;
- the Compatibility renderer;
- Git and GitHub for version control and collaboration;
- Windows x86_64 as the initial target platform.

Keep the architecture scene-oriented and minimal. Add scripts only for actual
behavior and use gradual static typing when GDScript is introduced. Do not add
third-party dependencies or general-purpose architectural systems without a
demonstrated need.

## Consequences

- Contributors need the pinned Godot version for consistent editing and runtime
  validation.
- The Compatibility renderer favors broad hardware support and is sufficient for
  the current undefined visual scope.
- Windows export configuration and artifacts remain separate future work.
- Other platforms, renderers, languages, and gameplay architecture remain open
  decisions rather than current commitments.
