"""Builds Tiptoe's scripted low-poly props and exports each one as a GLB.

Run from the repository root with a Python that has the `bpy` module:

    <python with bpy> tools/blender/props.py assets/models/props [prop ...]

Naming props (e.g. `safe gloves`) rebuilds only those.

Every prop is modelled in Godot's axes (x right, y up, z toward the viewer)
and converted to Blender's Z-up axes only when a mesh is made, so the numbers
below are the ones you see in Godot. The glTF exporter turns Blender's Z-up
back into Y-up.

Conventions:
  - wall props: back on z = 0, front facing +Z, centred on x, bottom on y = 0
  - floor props: standing on y = 0, centred on x and z
  - flat shading, flat-colour materials (roughness 1, no metal), no textures,
    in the same spirit as Kenney's kits
  - moving parts are their own nodes, with the origin on their pivot
"""

import math
import os
import sys

import bpy
from mathutils import Matrix, Vector

# Flat colours (linear, as glTF stores them). Several are Kenney's own
# Furniture Kit values so the props sit well next to that kit.
COLOURS = {
    "metal_light": (0.937, 0.980, 0.957),   # Kenney metalLight: off-white paint
    "metal_grey": (0.470, 0.520, 0.540),    # painted grey steel
    "metal_dark": (0.306, 0.388, 0.388),    # Kenney metalDark: safe green-grey
    "dark": (0.035, 0.040, 0.045),          # lens barrels, duct, holes
    "glass": (0.120, 0.200, 0.300),         # camera lens
    "red_led": (1.000, 0.050, 0.030),       # glows (emissive)
    "red": (0.943, 0.367, 0.343),           # Kenney carpet red
    "yellow": (1.000, 0.780, 0.150),        # warning label
    "brass": (0.860, 0.600, 0.220),
    "fabric_dark": (0.050, 0.053, 0.062),   # charcoal glove
    "fabric_light": (0.400, 0.420, 0.460),  # glove cuff
}
EMISSIVE = {"red_led": 3.0}


# --- mesh building -----------------------------------------------------------

def rot_x(deg):
    return Matrix.Rotation(math.radians(deg), 4, "X")


def rot_y(deg):
    return Matrix.Rotation(math.radians(deg), 4, "Y")


def rot_z(deg):
    return Matrix.Rotation(math.radians(deg), 4, "Z")


def move(x, y, z):
    return Matrix.Translation((x, y, z))


class Part:
    """A mesh under construction, in Godot axes, relative to its node origin."""

    def __init__(self):
        self.faces = []  # (points, material)

    def face(self, pts, mat, out=None):
        """Adds a polygon; `out` is any vector on the side it should face."""
        pts = [Vector(p) for p in pts]
        if out is not None:
            n = Vector((0, 0, 0))
            for i, a in enumerate(pts):  # Newell's normal
                b = pts[(i + 1) % len(pts)]
                n += Vector(((a.y - b.y) * (a.z + b.z), (a.z - b.z) * (a.x + b.x), (a.x - b.x) * (a.y + b.y)))
            if n.dot(Vector(out)) < 0:
                pts.reverse()
        self.faces.append((pts, mat))

    def mirrored_x(self):
        """A copy mirrored across x = 0 (winding flipped so it still faces out)."""
        p = Part()
        p.faces = [([Vector((-v.x, v.y, v.z)) for v in reversed(pts)], m) for pts, m in self.faces]
        return p


def centre(pts):
    return sum((Vector(p) for p in pts), Vector()) / len(pts)


def box(part, lo, hi, mat, m=Matrix(), skip=()):
    """Axis-aligned box from corner `lo` to `hi`, then moved by matrix `m`.
    `skip` lists faces to leave out: '-x', '+x', '-y', '+y', '-z', '+z'."""
    c = [m @ Vector((x, y, z)) for x in (lo[0], hi[0]) for y in (lo[1], hi[1]) for z in (lo[2], hi[2])]
    mid = centre(c)
    sides = {
        "-x": (0, 1, 3, 2), "+x": (4, 5, 7, 6), "-y": (0, 1, 5, 4),
        "+y": (2, 3, 7, 6), "-z": (0, 2, 6, 4), "+z": (1, 3, 7, 5),
    }
    for key, idx in sides.items():
        if key in skip:
            continue
        pts = [c[i] for i in idx]
        part.face(pts, mat, centre(pts) - mid)


