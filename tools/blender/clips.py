"""Adds Tiptoe's extra animation clips to Kenney's Mini Characters rig and Cube Pets dog.

usage: <python with bpy> tools/blender/clips.py <kenney_mini_characters_dir> <kenney_cube_pets_dir> <out_dir>

Writes <out_dir>/mini-character-clips.glb (character-male-a with all of Kenney's clips plus
startled, look-around, sleep, phone-call and sit-watch) and <out_dir>/animal-dog-clips.glb
(animal-dog with its clips plus sleep, bark, sniff and wake). Node and bone names and the
hierarchy are Kenney's, so the clips play on any Mini Character or on the dog.

The new clips follow Kenney's: linear keys 30 times a second, short and snappy. On the people
every clip keys root location and the rotation of every bone; on the dog every clip keys
location, rotation and scale of all six nodes, as Kenney's dog clips do.

Pose conventions on the Mini Characters rig, in Blender's view of each bone (every bone has
the same rest axes): x is the character's left, y is up and z is forward. A positive x
rotation tips the top of a bone forward (torso bows, head nods down) and swings a leg back;
a positive y rotation turns to the character's left. The arms rest straight out to the
sides (T pose); Kenney's idle hangs them 45 degrees down.
"""
import math
import os
import sys

import bpy
from mathutils import Quaternion, Vector, Euler

KEY_RATE = 30   # keys per second, as in Kenney's clips
FRAME_RATE = 24  # timeline frames per second the glTF importer and exporter convert with
BONES = ("root", "torso", "head", "arm-left", "arm-right", "leg-left", "leg-right")
DOG_PARTS = ("root", "body", "leg-back-left", "leg-back-right", "leg-front-left", "leg-front-right")


# ---------------------------------------------------------------- timing helpers

def smooth(u):
    """Smoothstep ease from 0 to 1."""
    u = min(1.0, max(0.0, u))
    return u * u * (3 - 2 * u)


def ease_out(u):
    """Fast start, soft landing (for snappy moves)."""
    u = min(1.0, max(0.0, u))
    return 1 - (1 - u) ** 3


def mix(a, b, u):
    if isinstance(a, (int, float)):
        return a + (b - a) * u
    return tuple(x + (y - x) * u for x, y in zip(a, b))


def keyed(t, keys, ease=smooth):
    """Value at time t from [(time, value), ...], eased between neighbouring keys.
    A key may be (time, value, ease) to use another ease into that key."""
    if t <= keys[0][0]:
        return keys[0][1]
    for k0, k1 in zip(keys, keys[1:]):
        if t <= k1[0]:
            e = k1[2] if len(k1) > 2 else ease
            return mix(k0[1], k1[1], e((t - k0[0]) / (k1[0] - k0[0])))
    return keys[-1][1]


def wave(t, period, phase=0.0):
    """Sine with the given period in seconds; phase in turns."""
    return math.sin(2 * math.pi * (t / period + phase))


def bump(t, at, width):
    """A single smooth 0-1-0 pulse centred on `at`, `width` seconds wide."""
    u = (t - at) / width + 0.5
    return math.sin(math.pi * u) ** 2 if 0 < u < 1 else 0.0


# ---------------------------------------------------------------- scene helpers

def import_glb(path):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.fps, scene.render.fps_base = FRAME_RATE, 1.0
    bpy.ops.import_scene.gltf(filepath=path)


def new_action(name, objects):
    """A layered action with one slot per object, stashed in each object's NLA like the
    importer stashes Kenney's clips, so the exporter writes it as one glTF animation.
    Returns {object name: channelbag}."""
    action = bpy.data.actions.new(name)
    strip = action.layers.new("layer0").strips.new(type="KEYFRAME")
    bags = {}
    for obj in objects:
        slot = action.slots.new("OBJECT", obj.name)
        bags[obj.name] = strip.channelbag(slot, ensure=True)
        track = obj.animation_data.nla_tracks.new(prev=None)
        track.name = name
        nla = track.strips.new(name, 0, action)
        nla.action_slot = slot
        track.lock = track.mute = True
    return action, bags


