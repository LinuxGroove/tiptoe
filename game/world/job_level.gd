class_name JobLevel
extends Node3D
## Base for a job's level, built in code from kit pieces. A level lays out
## walls a line at a time (see [method line]), floors, lamps, doors and the
## things the player uses, and records what the rest of the job needs: start
## points, places people walk to, the house's openings and which parts of
## the world are indoors.

## A note was opened (the HUD shows it).
signal note_opened(title: String, text: String)
## The player crossed from outside into the house (opening id) or back out
## (opening kind: "door" or "window").
signal entered_house(by: String)
signal left_house(kind: String)
## The player walked into a named area (like "garage") for the first time.
signal entered_area(area: String)
## The player is at a way out (a start point).
signal at_way_out(id: String)
## The navigation mesh for people is ready.
signal navigation_ready

const STOREY := 2.5
## Kit walls are 2.4 m; storeys are 2.5 m, so walls stretch a little.
const WALL_SCALE := Vector3(1.0, STOREY / 2.4, 1.0)
const WINDOW_SILL := 0.7 * STOREY / 2.4
const WINDOW_TOP := 1.9 * STOREY / 2.4
const OPENING_HALF := 0.45

const PIECES := {
	"W": "wall.glb",
	"w": "wall-window-square.glb",
	"o": "wall-window-square.glb",
	"p": "wall-window-square.glb",
	"D": "wall-doorway-square.glb",
	"d": "wall-doorway-square.glb",
	"-": "wall-low.glb",
}

## Place name -> position, for people's routines.
var points := {}
## Start point id -> Transform3D for the player.
var starts := {}
var doors := {}
## {id, kind ("door" or "window"), pos}
var openings: Array = []
## Volumes of the house proper; entering one counts as getting in.
var house_boxes: Array[AABB] = []
## Other roofed volumes (a garage): dark indoors, but not "in the house".
var indoor_boxes: Array[AABB] = []
## Named areas the job wants to know the player reached: name -> AABB.
var areas := {}
## Ways out: id -> position. Getting back to one with the treasure escapes.
var way_outs := {}
const WAY_OUT_RADIUS := 2.5
## Room -> its lamps.
var lights := {}
var nav_region: NavigationRegion3D
var _player_inside := false
var _last_outside := Vector3.ZERO
var _areas_seen := {}
var _at_way_out := ""


## Builds the whole level. Levels override this.
func build() -> void:
	pass


func _physics_process(_delta: float) -> void:
	var p := get_tree().get_first_node_in_group("moth") as Node3D
	if p == null:
		return
	var at: Vector3 = p.global_position
	var inside := in_house(at)
	if inside and not _player_inside:
		var o := nearest_opening(_last_outside.lerp(at, 0.5))
		entered_house.emit(o.get("id", ""))
	elif not inside and _player_inside:
		var o := nearest_opening(at)
		left_house.emit(o.get("kind", "door"))
	if not inside:
		_last_outside = at
	_player_inside = inside
	for a in areas:
		if not _areas_seen.has(a) and areas[a].has_point(at):
			_areas_seen[a] = true
			entered_area.emit(a)
	var way := ""
	for w in way_outs:
		if at.distance_to(way_outs[w]) < WAY_OUT_RADIUS:
			way = w
	if way != _at_way_out:
		_at_way_out = way
		if way != "":
			at_way_out.emit(way)


## The way out the player is standing at, or "".
func way_out_here() -> String:
	return _at_way_out


func in_house(at: Vector3) -> bool:
	for b in house_boxes:
		if b.has_point(at):
			return true
	return false


func indoors(at: Vector3) -> bool:
	if in_house(at):
		return true
	for b in indoor_boxes:
		if b.has_point(at):
			return true
	return false


func nearest_opening(at: Vector3) -> Dictionary:
	var best := {}
	var best_d := INF
	for o in openings:
		var d: float = at.distance_to(o.pos)
		if d < best_d:
			best_d = d
			best = o
	return best


## A start point, which is also a way out. `yaw` 0 faces north (-Z).
func add_start(id: String, pos: Vector3, yaw := 0.0) -> void:
	starts[id] = Transform3D(Basis(Vector3.UP, deg_to_rad(yaw)), pos + Vector3(0, 0.9, 0))
	way_outs[id] = pos
	var mark := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.9
	cm.bottom_radius = 0.9
	cm.height = 0.02
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.95, 0.85, 0.4, 0.35)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cm.material = m
	mark.mesh = cm
	mark.position = pos + Vector3(0, 0.02, 0)
	add_child(mark)


func start_transform(id: String) -> Transform3D:
	if starts.has(id):
		return starts[id]
	return starts.values()[0] if not starts.is_empty() else Transform3D()