def ring_pts(w, h, chamfer=0.3):
    """Eight points of a rectangle w x h with chamfered corners, in the xy plane."""
    c = chamfer * min(w, h)
    x, y = w / 2, h / 2
    return [(x, y - c), (x - c, y), (-x + c, y), (-x, y - c), (-x, -y + c), (-x + c, -y), (x - c, -y), (x, -y + c)]


def circle_pts(r, n, start=0.0):
    return [(r * math.cos(start + 2 * math.pi * i / n), r * math.sin(start + 2 * math.pi * i / n)) for i in range(n)]


def prism(part, outline, z0, z1, mat, m=Matrix(), cap_mat=None, caps=(True, True)):
    """Extrudes a convex 2D outline (xy) from z0 to z1, then moves it by `m`."""
    lo = [m @ Vector((x, y, z0)) for x, y in outline]
    hi = [m @ Vector((x, y, z1)) for x, y in outline]
    mid = centre(lo + hi)
    n = len(outline)
    for i in range(n):
        j = (i + 1) % n
        pts = [lo[i], lo[j], hi[j], hi[i]]
        part.face(pts, mat, centre(pts) - mid)
    if caps[0]:
        part.face(lo, cap_mat or mat, centre(lo) - mid)
    if caps[1]:
        part.face(hi, cap_mat or mat, centre(hi) - mid)


def cylinder(part, r, z0, z1, n, mat, m=Matrix(), cap_mat=None, start=None, caps=(True, True)):
    """Cylinder along z (radius r, from z0 to z1), then moved by `m`."""
    prism(part, circle_pts(r, n, math.pi / n if start is None else start), z0, z1, mat, m, cap_mat, caps)


def loft(part, rings, mat, caps=(True, True), cap_mats=(None, None)):
    """Skins a list of rings (same point count) into a tube, with end caps."""
    for a, b in zip(rings, rings[1:]):
        axis = centre(a + b)
        for i in range(len(a)):
            j = (i + 1) % len(a)
            pts = [a[i], a[j], b[j], b[i]]
            part.face(pts, mat, centre(pts) - axis)
    if caps[0]:
        part.face(rings[0], cap_mats[0] or mat, centre(rings[0]) - centre(rings[1]))
    if caps[1]:
        part.face(rings[-1], cap_mats[1] or mat, centre(rings[-1]) - centre(rings[-2]))


def open_box(part, lo, hi, wall, back, mat_out, mat_in):
    """A box open toward +Z: outside skin, front rim and a cavity `wall` thick
    on the sides and `back` thick at the back. The cavity faces point inward."""
    box(part, lo, hi, mat_out, skip=("+z",))
    ilo = (lo[0] + wall, lo[1] + wall, lo[2] + back)
    ihi = (hi[0] - wall, hi[1] - wall, hi[2])
    z = hi[2]
    outer = [(lo[0], lo[1], z), (hi[0], lo[1], z), (hi[0], hi[1], z), (lo[0], hi[1], z)]
    inner = [(ilo[0], ilo[1], z), (ihi[0], ilo[1], z), (ihi[0], ihi[1], z), (ilo[0], ihi[1], z)]
    for i in range(4):  # front rim
        j = (i + 1) % 4
        part.face([outer[i], outer[j], inner[j], inner[i]], mat_out, (0, 0, 1))
    cavity(part, ilo, ihi, mat_in)


