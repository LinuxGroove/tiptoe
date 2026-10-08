# Extra animation clips

Made by a script, `tools/blender/clips.py`, on Kenney's CC0 models (`<python with bpy> tools/blender/clips.py assets/kenney/mini-characters assets/kenney/cube-pets assets/models/clips`); change the script and rerun it rather than editing these files. Each file is Kenney's model with all of its own clips plus the new ones below, with Kenney's node and bone names, so the clips can be copied onto any Mini Character or onto the dog. Godot imports every clip without looping; set the loop mode on the looping ones in the game.

`mini-character-clips.glb` (character-male-a):

- `startled`: 0.6 s, once. A hop back with hands flung up; ends on idle's first pose.
- `look-around`: 2.5 s, loops. Right hand shading the eyes, looks left, then right.
- `sleep`: 3 s, loops. Flat on the back, arms by the sides, slow breathing. Head toward -Z, feet toward +Z, centred lengthwise on the origin; the back of the torso is 0.007 above the origin.
- `phone-call`: 3 s, loops. Right hand at the ear, left hand gesturing, small nods.
- `sit-watch`: 3 s, loops. Kenney's `sit` pose leaning back, head tipped, slow breathing.

`animal-dog-clips.glb` (animal-dog):

- `sleep`: 3 s, loops. Lying on the floor with legs tucked, slow breathing.
- `bark`: 0.5 s, once. The front pops up and the body jerks forward.
- `sniff`: 1.2 s, loops. Nose to the floor, quick bobs, sweeping side to side.
- `wake`: 0.8 s, once. From `sleep`'s first frame up to standing, with a shake.