## Lays a line of wall pieces, one per 2 m, starting at `from` (x, z) and
## heading along `dir` (one of the four axes), on the storey whose floor is
## at `y0`. Each character of `codes` is one piece:
##   W wall, w window, o open window, p window that can be pried open,
##   D doorway with a door, d doorway without one, - low wall, . nothing.
## `specs` gives, in order, the id (for o and p) or the door spec (for D:
## {id, into: Vector2 a point in the room it swings into, locked, key, pick}).
func line(y0: float, from: Vector2, dir: Vector2, codes: String, specs := []) -> void:
	var u := Vector3(dir.x, 0, dir.y).normalized()
	var yaw := rad_to_deg(atan2(u.x, u.z))
	var next := 0
	for i in codes.length():
		var code := codes[i]
		var c := Vector3(from.x, y0, from.y) + u * (2.0 * i + 1.0)
		if code == "." or not PIECES.has(code):
			continue
		var body := Kit.solid(self, Kit.BUILDING + PIECES[code], c, yaw, WALL_SCALE)
		match code:
			"w":
				_glass(body)
			"o":
				_remove_glass(body)
				var id: String = specs[next]
				next += 1
				openings.append({"id": id, "kind": "window", "pos": c + Vector3(0, 1.2, 0)})
			"p":
				var id: String = specs[next]
				next += 1
				_remove_glass(body)
				_pry_window(id, c, yaw, body)
				openings.append({"id": id, "kind": "window", "pos": c + Vector3(0, 1.2, 0)})
			"D":
				var spec: Dictionary = specs[next]
				next += 1
				_door(spec, c, u, yaw)


## A floor (and the ceiling under it, unless it's the ground floor).
func floor_rect(y0: float, x0: float, z0: float, x1: float, z1: float, surface: String, color: Color, ceiling := true) -> void:
	var size := Vector3(absf(x1 - x0), 0.06, absf(z1 - z0))
	var center := Vector3((x0 + x1) * 0.5, y0 - 0.03, (z0 + z1) * 0.5)
	Kit.block(self, center, size, surface, Kit.flat(color))
	if ceiling:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(size.x, 0.04, size.z)
		bm.material = Kit.flat(Color(0.86, 0.84, 0.8))
		mi.mesh = bm
		mi.position = center + Vector3(0, -0.06, 0)
		add_child(mi)


## A ceiling lamp for a room, in the "stealth_lights" group.
func lamp(room: String, pos: Vector3, on := true, energy := 1.2, reach := 6.0, color := Color(1.0, 0.86, 0.66)) -> OmniLight3D:
	Kit.model(self, Kit.FURNITURE + "lampSquareCeiling.glb", pos + Vector3(0, -0.46, 0), 0.0, Kit.FURNITURE_SCALE)
	var l := OmniLight3D.new()
	l.position = pos + Vector3(0, -0.6, 0)
	l.light_color = color
	l.omni_range = reach
	l.omni_attenuation = 1.2
	l.shadow_enabled = true
	l.light_energy = energy
	l.visible = on
	l.set_meta("room", room)
	l.add_to_group("stealth_lights")
	add_child(l)
	if not lights.has(room):
		lights[room] = []
	lights[room].append(l)
	return l


## A light switch on a wall for the lamps of `rooms`. `normal` points out of
## the wall into the room.
func light_switch(rooms: Array, pos: Vector3, normal: Vector3, event := "") -> UsableBody:
	var s := UsableBody.new()
	s.name = "Switch_" + "_".join(rooms)
	s.position = pos
	s.rotation.y = atan2(normal.x, normal.z)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.09, 0.13, 0.03)
	bm.material = Kit.flat(Color(0.95, 0.94, 0.9))
	mi.mesh = bm
	s.add_child(mi)
	s.add_box(Vector3.ZERO, Vector3(0.14, 0.18, 0.06))
	s.add_action("interact", "Switch the light", _flip_switch.bind(rooms, event, s))
	add_child(s)
	return s


func lights_on(room: String) -> bool:
	for l in lights.get(room, []):
		if l.visible:
			return true
	return false


func set_lights(room: String, on: bool) -> void:
	for l in lights.get(room, []):
		l.visible = on


## Something to read: a note, a list, a flyer.
func note(id: String, title: String, text: String, pos: Vector3, yaw := 0.0, size := Vector3(0.2, 0.28, 0.01)) -> UsableBody:
	var n := UsableBody.new()
	n.name = "Note_" + id
	n.position = pos
	n.rotation.y = deg_to_rad(yaw)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	bm.material = Kit.flat(Color(0.97, 0.95, 0.85))
	mi.mesh = bm
	n.add_child(mi)
	n.add_box(Vector3.ZERO, size.max(Vector3(0.1, 0.1, 0.1)))
	n.add_action("interact", "Read", _read.bind(id, title, text))
	add_child(n)
	return n


## Something to take: it goes in the player's bag.
func pickup(item: String, verb: String, path: String, pos: Vector3, scale := 1.0, yaw := 0.0, event := "") -> UsableBody:
	var p := UsableBody.new()
	p.name = "Pickup_" + item
	p.position = pos
	p.rotation.y = deg_to_rad(yaw)
	var m := Kit.scene(path).instantiate() as Node3D
	m.scale = Vector3.ONE * scale
	p.add_child(m)
	var box := Kit.aabb_of(m)
	p.add_box(box.get_center(), box.size.max(Vector3(0.15, 0.15, 0.15)))
	p.add_action("interact", verb, _take.bind(item, event, p))
	add_child(p)
	return p