def write_curves(bag, data_path, group, samples):
    """samples: [(seconds, tuple)]; one linear fcurve per component."""
    if group not in bag.groups:
        bag.groups.new(group)
    for i in range(len(samples[0][1])):
        fc = bag.fcurves.new(data_path, index=i)
        fc.group = bag.groups[group]
        fc.keyframe_points.add(len(samples))
        co = []
        for t, v in samples:
            co += [t * FRAME_RATE, v[i]]
        fc.keyframe_points.foreach_set("co", co)
        fc.keyframe_points.foreach_set("interpolation", [1] * len(samples))  # LINEAR
        fc.update()


def sample_times(length):
    n = round(length * KEY_RATE)
    return [length * k / n for k in range(n + 1)]


def continuous(quats):
    """Flips quaternion signs so neighbouring keys take the short way round."""
    out = [quats[0]]
    for q in quats[1:]:
        out.append(-q if out[-1].dot(q) < 0 else q)
    return out


# ---------------------------------------------------------------- people

def rot(x=0.0, y=0.0, z=0.0):
    """Bone rotation from Euler degrees in the bone's axes (x left, y up, z forward)."""
    return Euler((math.radians(x), math.radians(y), math.radians(z))).to_quaternion()


def arm(side, elev, fwd=0.0, twist=0.0):
    """Arm rotation that points the arm `elev` degrees above horizontal (negative hangs it)
    and swings it `fwd` degrees toward the front, then twists it about its length."""
    out = 1.0 if side == "left" else -1.0
    e, f = math.radians(elev), math.radians(fwd)
    d = Vector((out * math.cos(e) * math.cos(f), math.sin(e), math.cos(e) * math.sin(f)))
    q = Vector((out, 0, 0)).rotation_difference(d)
    return Quaternion(d, math.radians(twist * out)) @ q


def person(root_loc=(0, 0, 0), root_rot=(0, 0, 0), torso=(0, 0, 0), head=(0, 0, 0),
           arm_left=(-45, 0), arm_right=(-45, 0), leg_left=(0, 0, 0), leg_right=(0, 0, 0)):
    """A whole pose. Defaults are the first frame of Kenney's idle. Arms are (elev, fwd[, twist])."""
    return {
        "root_loc": tuple(root_loc),
        "root": rot(*root_rot),
        "torso": rot(*torso),
        "head": rot(*head),
        "arm-left": arm("left", *arm_left),
        "arm-right": arm("right", *arm_right),
        "leg-left": rot(*leg_left),
        "leg-right": rot(*leg_right),
    }


def bake_person(rig, name, length, pose):
    """Keys pose(t) on the rig at KEY_RATE from 0 to length seconds."""
    _, bags = new_action(name, [rig])
    bag = bags[rig.name]
    times = sample_times(length)
    poses = [pose(t) for t in times]
    write_curves(bag, 'pose.bones["root"].location', "root", [(t, p["root_loc"]) for t, p in zip(times, poses)])
    for bone in BONES:
        quats = continuous([p[bone] for p in poses])
        write_curves(bag, f'pose.bones["{bone}"].rotation_quaternion', bone,
                     [(t, tuple(q)) for t, q in zip(times, quats)])


# Kenney's sit lowers the root 0.15 and swings both legs 75 degrees forward.
SIT_ROOT = (0, -0.15, 0)
SIT_LEGS = (-75, 0, 0)

# Lying on the back: the root turns -90 about x (head toward the character's back, which is
# glTF -Z), lifts the back of the torso to just above the origin and slides the body
# toward the feet so it is centred lengthwise on the origin.
SLEEP_ROOT = (0, 0.17, 0.33)
SLEEP_ROOT_ROT = (-90, 0, 0)


