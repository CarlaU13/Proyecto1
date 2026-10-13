# Gameplay

## Current playable sequence

The player explores a top-down house, gathers environmental clues, solves the
newspaper crossword, enters the library, and plays hangman against the librarian.
The hangman answer is also the password for an evidence chest. Opening the chest
reveals the narrative setup and starts a playable social deduction round.

Player-facing content is written in Spanish. The descriptions in this document
record product intent and do not define final story text, names, balance, or art.

## Current impostor round

The impostor game is a word-association deduction round:

1. Every regular participant receives the same secret word.
2. The impostor does not receive that word. They receive a related contextual hint
   so their answers are plausible rather than obviously random.
3. Each participant says one word related to the secret word.
4. The player compares those statements and identifies the participant who appears
   to be improvising without knowing the exact secret.

The first provisional round uses `AJEDREZ` as the secret word. Four participants
give specific chess terms. The impostor receives the broader hint `JUEGO DE MESA`
and answers `TABLERO`. Wrong accusations eliminate that choice without resetting
the round, and requested hints explain the intended deduction progressively.

All participant labels and round content are kept together in
`src/puzzles/impostor_game.gd` so they can be replaced without changing scene
coordination. They are sample content, not final character or narrative decisions.
Randomized rounds, difficulty variants, replay rules, and the consequence of
solving the interrogation remain undecided.