## Builds the people's navigation mesh from everything in Kit.NAV_GROUP
## (doors are left out, so paths go through doorways).
func bake_navigation(on_thread := true) -> void:
	nav_region = NavigationRegion3D.new()
	nav_region.name = "Navigation"
	var nm := NavigationMesh.new()
	nm.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	nm.geometry_source_geometry_mode = NavigationMesh.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
	nm.geometry_source_group_name = Kit.NAV_GROUP
	nm.geometry_collision_mask = Kit.LAYER_WORLD
	nm.cell_size = 0.1
	nm.cell_height = 0.05
	nm.agent_radius = 0.3
	nm.agent_height = 1.6
	nm.agent_max_climb = 0.25
	nm.agent_max_slope = 40.0
	nav_region.navigation_mesh = nm
	add_child(nav_region)
	nav_region.bake_finished.connect(_on_bake_finished)
	nav_region.bake_navigation_mesh(on_thread)


func _on_bake_finished() -> void:
	navigation_ready.emit()


func _door(spec: Dictionary, c: Vector3, u: Vector3, yaw: float) -> void:
	var d := HouseDoor.make(spec.id, Kit.BUILDING + spec.get("model", "door-rotate-square-a.glb"))
	d.position = c - u * OPENING_HALF
	d.rotation.y = deg_to_rad(yaw)
	# Swing into the room on the side of `into`.
	var n := Vector3(u.z, 0, -u.x)
	var into: Vector2 = spec.get("into", Vector2(c.x + n.x, c.z + n.z))
	d.swing = 1 if n.dot(Vector3(into.x, 0, into.y) - c) >= 0.0 else -1
	d.locked = spec.get("locked", false)
	d.key_item = spec.get("key", "")
	d.pickable = spec.has("pick")
	d.pick_time = spec.get("pick", 6.0)
	d.is_open = spec.get("open", false)
	add_child(d)
	doors[d.id] = d
	if spec.get("outside", false):
		openings.append({"id": d.id, "kind": "door", "pos": c + Vector3(0, 1.0, 0)})


func _glass(body: StaticBody3D) -> void:
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.04, WINDOW_TOP - WINDOW_SILL, OPENING_HALF * 2.0)
	cs.shape = shape
	cs.position = Vector3(0, (WINDOW_SILL + WINDOW_TOP) * 0.5, 0)
	body.add_child(cs)


func _remove_glass(body: StaticBody3D) -> void:
	for mi in body.find_children("(_ignore)*", "MeshInstance3D", true, false):
		mi.queue_free()


func _pry_window(id: String, c: Vector3, yaw: float, wall: StaticBody3D) -> void:
	var w := UsableBody.new()
	w.name = "Window_" + id
	w.position = c
	w.rotation.y = deg_to_rad(yaw)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.02, WINDOW_TOP - WINDOW_SILL, OPENING_HALF * 2.0)
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.6, 0.75, 0.85, 0.35)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bm.material = glass
	mi.mesh = bm
	mi.position = Vector3(0, (WINDOW_SILL + WINDOW_TOP) * 0.5, 0)
	w.add_child(mi)
	w.add_box(mi.position, Vector3(0.06, WINDOW_TOP - WINDOW_SILL, OPENING_HALF * 2.0))
	w.add_action("interact", "Pry it open", _pry.bind(id, w))
	add_child(w)


func _pry(pic: PlayerInteractionComponent, id: String, w: UsableBody) -> void:
	var player: Node = pic.get_parent()
	if not player.has_item("pry_bar"):
		UsableBody.hint(pic, "It's shut tight. A pry bar would do it.")
		return
	Sfx.at(self, "kenney:metalClick", w.global_position + Vector3(0, 1.3, 0), 0.0, 0.7)
	StealthNoise.make(self, w.global_position + Vector3(0, 1.3, 0), 6.0, "pry", player)
	_record("pried:" + id)
	w.queue_free()


func _flip_switch(pic: PlayerInteractionComponent, rooms: Array, event: String, s: UsableBody) -> void:
	var on := not lights_on(rooms[0])
	for r in rooms:
		set_lights(r, on)
	Sfx.at(self, "kenney:metalClick", s.global_position, -10.0, 1.6)
	if not on:
		for r in rooms:
			_record("light_off:" + r)
		if event != "":
			_record(event)


func _read(pic: PlayerInteractionComponent, id: String, title: String, text: String) -> void:
	Sfx.at(self, "kenney:bookOpen", pic.get_parent().global_position, -10.0)
	_record("read:" + id)
	note_opened.emit(title, text)


func _take(pic: PlayerInteractionComponent, item: String, event: String, p: UsableBody) -> void:
	var player: Node = pic.get_parent()
	player.add_item(item)
	Sfx.at(self, "kenney:cloth2", p.global_position, -8.0)
	_record("took:" + item)
	if event != "":
		_record(event)
	p.queue_free()


func _record(event: String) -> void:
	if JobRun.current:
		JobRun.current.record(event)