def person_startled(t):
    """startled, 0.6 s, once: a hop back with hands flung up, then settles to idle's first pose."""
    hop = keyed(t, [(0, 0), (0.07, 1, ease_out), (0.16, 0.35), (0.24, 0.0), (0.6, 0)])
    back = keyed(t, [(0, 0), (0.08, 1, ease_out), (0.3, 1), (0.6, 0)])
    up = keyed(t, [(0, 0), (0.07, 1, ease_out), (0.32, 1), (0.6, 0)])
    shiver = math.sin(t * 2 * math.pi * 14) * keyed(t, [(0.1, 0), (0.18, 1), (0.34, 0)])
    return person(
        root_loc=(0, 0.06 * hop, -0.05 * back),
        torso=(-16 * up, 0, 0),
        head=(-12 * up, 4 * shiver, 0),
        arm_left=(mix(-45, 55, up) + 4 * shiver, 22 * up),
        arm_right=(mix(-45, 55, up) - 4 * shiver, 22 * up),
        leg_left=(-18 * hop, 0, -6 * up),
        leg_right=(14 * hop, 0, 6 * up),
    )


def person_look_around(t):
    """look-around, 2.5 s, loops: a hand shading the eyes, looking left, then right."""
    turn = keyed(t, [(0, 0), (0.35, 1), (0.95, 1), (1.45, -1), (2.05, -1), (2.5, 0)])
    breathe = wave(t, 1.25)
    return person(
        torso=(-2 + breathe, 16 * turn, 0),
        head=(-6, 24 * turn, -3 * turn),
        arm_left=(-50 + 3 * breathe, -6),
        arm_right=(48 + 2 * breathe, 72, 30),
        leg_left=(0, 0, 0),
        leg_right=(0, 0, 0),
    )


def person_sleep(t):
    """sleep, 3 s, loops: flat on the back, arms by the sides, one slow breath."""
    breath = 0.5 - 0.5 * math.cos(2 * math.pi * t / 3.0)
    return person(
        root_loc=SLEEP_ROOT,
        root_rot=SLEEP_ROOT_ROT,
        torso=(4 * breath, 0, 0),
        head=(-4 * breath, 10, 0),
        arm_left=(-72 + 2 * breath, -42),  # swung back: Kenney's arms angle forward
        arm_right=(-72 + 2 * breath, -42),
        leg_left=(0, 0, -4),
        leg_right=(0, 0, 4),
    )


def person_phone_call(t):
    """phone-call, 3 s, loops: right hand at the ear, left hand talking, little nods."""
    nod = bump(t, 0.5, 0.35) + bump(t, 0.9, 0.35) + 0.7 * bump(t, 2.1, 0.4)
    talk = keyed(t, [(0, 0), (0.7, 0), (1.0, 1), (1.4, 0.6), (1.7, 1), (2.2, 0), (3.0, 0)])
    sway = wave(t, 3.0)
    return person(
        torso=(1 + 1.5 * wave(t, 1.5), 5 * sway, 0),
        head=(4 + 9 * nod, -4 + 3 * sway, 9),
        arm_left=(mix(-48, -15, talk), mix(0, 50, talk), 20 * talk),
        arm_right=(62, 10, 0),
        leg_left=(0, 0, 0),
        leg_right=(0, 0, 0),
    )


def person_sit_watch(t):
    """sit-watch, 3 s, loops: sitting (Kenney's sit) leaning back, head tipped, slow breathing."""
    breath = 0.5 - 0.5 * math.cos(2 * math.pi * t / 3.0)
    return person(
        root_loc=SIT_ROOT,
        torso=(-14 + 2 * breath, 0, 0),
        head=(7 - 1 * breath, 0, 8),
        arm_left=(-58 + 3 * breath, 22),
        arm_right=(-58 + 3 * breath, 22),
        leg_left=SIT_LEGS,
        leg_right=SIT_LEGS,
    )


PERSON_CLIPS = [
    ("startled", 0.6, person_startled),
    ("look-around", 2.5, person_look_around),
    ("sleep", 3.0, person_sleep),
    ("phone-call", 3.0, person_phone_call),
    ("sit-watch", 3.0, person_sit_watch),
]