def cavity(part, lo, hi, mat):
    """Inside walls and back of a box open toward +Z, facing inward."""
    mid = Vector(((lo[0] + hi[0]) / 2, (lo[1] + hi[1]) / 2, (lo[2] + hi[2]) / 2))
    box_pts = [Vector((x, y, z)) for x in (lo[0], hi[0]) for y in (lo[1], hi[1]) for z in (lo[2], hi[2])]
    for idx in ((0, 1, 3, 2), (4, 5, 7, 6), (0, 1, 5, 4), (2, 3, 7, 6), (0, 2, 6, 4)):
        pts = [box_pts[i] for i in idx]
        part.face(pts, mat, mid - centre(pts))


# --- Blender scene -----------------------------------------------------------

def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def material(name):
    mat = bpy.data.materials.get(name)
    if mat:
        return mat
    mat = bpy.data.materials.new(name)
    rgb = COLOURS[name]
    mat.diffuse_color = (*rgb, 1.0)
    mat.roughness = 1.0
    mat.metallic = 0.0
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*rgb, 1.0)
    bsdf.inputs["Roughness"].default_value = 1.0
    bsdf.inputs["Metallic"].default_value = 0.0
    if name in EMISSIVE:
        bsdf.inputs["Emission Color"].default_value = (*rgb, 1.0)
        bsdf.inputs["Emission Strength"].default_value = EMISSIVE[name]
    return mat


def to_blender(v):
    """Godot axes (y up, z toward viewer) to Blender axes (z up, -y toward viewer)."""
    return (v[0], -v[2], v[1])


def node(name, part, at=(0, 0, 0), parent=None):
    """Makes an object from `part` with its origin `at` (relative to `parent`)."""
    verts, faces, mats, index = [], [], [], {}
    names = sorted({m for _, m in part.faces})
    for pts, m in part.faces:
        f = []
        for p in pts:
            key = tuple(round(c, 6) for c in p)
            if key not in index:
                index[key] = len(verts)
                verts.append(to_blender(p))
            f.append(index[key])
        faces.append(f)
        mats.append(names.index(m))
    # Two touching parts leave a pair of faces on the same corners, inside
    # the mesh where nobody sees them: drop both.
    seen = {}
    for i, f in enumerate(faces):
        seen.setdefault(frozenset(f), []).append(i)
    hidden = {i for group in seen.values() if len(group) > 1 for i in group}
    faces = [f for i, f in enumerate(faces) if i not in hidden]
    mats = [m for i, m in enumerate(mats) if i not in hidden]
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    for m in names:
        mesh.materials.append(material(m))
    for poly, mi in zip(mesh.polygons, mats):
        poly.material_index = mi
        poly.use_smooth = False
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.scene.collection.objects.link(obj)
    obj.location = to_blender(at)
    if parent:
        obj.parent = parent
    return obj


def export(path):
    bpy.ops.export_scene.gltf(
        filepath=path, export_format="GLB", export_yup=True, export_apply=False,
        export_materials="EXPORT", export_animations=False, export_cameras=False,
        export_lights=False, export_extras=False,
    )


# --- props -------------------------------------------------------------------

def security_camera():
    """Wall CCTV camera. `head` pans about Y on the top of the bracket arm."""
    mount = Part()
    box(mount, (-0.045, 0.0, 0.0), (0.045, 0.13, 0.014), "metal_grey")       # wall plate
    for y in (0.022, 0.108):                                                   # screws
        cylinder(mount, 0.007, 0.014, 0.018, 6, "dark", move(0, y, 0))
    box(mount, (-0.018, 0.047, 0.014), (0.018, 0.083, 0.15), "metal_grey")    # arm
    cylinder(mount, 0.026, 0.0, 0.03, 10, "metal_grey", move(0, 0.06, 0.135) @ rot_x(-90))  # knuckle

    pivot = (0.0, 0.09, 0.135)
    head = Part()
    cylinder(head, 0.014, 0.0, 0.03, 8, "metal_grey", rot_x(-90))             # neck
    # The body leans forward and down a little, looking out from the wall.
    tilt = move(0, 0.068, 0.0) @ rot_x(14)
    box(head, (-0.05, -0.042, -0.06), (0.05, 0.042, 0.15), "metal_light", tilt)     # body
    box(head, (-0.06, 0.042, -0.07), (0.06, 0.054, 0.20), "metal_light", tilt)      # sun hood
    for x in (-0.06, 0.05):                                                          # hood sides
        box(head, (x, 0.0, 0.11), (x + 0.010, 0.042, 0.20), "metal_light", tilt)
    box(head, (-0.05, -0.042, 0.15), (0.05, 0.042, 0.158), "metal_grey", tilt)      # front face plate
    cylinder(head, 0.034, 0.158, 0.18, 10, "dark", tilt @ move(0, -0.006, 0))       # lens barrel
    cylinder(head, 0.024, 0.18, 0.183, 10, "glass", tilt @ move(0, -0.006, 0))      # lens glass
    box(head, (0.030, 0.022, 0.158), (0.043, 0.035, 0.168), "red_led", tilt)        # LED
    box(head, (-0.024, -0.024, -0.076), (0.024, 0.024, -0.06), "metal_grey", tilt)  # back cap

    node("mount", mount)
    node("head", head, pivot)


