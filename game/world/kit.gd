class_name Kit
extends RefCounted
## Helpers for building levels out of Kenney pieces in code: placing models,
## giving them collision, footstep surfaces and the groups the stealth systems
## look for. Levels call these instead of hand-placing scenes, so a house is a
## readable list of walls, doors and furniture.

const BUILDING := "res://assets/kenney/building-kit/"
const FURNITURE := "res://assets/kenney/furniture-kit/"
const SUBURBAN := "res://assets/kenney/city-suburban/"
const FOOD := "res://assets/kenney/food-kit/"
const PROTOTYPE := "res://assets/kenney/prototype-kit/"
const PROPS := "res://assets/models/props/"

## Collision layers.
const LAYER_WORLD := 1
const LAYER_INTERACT := 2
const LAYER_PEOPLE := 4
## Window glass: stops bodies, but not sight, light or sound.
const LAYER_GLASS := 8
## Doors: block the player, sight, light and sound, but people walk through
## an open door's leaf rather than getting stuck on it.
const LAYER_DOOR := 16
## What blocks sight, light and sound.
const LAYER_SOLID := LAYER_WORLD | LAYER_DOOR

## The Furniture Kit is modelled at half scale.
const FURNITURE_SCALE := 2.0

const FOOTSTEPS := "res://game/stealth/footsteps/footsteps_%s.tres"

## Nodes whose collision the people's navigation mesh is baked from.
const NAV_GROUP := "navmesh_source"

static var _scenes := {}
static var _shapes := {}
static var _materials := {}


static func scene(path: String) -> PackedScene:
	if not _scenes.has(path):
		_scenes[path] = load(path)
	return _scenes[path]


## Places a model with no collision.
static func model(parent: Node, path: String, pos: Vector3, yaw := 0.0, scale := 1.0) -> Node3D:
	var n: Node3D = scene(path).instantiate()
	n.position = pos
	n.rotation.y = deg_to_rad(yaw)
	n.scale = Vector3.ONE * scale
	parent.add_child(n)
	return n


## Places a model that people and the player bump into, with collision made
## from its own triangles (for walls with holes in them).
static func solid(parent: Node, path: String, pos: Vector3, yaw := 0.0, scale := Vector3.ONE, surface := "") -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation.y = deg_to_rad(yaw)
	body.collision_layer = LAYER_WORLD
	body.collision_mask = 0
	parent.add_child(body)
	var n: Node3D = scene(path).instantiate()
	n.scale = scale
	body.add_child(n)
	for mi in n.find_children("", "MeshInstance3D", true, false):
		if String(mi.name).begins_with("(_ignore)"):
			continue
		var cs := CollisionShape3D.new()
		cs.shape = _trimesh(mi.mesh, _relative(mi, body))
		body.add_child(cs)
	if surface != "":
		add_surface(body, surface)
	body.add_to_group(NAV_GROUP)
	return body


## Places a model that blocks with a box around it: furniture, fences, props.
## `pos` is the middle of its footprint, on the floor. Returns the body; the
## model is its first child.
static func boxed(parent: Node, path: String, pos: Vector3, yaw := 0.0, scale := 1.0, surface := "", nav := true) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation.y = deg_to_rad(yaw)
	body.collision_layer = LAYER_WORLD
	body.collision_mask = 0
	parent.add_child(body)
	var n: Node3D = scene(path).instantiate()
	n.scale = Vector3.ONE * scale
	body.add_child(n)
	var box := aabb_of(n)
	# Centre the model on the body, so `pos` is the middle of its footprint.
	var c := box.get_center()
	n.position = Vector3(-c.x, 0, -c.z)
	box.position -= Vector3(c.x, 0, c.z)
	if box.size.length() > 0.0:
		var cs := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = box.size.max(Vector3(0.05, 0.05, 0.05))
		cs.shape = shape
		cs.position = box.get_center()
		body.add_child(cs)
	if surface != "":
		add_surface(body, surface)
	if nav:
		body.add_to_group(NAV_GROUP)
	return body


## A furniture piece, scaled up from the kit's half scale.
static func furniture(parent: Node, name: String, pos: Vector3, yaw := 0.0, solid_box := true) -> Node3D:
	if solid_box:
		return boxed(parent, FURNITURE + name + ".glb", pos, yaw, FURNITURE_SCALE, "wood")
	return model(parent, FURNITURE + name + ".glb", pos, yaw, FURNITURE_SCALE)


## An invisible or plain box that blocks: floors, ramps, hedges, sills.
static func block(parent: Node, center: Vector3, size: Vector3, surface := "", material: Material = null, nav := true) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = center
	body.collision_layer = LAYER_WORLD
	body.collision_mask = 0
	parent.add_child(body)
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	body.add_child(cs)
	if material:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = size
		bm.material = material
		mi.mesh = bm
		body.add_child(mi)
	if surface != "":
		add_surface(body, surface)
	if nav:
		body.add_to_group(NAV_GROUP)
	return body


## Tells footsteps on this body what they sound like (and how far they carry).
static func add_surface(body: Node, surface: String) -> void:
	var fs := FootstepSurface.new()
	fs.name = "FootstepSurface"
	fs.footstep_profile = load(FOOTSTEPS % surface)
	body.add_child(fs)


## A flat coloured material, cached by colour.
static func flat(color: Color, roughness := 0.9) -> StandardMaterial3D:
	var key := "%s/%s" % [color.to_html(), roughness]
	if not _materials.has(key):
		var m := StandardMaterial3D.new()
		m.albedo_color = color
		m.roughness = roughness
		_materials[key] = m
	return _materials[key]


## The bounds of a node's meshes, in the node's parent's space.
static func aabb_of(n: Node3D) -> AABB:
	var acc := [null]
	_merge_aabb(n, n.transform, acc)
	return acc[0] if acc[0] != null else AABB()


static func _merge_aabb(n: Node, xf: Transform3D, acc: Array) -> void:
	if n is MeshInstance3D and n.mesh and not String(n.name).begins_with("(_ignore)"):
		var b: AABB = xf * n.mesh.get_aabb()
		acc[0] = b if acc[0] == null else acc[0].merge(b)
	for c in n.get_children():
		if c is Node3D:
			_merge_aabb(c, xf * c.transform, acc)


## `n`'s transform relative to `ancestor`, before either is in the tree.
static func _relative(n: Node3D, ancestor: Node3D) -> Transform3D:
	var t := Transform3D()
	var cur: Node = n
	while cur != null and cur != ancestor:
		if cur is Node3D:
			t = cur.transform * t
		cur = cur.get_parent()
	return t


## Collision from a mesh's triangles with `xf` (scale included) baked in, as
## physics engines handle scaled concave shapes badly.
static func _trimesh(mesh: Mesh, xf: Transform3D) -> Shape3D:
	var key := [mesh, xf]
	if not _shapes.has(key):
		var faces := mesh.get_faces()
		for i in faces.size():
			faces[i] = xf * faces[i]
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(faces)
		shape.backface_collision = true
		_shapes[key] = shape
	return _shapes[key]
