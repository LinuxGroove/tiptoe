# Tiptoe

A cat burglar in reverse. Augustus Hoard has "borrowed" half the town's
treasures, and you're the one quietly taking them home.

A first person stealth game built with Godot 4 and [COGITO](https://codeberg.org/Phazorknight/Cogito)
for Ubuntu. Design: [idea 17](https://github.com/LinuxGroove/game-ideas/blob/main/ideas/17-tiptoe.md)
in game-ideas.

## How a job plays

- Pick a job on the job board and where to start from. Get the treasure and
  get back to where you started without being caught.
- **Light** shows you: the gem at the bottom of the screen says how lit you
  are. Keep to the dark, and turn lights off (or cut the power).
- **Noise** carries: every step makes a noise, louder on wood and tiles than
  on carpet and grass, quieter crouched, louder sprinting. Walls and closed
  doors muffle it. Rings on screen show every noise (you can turn them off).
- **People** follow their routines. A little suspicion and they come to look;
  a full meter and they've spotted you. Get caught and you're marched back
  out of the garden, without the treasure.
- **Capers** are clever ways of doing a job (get in without a key, leave the
  dog asleep, swap the trophy for a cupcake). Every two capers raise your
  mastery of a job, which unlocks start points and gadgets.
- **Leads** are notes and flyers that point you at another way in, step by
  step. Turn them off in the pause menu if you'd rather work it out.

The first job is **Maple Close**: the Pembertons' house, where Ted watches
the telly, Maggie potters about upstairs and Biscuit the dog sleeps by the
back door. The bakery's prize trophy is in the upstairs study.

## Controls

| Action | Keyboard and mouse | Controller |
|---|---|---|
| Move | WASD | Left stick |
| Look | Mouse | Right stick |
| Crouch | Ctrl or C | B |
| Sprint | Shift | Left stick press |
| Jump, climb onto ledges and sills | Space | A |
| Lean | Q and E | LB and RB |
| Use (open, read, take, switch) | F | X |
| Pick a lock | R | Y |
| Throw the noisemaker | Left click | RT |
| Toss a dog treat | Right click | LT |
| Capers | J | D-pad down |
| Pause | Esc | Start |

## Running from source

```sh
godot --headless --path . --import && godot --headless --path . --import
godot --path . -- --job=maple_close --start=street
```

`--job` skips the menus. Tests: `godot --headless --path . tests/run_tests.tscn`.
Screenshots of a level: `xvfb-run godot --path . tools/screenshot.tscn -- --out=/tmp/shots`.

Everything works offline; nothing in Tiptoe needs a server yet.

## License

Code is MIT (see `LICENSE`); assets are CC0 or MIT. See `CREDITS.md`.