def safe():
    """Floor safe. The door hinges on its right edge (+X) and opens with a
    positive Y rotation; `dial` turns about the door's normal (local Z)."""
    body = Part()
    for x in (-0.25, 0.25):                                                    # feet
        for z in (-0.25, 0.19):
            box(body, (x - 0.04, 0.0, z - 0.04), (x + 0.04, 0.04, z + 0.04), "dark")
    open_box(body, (-0.3, 0.04, -0.3), (0.3, 0.70, 0.24), 0.07, 0.07, "metal_dark", "dark")
    box(body, (-0.23, 0.355, -0.23), (0.23, 0.375, 0.20), "metal_grey")       # shelf
    for y in (0.17, 0.57):                                                     # hinge barrels
        cylinder(body, 0.014, 0.0, 0.08, 8, "metal_grey", move(0.268, y - 0.04, 0.255) @ rot_x(-90))

    hinge = (0.26, 0.37, 0.24)  # door's back edge on the hinge side; door spans x -0.52..0
    door = Part()
    box(door, (-0.52, -0.29, 0.0), (0.0, 0.29, 0.06), "metal_dark")            # slab
    box(door, (-0.47, -0.24, 0.06), (-0.05, 0.24, 0.07), "metal_dark")         # raised panel
    # A fixed red mark above the dial, pointing down at it.
    prism(door, [(-0.012, 0.0), (0.012, 0.0), (0.0, -0.018)], 0.07, 0.074, "red", move(-0.26, 0.19, 0))

    dial = Part()
    cylinder(dial, 0.07, 0.0, 0.015, 16, "metal_light")
    cylinder(dial, 0.036, 0.015, 0.045, 10, "dark")
    box(dial, (-0.005, 0.044, 0.015), (0.005, 0.066, 0.018), "red")           # index notch

    handle = Part()
    cylinder(handle, 0.026, 0.0, 0.036, 10, "brass")                         # hub
    for a in (90, 210, 330):                                                  # three spokes
        spin = rot_z(a)
        cylinder(handle, 0.008, 0.0, 0.075, 6, "brass", spin @ move(0, 0, 0.026) @ rot_y(90))
        cylinder(handle, 0.016, 0.01, 0.04, 8, "brass", spin @ move(0.08, 0, 0))

    node("body", body)
    d = node("door", door, hinge)
    node("dial", dial, (-0.26, 0.09, 0.07), d)
    node("handle", handle, (-0.26, -0.13, 0.07), d)


