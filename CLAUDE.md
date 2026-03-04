# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pathfinder Beyond is a free, open-source character sheet app for Pathfinder 1st Edition. It features real-time collaboration via WebSocket and no login required (characters are accessed by shareable link).

## Language

The entire codebase is written in **Haxe 4** (a statically typed language that compiles to JavaScript). There is no TypeScript, no React, no framework — just Haxe compiling to plain JS. Understanding Haxe syntax is required to work in this repo.

## Build Commands

### Backend
```bash
cd backend
npm install           # first time only
npm run watch         # compile + run with hot reload (uses nodemon)
# Manual: haxe make.hxml && node bin/server.js
```

### Frontend
```bash
cd frontend
./watch.sh            # rebuild on .hx and .scss changes (uses inotifywait)
# Manual: haxe make.hxml    → outputs ../backend/static/main.js
# Manual: sass scss/main.scss ../backend/static/main.css
```

There are no tests and no linter — Haxe's static type system catches most errors at compile time.

**Always run both `cd frontend && haxe make.hxml` and `cd backend && haxe make.hxml` after any edit and fix all errors before considering the task done.**

### Docker
```bash
docker build -t pathfinder-beyond .
docker run -e DB_PASSWORD=<password> -p 8000:8000 pathfinder-beyond
```

### Environment
- `DB_PASSWORD`: MySQL password (required)
- MySQL must be reachable at `mysql:3306`, database `pfb`
- Server runs on port 8000

## Architecture

The codebase has three parts sharing the same language:

```
shared/     ← compiled into both backend and frontend
backend/    ← Node.js + Express server
frontend/   ← browser JS (no framework)
```

### Event Sourcing / State Machine

Character state is **never stored directly** — only events are persisted. The flow:

1. UI action → `Api.pushEvent(ficheId, EventType)` (REST POST)
2. Backend stores event in `fiche_events` table (append-only)
3. Backend broadcasts via WebSocket to all subscribers
4. All clients replay events through `FullCharacter.processEvent()` to derive current state

This means `shared/FullCharacter.hx` is the single source of truth for character state. Modifying character data always means adding a new `FicheEventType` variant (defined in `shared/Protocol.hx`).

### Key Files

| File | Role |
|------|------|
| `shared/Protocol.hx` | All event types (`FicheEventType`) and WebSocket message types |
| `shared/FullCharacter.hx` | Event processor + derived character state (HP, modifiers, etc.) |
| `shared/Rules.hx` | Game rule calculations (AC, saving throws, initiative, skills) |
| `shared/RulesSkills.hx` | Pathfinder skill definitions |
| `frontend/src/Fiche.hx` | Main character sheet UI (816 lines — largest file) |
| `frontend/src/App.hx` | Client-side router (dispatches to `Fiche` or `Campaign`) |
| `frontend/src/Api.hx` | REST API client |
| `frontend/src/WsTalker.hx` | WebSocket client for real-time updates |
| `backend/src/Server.hx` | Express server entry point |
| `backend/src/FicheRouter.hx` | REST API routes |
| `backend/src/WebsocketClient.hx` | WebSocket subscriptions + broadcasting |
| `backend/src/model/DatabaseHandler.hx` | MySQL connection + schema migrations |

### HTML Templates

Frontend HTML is embedded as Haxe resources in `frontend/src/assets/*.tpl.html` and declared in `frontend/make.hxml` with `--resource`. They are accessed at runtime via `haxe.Resource.getString("fiche.html")`.

### Adding a New Character Feature

1. Add a new variant to `FicheEventType` in `shared/Protocol.hx`
2. Handle the event in `FullCharacter.processEvent()` in `shared/FullCharacter.hx`
3. Update game rule calculations in `shared/Rules.hx` if needed
4. Add UI in `frontend/src/Fiche.hx` to create and display the event
5. Add a dialog component in `frontend/src/elems/` if needed

### Haxe Conventions

- **Extend, don't reimplement.** If a dialog needs extra fields (e.g. damage type picker appended to an amount input), extend the existing dialog class (`AmountChoice`, etc.) and append to `getContent()` after calling `super()`. Do not copy its logic.
- **Use `Enum.createByName()`** to convert a `String` to an enum value — never write a manual switch for this. Create enum values as early as possible (e.g. in the frontend when reading form inputs), rather than passing raw strings to the backend for parsing. Store the full enum constructor name (e.g. `ALIGNEMENT_NB`, `SIZE_M`) in form option values so `createByName` can be called directly without prefix manipulation.
- **Use `using ProtocolUtil`** (extension-method style) rather than calling `ProtocolUtil.method(value)` directly. French display labels for protocol types belong in `shared/ProtocolUtil.hx`. The same pattern applies to `Rules`, `RulesSkills`, etc.
- **`querySelectorAll` returns `NodeList<Node>`** — items must be cast before accessing Element-specific fields: `(cast nodeList.item(i) : js.html.Element).classList`.
- **Events accumulate, not overwrite.** When an event modifies a numeric value on a character (resistances, modifiers, etc.), it should add to the current value (`current + amount`), not replace it (`set`). Replacing breaks event-sourcing replay correctness.
- **Never assign a variable to a block, `for`, or `while`.** You may assign to an `if` or `switch` expression. To count map/iterator entries, use an array comprehension: `[for (_ in map.keys()) true].length`.
- **No bare `else` when all cases are explicit.** In if/else-if chains where every case is named (e.g. menu choices), use `else if (choice == N)` for every branch. A trailing `else` obscures intent.
- **Use `enum abstract`, not `@:enum abstract`.** The `@:enum` metadata form is deprecated in Haxe 4.
- **Avoid repeating the same expression in every branch.** If a value is computed identically in most or all cases of a switch, hoist it above the switch instead.
- **Use `Serializer.run` / `Unserializer.run` for frontend↔backend communication**, not JSON. This preserves Haxe enum types across the wire without any backend parsing. See `pushEvent` and `createFiche` in `Api.hx` / `FicheRouter.hx` as the reference pattern.
