# Credits

Made by the LinuxGroove team.

## Art and audio

Most of it is by [Kenney](https://kenney.nl), released under CC0 (public
domain). Each pack keeps its `License.txt` next to the files in
`assets/kenney/`.

| Pack | Used for |
|---|---|
| Building Kit | Walls, windows, doors and stairs |
| Furniture Kit | Furniture and lamps |
| City Kit (Suburban) | Trees, the planter |
| Mini Characters | Ted and Maggie |
| Cube Pets | Biscuit the dog |
| Food Kit | Treats, the cupcake and the pizza |
| Mini Arena | The trophy |
| Prototype Kit, Platformer Kit, Blaster Kit, Survival Kit, Graveyard Kit | Small props and gadgets |
| Skyboxes | The night sky |
| Music Loops, Music Jingles | Music |
| Impact Sounds | Footsteps |
| Interface Sounds, RPG Audio and others, through Cogito | Doors, switches and pick-ups |

Made for Tiptoe, all CC0 like the rest:

- `assets/models/props/`: the security camera, safe, wall vent, fuse box,
  doorbell and gloves, modelled by a script (`tools/blender/props.py`).
- `assets/models/clips/`: extra animation clips (startled, looking around,
  sleeping, on the phone, watching TV; the dog sleeping, barking, sniffing
  and waking) on Kenney's characters (`tools/blender/clips.py`).
- `assets/audio/sfx/`: sound effects synthesized by a script
  (`tools/sfx/make_sfx.py`); see the README there.

## Code

- [Godot Engine](https://godotengine.org), MIT.
- [COGITO](https://codeberg.org/Phazorknight/Cogito) by Phazorknight and
  contributors, MIT, vendored in `addons/cogito` (see `VENDORED.md` there),
  with Nathan Hoad's [InputHelper](https://github.com/nathanhoad/godot_input_helper)
  (MIT) and Bryce Dixon's [QuickAudio](https://github.com/BtheDestroyer/Godot_QuickAudio)
  (MIT). Cogito's assets are by Kenney, Quaternius (CC0) and Philip Drobar
  (MIT); the freesound.org sounds kept are CC0 (match strike by Bertsz, dirt
  sliding by Laughingfish78, water steaming by Ekrcoaster, footsteps by
  RomanKolachnik).
- [Nakama Godot client](https://github.com/heroiclabs/nakama-godot),
  Apache-2.0, vendored in `addons/com.heroiclabs.nakama` (see `VENDORED.md`).
- The shared LinuxGroove add-on in `addons/linuxgroove`, MIT.