def wall_vent():
    """Wall air vent: `frame`, a lift-off grille (`cover`, origin in the middle
    of the opening) and `duct`, a dark liner 0.5 m deep behind the wall face.
    The duct's faces point inward, and the wall needs a hole behind the
    opening for it to show."""
    w, h, inner_w, inner_h, depth = 0.6, 0.4, 0.5, 0.3, 0.025
    frame = Part()
    ox, oy, ix = w / 2, h, inner_w / 2
    iy0, iy1 = (h - inner_h) / 2, (h + inner_h) / 2
    outer = [(-ox, 0, depth), (ox, 0, depth), (ox, oy, depth), (-ox, oy, depth)]
    inner = [(-ix, iy0, depth), (ix, iy0, depth), (ix, iy1, depth), (-ix, iy1, depth)]
    for i in range(4):
        j = (i + 1) % 4
        frame.face([outer[i], outer[j], inner[j], inner[i]], "metal_light", (0, 0, 1))      # face
        frame.face([outer[i], outer[j], (outer[j][0], outer[j][1], 0), (outer[i][0], outer[i][1], 0)],
                   "metal_light", centre([outer[i], outer[j]]) - Vector((0, h / 2, depth)))  # outer edge
        frame.face([inner[i], inner[j], (inner[j][0], inner[j][1], 0), (inner[i][0], inner[i][1], 0)],
                   "metal_light", Vector((0, h / 2, 0)) - centre([inner[i], inner[j]]))     # inner edge
    duct = Part()
    cavity(duct, (-ix, iy0, -0.5), (ix, iy1, 0.0), "dark")

    cover = Part()  # origin at the middle of the opening, on the wall
    cw, ch = inner_w / 2 - 0.004, inner_h / 2 - 0.004
    rim = 0.025
    for lo, hi in (((-cw, -ch, 0), (cw, -ch + rim, 0.03)), ((-cw, ch - rim, 0), (cw, ch, 0.03)),
                   ((-cw, -ch + rim, 0), (-cw + rim, ch - rim, 0.03)), ((cw - rim, -ch + rim, 0), (cw, ch - rim, 0.03))):
        box(cover, lo, hi, "metal_light")
    slats = 6
    step = (2 * (ch - rim)) / slats
    for i in range(slats):  # louvres tilted so you look down onto them
        y = -ch + rim + step * (i + 0.5)
        box(cover, (-cw + rim, -0.019, -0.003), (cw - rim, 0.019, 0.003), "metal_light",
            move(0, y, 0.016) @ rot_x(-45))
    for x in (-cw + rim / 2, cw - rim / 2):  # screws
        for y in (-ch + rim / 2, ch - rim / 2):
            cylinder(cover, 0.006, 0.03, 0.034, 6, "metal_grey", move(x, y, 0))

    node("frame", frame)
    node("duct", duct)
    node("cover", cover, (0, h / 2, 0))


def fuse_box():
    """Grey fuse box. The door hinges on its right edge (+X) and opens with a
    positive Y rotation. `breaker` rotates about X: 0 is up (on), about
    +70 degrees is down (off)."""
    bx = Part()
    open_box(bx, (-0.2, 0.0, 0.0), (0.2, 0.5, 0.13), 0.02, 0.015, "metal_grey", "metal_dark")
    box(bx, (-0.08, 0.28, 0.015), (0.08, 0.45, 0.05), "metal_light")         # main switch housing
    box(bx, (-0.04, 0.32, 0.05), (0.04, 0.41, 0.053), "dark")                 # lever slot
    box(bx, (-0.165, 0.12, 0.015), (0.165, 0.23, 0.05), "metal_light")       # fuse rail
    for i in range(8):                                                       # fuse switches
        x = -0.126 + i * 0.036
        up = i not in (2, 6)
        y0 = 0.175 if up else 0.150
        box(bx, (x - 0.011, y0, 0.05), (x + 0.011, y0 + 0.028, 0.07), "dark")
    box(bx, (-0.165, 0.06, 0.015), (0.165, 0.09, 0.03), "yellow")            # label strip
    for y in (0.08, 0.42):                                                   # hinge barrels
        cylinder(bx, 0.01, 0.0, 0.05, 8, "metal_grey", move(0.2, y - 0.025, 0.135) @ rot_x(-90))

    breaker = Part()  # origin on its pivot; the lever points up and out
    cylinder(breaker, 0.014, -0.034, 0.034, 8, "dark", rot_y(90))           # pivot barrel
    lean = rot_x(-35)
    box(breaker, (-0.012, -0.008, 0.0), (0.012, 0.008, 0.068), "dark", lean)  # arm
    box(breaker, (-0.042, -0.014, 0.056), (0.042, 0.014, 0.085), "red", lean) # grip

    door = Part()  # origin on the hinge (back edge, right side)
    box(door, (-0.4, -0.25, 0.0), (0.0, 0.25, 0.02), "metal_grey")
    box(door, (-0.385, -0.04, 0.02), (-0.365, 0.04, 0.035), "metal_light")   # latch
    tri = [(-0.07, -0.045), (0.07, -0.045), (0.0, 0.075)]
    prism(door, tri, 0.02, 0.023, "yellow", move(-0.2, 0.06, 0))             # warning sign
    bolt = [(0.008, 0.045), (-0.016, 0.0), (0.0, 0.0), (-0.01, -0.035), (0.016, 0.01), (0.0, 0.01)]
    # The bolt is concave, so build it from two convex halves.
    prism(door, [bolt[0], bolt[1], bolt[2], bolt[5]], 0.023, 0.025, "dark", move(-0.2, 0.06, 0))
    prism(door, [bolt[2], bolt[3], bolt[4], bolt[5]], 0.023, 0.025, "dark", move(-0.2, 0.06, 0))

    b = node("box", bx)
    node("breaker", breaker, (0.0, 0.365, 0.05), b)
    node("door", door, (0.2, 0.25, 0.13))