# ---------------------------------------------------------------- dog

def drot(x=0.0, y=0.0, z=0.0):
    """Node rotation from Euler degrees: +x tips the front (nose) down and swings a leg back,
    +y rolls the top toward the dog's left, +z turns the nose to the dog's left."""
    return Euler((math.radians(x), math.radians(y), math.radians(z))).to_quaternion()


class Dog:
    """Rest places of the dog's nodes, read from the model, and a pose builder."""

    def __init__(self, objects):
        self.rest = {n: objects[n].location.copy() for n in DOG_PARTS}

    def pose(self, body=(0, 0, 0), body_rot=(0, 0, 0), body_scale=(1, 1, 1), legs=None):
        """body offset from rest, rotation and scale; legs: {name: (offset, rotation)}."""
        p = {
            "root": (self.rest["root"], drot(), (1, 1, 1)),
            "body": (self.rest["body"] + Vector(body), drot(*body_rot), body_scale),
        }
        for leg in DOG_PARTS[2:]:
            off, r = (legs or {}).get(leg, ((0, 0, 0), (0, 0, 0)))
            p[leg] = (self.rest[leg] + Vector(off), drot(*r), (1, 1, 1))
        return p


def dog_sleep_pose(dog, breath=0.0):
    """Lying on the floor: front paws tucked forward under the chin, back legs folded away,
    body slightly turned and nose down. breath 0..1 swells the body a little."""
    s = 1 + 0.035 * breath
    tuck = ((0, -0.13, -0.11), (-90, 0, 0))
    fold = ((0, 0.05, 0.02), (90, 0, 0))
    return dog.pose(
        body=(0, 0, -0.16 + 0.012 * breath),
        body_rot=(7 - 2 * breath, 4, 12),
        body_scale=(s, s, 1 + 0.05 * breath),
        legs={
            "leg-front-left": tuck,
            "leg-front-right": tuck,
            "leg-back-left": fold,
            "leg-back-right": fold,
        },
    )


def dog_sleep(dog):
    """sleep, 3 s, loops: curled up on the floor, one slow breath."""
    return lambda t: dog_sleep_pose(dog, 0.5 - 0.5 * math.cos(2 * math.pi * t / 3.0))


def dog_bark(dog):
    """bark, 0.5 s, once: a squat, then the front pops up and the body jerks forward."""
    def pose(t):
        crouch = keyed(t, [(0, 0), (0.07, 1), (0.12, 0, ease_out), (0.5, 0)])
        pop = keyed(t, [(0, 0), (0.07, 0), (0.13, 1, ease_out), (0.22, 0.75), (0.34, -0.12), (0.5, 0)])
        squash = 1 - 0.06 * crouch + 0.06 * pop
        wide = 1 + 0.04 * crouch - 0.03 * pop
        front = -25 * max(pop, 0)
        return dog.pose(
            body=(0, 0.03 * crouch - 0.09 * pop, -0.02 * crouch + 0.06 * max(pop, 0)),
            body_rot=(6 * crouch - 16 * pop, 0, 0),
            body_scale=(wide, wide, squash),
            legs={
                "leg-front-left": ((0, -0.05 * max(pop, 0), 0.05 * max(pop, 0)), (front, 0, 0)),
                "leg-front-right": ((0, -0.05 * max(pop, 0), 0.05 * max(pop, 0)), (front, 0, 0)),
                "leg-back-left": ((0, 0, 0), (-8 * max(pop, 0), 0, 0)),
                "leg-back-right": ((0, 0, 0), (-8 * max(pop, 0), 0, 0)),
            },
        )
    return pose


