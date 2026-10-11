# Tiptoe

A first person stealth game, a cat burglar in reverse, in Godot 4.7 with GDScript on top of the COGITO immersive sim template. The concept is idea 17 in [game-ideas](https://github.com/LinuxGroove/game-ideas/blob/main/ideas/17-tiptoe.md). It shares the LinuxGroove add-on with the other games; **read game-ideas' [online-addon.md](https://github.com/LinuxGroove/game-ideas/blob/main/online-addon.md) before touching online features or the shared add-on.**

## Commands

```sh
godot --headless --path . --import && godot --headless --path . --import   # twice: Cogito's fonts fail the first time
godot --headless --path . tools/check_scripts.tscn                  # every script compiles
godot --headless --path . tests/run_tests.tscn -- --games=3         # unit tests and scripted nights against the AI
godot --path . -- --job=maple_close --start=street                  # straight into a job
xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 tools/screenshot.tscn -- --out=/tmp/shots [--job=market] [--view=who]
xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 tools/screenshot.tscn -- --all=docs/screenshots [--job=market]
```

On a server with no GPU, xvfb gives Godot no Vulkan and it falls back to OpenGL, which looks paler than the game; install `mesa-vulkan-drivers` and set `VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json` for screenshots in the real renderer (slowly: a whole `--all` run takes a while).

Run the script check and the tests before every commit. A new `class_name` needs an `--import` before the script check finds it. Headless runs reimport assets and rewrite `*.import` files and `icon.png.import`; revert those (`git checkout -- '*.import'`, `rm icon.png.import`) unless you meant to change them.

## Layout

| Path | What |
|---|---|
| `game/game_config.gd` | `GAME_ID`, setting defaults, input map (Cogito's action names) |
| `game/jobs/` | `JobDef`, `CaperDef`, `LeadDef`, `JobRun` (events, capers, leads, score), `Jobs`, the job scene, and one folder per job (its data and its level) |
| `game/world/` | `Kit` (placing Kenney pieces with collision), `JobLevel` (walls a line at a time, floors, lamps, switches, notes, pick-ups, navigation), `HouseDoor`, `UsableBody` and `UseAction` |
| `game/people/` | `Person` (routines, sight, hearing, suspicion, chase), `Dog`, `Rigs` (models with the extra clips) |
| `game/player/` | `Moth` (extends `CogitoPlayer`: lean, climb, bag, disguise), `Gadgets` |
| `game/stealth/` | `StealthNoise`, footstep noise, `LightProbe`, footstep sounds per surface |
| `game/ui/` | Title and job board, HUD, pause menu, results |
| `game/progress.gd` | `Progress` autoload: capers, leads, mastery, best scores (user://progress.cfg) |
| `addons/cogito/` | Vendored COGITO 1.1.5 with local changes (see its `VENDORED.md`) |
| `addons/linuxgroove/` | Shared LinuxGroove add-on |
| `addons/com.heroiclabs.nakama/` | Vendored Nakama client with a local patch (see its `VENDORED.md`) |
| `assets/` | Kenney packs (`kenney/`), Blender-made props and clips (`models/`), synthesized sounds (`audio/sfx/`) |
| `tools/` | Script checker, screenshots, Blender scripts, the sound synthesizer |
| `docs/screenshots/` | Every job's places, start points and people, and the menus, made by `tools/screenshot.tscn -- --all=docs/screenshots` |

## How the game is built

- **Levels are code.** A job's level extends `JobLevel` and lays walls with `line()` (one character per 2 m piece: `W` wall, `w` window, `o` open window, `p` pryable window, `D` door, `d` doorway, `-` low wall), plus floors, lamps and things to use. Storeys are 2.5 m; X runs east and Z south.
- **Events drive everything.** The level, people and gadgets call `JobRun.record("event")`; capers and leads are lists of event names in the job's data, so a new caper is usually just data plus one `record` call.
- **Layers**: 1 world, 2 interactables, 4 people, 8 window glass (stops bodies, not sight, light or sound), 16 doors (people walk through open leaves). `Kit.LAYER_SOLID` is what blocks sight, light and sound.
- **People** navigate a mesh baked at runtime from `Kit.NAV_GROUP` (doors left out; people open them as they walk). Listeners join the "hears" group; anything that makes a sound calls `StealthNoise.make`.
- **Cogito** provides the player controller, interaction raycast and prompts, and footsteps. Tiptoe's own interactables, HUD, pause menu and AI replace the rest; keep Cogito's files as they are and list any change in its `VENDORED.md`.
- **Play tests.** The shared add-on's `LGPlaytest` records a play test when the Play test recording setting is on (or with `-- --playtest`): a picture every few seconds, game events, frame times and controls, the player's notes (F8, or Note this moment in the pause menu) and a survey when they quit, all in one zip in `user://playtest/`. Game events go through `LGPlaytest.event()` and `moment()`; the round's own survey questions (and standard ones to skip) are `GameConfig.PLAYTEST`. Quit through `LGScenes.quit()` so the survey comes first.
- **Everything works offline.** No server or network is needed.
- **Launch ping.** `game/main.gd` calls `LGLaunchPing.send(GameConfig.GAME_ID)` at startup: one anonymous request to the game server's `/launch` (game, random install id, version, OS, CPU) so the server counts every player, online or not. It's skipped headless, from source and with `DO_NOT_TRACK` set, and never blocks or retries.

## The shared add-on

`addons/linuxgroove/` and `addons/com.heroiclabs.nakama/` are copies shared with [Foam Frenzy](https://github.com/LinuxGroove/foam-frenzy) and [Lantern Out](https://github.com/LinuxGroove/LampLighters). Fix shared behaviour in the add-on, not with a workaround here, keep it game-agnostic, and port the change to the other games in the same piece of work. When the change affects how games should use the add-on, update online-addon.md in game-ideas too.

## Style

- Match the surrounding code: `##` doc comments on classes and non-obvious functions, short comments only where the reason isn't obvious.
- Connect signals with methods (or `bind`), not lambdas.
- Build pieces so tests can drive them without a scene change: `JobRun` needs no level, and levels build without a player.
- Player-facing text is plain and short, in the game's words (jobs, capers, leads, the treasure).

## Releases

Pushing to `main` builds the snap and publishes it to the `edge` channel; a GitHub release publishes to `candidate`. Until the `tiptoe` snap is registered in the Snap Store, `PUBLISH` in `snap.yml` is `"false"`, so builds keep the snap as an artifact and publish nothing. The **Windows and macOS** workflow (`desktop.yml`) exports both from Linux. CI injects the server key from the `GAME_SERVER_KEY` secret, so never commit the real key; `SERVER_KEY` stays `defaultkey` in git.

Versions are `vYYYY.WW.MINOR`, derived from git by `tools/version.sh`; make releases with the **Release** workflow. Commit subjects become the release notes, so write them for players.