def doorbell():
    """Front-door bell. `button` sits proud and pushes in along -Z (about 6 mm)."""
    plate = Part()
    c = 0.01  # chamfered corners
    outline = [(0.035 - c, 0.0), (0.035, c), (0.035, 0.11 - c), (0.035 - c, 0.11),
               (-0.035 + c, 0.11), (-0.035, 0.11 - c), (-0.035, c), (-0.035 + c, 0.0)]
    prism(plate, outline, 0.0, 0.012, "brass")
    box(plate, (-0.022, 0.082, 0.012), (0.022, 0.098, 0.015), "metal_light")  # name card
    cylinder(plate, 0.022, 0.012, 0.018, 12, "dark", move(0, 0.045, 0))       # bezel

    button = Part()
    cylinder(button, 0.016, -0.006, 0.006, 12, "metal_light", caps=(False, False))
    loft(button, [[Vector((x, y, 0.006)) for x, y in circle_pts(0.016, 12, math.pi / 12)],
                  [Vector((x, y, 0.010)) for x, y in circle_pts(0.012, 12, math.pi / 12)]],
         "metal_light", caps=(False, True))

    node("plate", plate)
    node("button", button, (0, 0.045, 0.018))


def finger(part, base, fwd, up, lengths, bends, w, h, mat):
    """A tube through finger joints. `bends` curls each joint toward the palm."""
    fwd, up = Vector(fwd).normalized(), Vector(up)
    up = (up - fwd * up.dot(fwd)).normalized()
    joints, frames = [Vector(base)], []
    f, u = fwd, up
    for length, bend in zip(lengths, bends):
        r = Matrix.Rotation(math.radians(-bend), 3, f.cross(u))
        f, u = r @ f, r @ u
        frames.append((f, u))
        joints.append(joints[-1] + f * length)
    rings = []
    count = len(joints)
    for i, p in enumerate(joints):
        if i == 0:
            f, u = frames[0]
        elif i == count - 1:
            f, u = frames[-1]
        else:  # joints face halfway between the two segments
            f = (frames[i - 1][0] + frames[i][0]).normalized()
            u = (frames[i - 1][1] + frames[i][1]).normalized()
        s = 1.0 - 0.12 * i / (count - 1)  # taper toward the tip
        if i == count - 1:
            p = p - f * (w * 0.3)
        rings.append(ring_at(p, f, u, w * s, h * s))
    f, u = frames[-1]
    tip = joints[-1] + f * (w * 0.12)
    rings.append(ring_at(tip, f, u, w * 0.55, h * 0.5))
    loft(part, rings, mat)


def ring_at(p, f, u, w, h):
    side = f.cross(u).normalized()
    return [p + side * x + u * y for x, y in ring_pts(w, h)]