def dog_sniff(dog):
    """sniff, 1.2 s, loops: nose to the floor, quick little bobs, sweeping left and right."""
    def pose(t):
        bob = 0.5 - 0.5 * math.cos(2 * math.pi * t / 0.24)
        sweep = wave(t, 1.2)
        return dog.pose(
            body=(0.03 * sweep, -0.04, -0.05 + 0.015 * bob),
            body_rot=(18 - 3 * bob, 0, 9 * sweep),
            legs={
                "leg-back-left": ((0, 0, 0), (6, 0, 0)),
                "leg-back-right": ((0, 0, 0), (6, 0, 0)),
            },
        )
    return pose


def dog_wake(dog):
    """wake, 0.8 s, once: from the sleep pose, front up, back up, a quick shake, standing."""
    sleeping = dog_sleep_pose(dog)
    standing = dog.pose()

    def pose(t):
        front = keyed(t, [(0, 0), (0.28, 1)])
        back = keyed(t, [(0.12, 0), (0.42, 1)])
        p = {}
        for name in DOG_PARTS:
            loc0, rot0, sc0 = sleeping[name]
            loc1, rot1, sc1 = standing[name]
            u = front if "front" in name else back if "back" in name else (front + back) / 2
            p[name] = (loc0.lerp(loc1, u), rot0.slerp(rot1, u), mix(tuple(sc0), tuple(sc1), u))
        # the body noses up as the front rises, then shakes itself awake
        lift = bump(t, 0.24, 0.36)
        shake = keyed(t, [(0.4, (0, 0, 0)), (0.5, (0, 9, 0)), (0.6, (0, -7, 0)), (0.7, (0, 4, 0)), (0.8, (0, 0, 0))])
        loc, r, sc = p["body"]
        p["body"] = (loc + Vector((0, 0, 0.04 * lift)), r @ drot(-10 * lift, 0, 0) @ drot(*shake), sc)
        return p
    return pose


def bake_dog(objects, name, length, pose):
    _, bags = new_action(name, [objects[n] for n in DOG_PARTS])
    times = sample_times(length)
    poses = [pose(t) for t in times]
    for part in DOG_PARTS:
        bag = bags[part]
        write_curves(bag, "location", "Object Transforms", [(t, tuple(p[part][0])) for t, p in zip(times, poses)])
        quats = continuous([p[part][1] for p in poses])
        write_curves(bag, "rotation_quaternion", "Object Transforms", [(t, tuple(q)) for t, q in zip(times, quats)])
        write_curves(bag, "scale", "Object Transforms", [(t, tuple(p[part][2])) for t, p in zip(times, poses)])


DOG_CLIPS = [
    ("sleep", 3.0, dog_sleep),
    ("bark", 0.5, dog_bark),
    ("sniff", 1.2, dog_sniff),
    ("wake", 0.8, dog_wake),
]


# ---------------------------------------------------------------- export

def export(path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=path, export_format="GLB", export_yup=True,
        export_cameras=False, export_lights=False, export_extras=False,
        export_animations=True, export_animation_mode="ACTIONS",
        export_force_sampling=False,             # keep the linear keys exactly as written
        export_optimize_animation_size=False,    # keep every keyed channel, like Kenney's files
        export_anim_slide_to_zero=False,
    )


def build_people(src_dir, out_dir):
    import_glb(os.path.join(src_dir, "character-male-a.glb"))
    rig = bpy.data.objects["character-male-a"]
    for name, length, pose in PERSON_CLIPS:
        bake_person(rig, name, length, pose)
    export(os.path.join(out_dir, "mini-character-clips.glb"))


def build_dog(src_dir, out_dir):
    import_glb(os.path.join(src_dir, "animal-dog.glb"))
    objects = {n: bpy.data.objects[n] for n in DOG_PARTS}
    dog = Dog(objects)
    for name, length, make in DOG_CLIPS:
        bake_dog(objects, name, length, make(dog))
    export(os.path.join(out_dir, "animal-dog-clips.glb"))


def main():
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
    if len(args) != 3:
        sys.exit(__doc__.split("\n\n")[1])
    people_dir, pets_dir, out_dir = args
    build_people(people_dir, out_dir)
    build_dog(pets_dir, out_dir)


if __name__ == "__main__":
    main()