def glove():
    """Right glove, palm down, fingers toward -Z, origin at the wrist."""
    g = Part()
    fab, cuff = "fabric_dark", "fabric_light"
    # Back of the hand and palm, from the wrist to the knuckles.
    sections = [(0.0, 0.0, 0.062, 0.036), (-0.035, 0.0, 0.082, 0.038),
                (-0.070, -0.002, 0.090, 0.035), (-0.088, -0.006, 0.086, 0.028)]
    rings = [[Vector((x, y + oy, z)) for x, y in ring_pts(w, hh)] for z, oy, w, hh in sections]
    loft(g, rings, fab)
    # Fingers: x at the knuckle, lengths (incl. the part inside the palm),
    # curl per joint, width, height and spread.
    fingers = [
        (-0.0315, (0.054, 0.027, 0.021), (10, 22, 16), 0.024, 0.021, -2),
        (-0.0105, (0.058, 0.030, 0.023), (12, 25, 18), 0.024, 0.022, 0),
        (0.0105, (0.055, 0.028, 0.021), (15, 28, 20), 0.023, 0.021, 2),
        (0.030, (0.045, 0.023, 0.019), (19, 32, 22), 0.021, 0.019, 5),
    ]
    for x, lengths, bends, w, h, spread in fingers:
        fwd = rot_y(-spread).to_3x3() @ Vector((0, 0, -1))
        finger(g, (x, -0.004, -0.07), fwd, (0, 1, 0), lengths, bends, w, h, fab)
    # Thumb: out to the side and forward, curling in under the fingers.
    finger(g, (-0.026, -0.008, -0.02), (-0.55, -0.22, -0.80), (-0.55, 0.83, 0.0),
           (0.044, 0.030, 0.025), (6, 14, 18), 0.028, 0.025, fab)
    # Cuff: a short lighter band over the wrist, open at the back, dark inside.
    cuff_rings = [[Vector((x, y, z)) for x, y in ring_pts(w, hh, 0.35)]
                  for z, w, hh in ((-0.010, 0.070, 0.046), (0.035, 0.078, 0.054))]
    hole = [[Vector((x, y, z)) for x, y in ring_pts(w, hh, 0.35)] for z, w, hh in ((0.035, 0.060, 0.038), (0.022, 0.060, 0.038))]
    loft(g, cuff_rings, cuff, caps=(True, False))
    for i in range(8):  # back rim of the cuff
        j = (i + 1) % 8
        g.face([cuff_rings[1][i], cuff_rings[1][j], hole[0][j], hole[0][i]], cuff, (0, 0, 1))
    for i in range(8):  # inside of the cuff
        j = (i + 1) % 8
        pts = [hole[0][i], hole[0][j], hole[1][j], hole[1][i]]
        g.face(pts, "fabric_dark", Vector((0, 0, centre(pts).z)) - centre(pts))
    g.face(hole[1], "fabric_dark", (0, 0, 1))
    return g


def gloves():
    """First-person gloves. Each origin is at the wrist; fingers point to -Z
    (Godot's forward), backs of the hands up (+Y)."""
    right = glove()
    left = right.mirrored_x()
    node("glove_left", left, (-0.12, 0, 0))
    node("glove_right", right, (0.12, 0, 0))


PROPS = {
    "security_camera": security_camera,
    "safe": safe,
    "wall_vent": wall_vent,
    "fuse_box": fuse_box,
    "doorbell": doorbell,
    "gloves": gloves,
}


def main():
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
    out_dir = args[0] if args else "assets/models/props"
    only = set(args[1:])
    os.makedirs(out_dir, exist_ok=True)
    for name, build in PROPS.items():
        if only and name not in only:
            continue
        reset_scene()
        build()
        export(os.path.join(out_dir, name + ".glb"))
        tris = {o.name: sum(len(p.vertices) - 2 for p in o.data.polygons) for o in bpy.data.objects}
        counts = ", ".join(f"{k} {n}" for k, n in tris.items())
        print(f"{name}.glb: {sum(tris.values())} tris ({counts})")


if __name__ == "__main__":
    main()
