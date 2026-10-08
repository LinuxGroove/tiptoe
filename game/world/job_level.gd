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
## The power went off (false) or came back (true) at the fuse box.
signal power_changed(on: bool)
## The alarm went off (a camera, a laser, a guard) or was silenced.
signal alarm_changed(ringing: bool)

## The level being played (noises ask it about machinery drowning them out).
static var current: JobLevel

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
## Rooms whose lamps go off with the power (see [method set_power]).
var circuit: Array = []
## Seconds the alarm rings for. Cameras and lasers on the "powered" group
## stop working with the power off, and so does the alarm.
var alarm_time := 20.0
var alarm_ringing := false
## The alarm's on/off switch (a security office): off, nothing raises it.
var alarm_armed := true
## [{name, box (AABB), allow (Array of disguises)}]: places only some
## disguises belong. A disguise works anywhere except zones that don't list it.
var zones: Array = []
## [[AABB, amount 0..1]]: loud machinery that drowns out quieter noises.
var masking: Array = []
## The treasure's stand (see [method treasure]).
var treasure_stand: UsableBody
var _treasure_item := ""
var _treasure_path := ""
var _treasure_scale := 1.0
var _treasure_model: Node3D
var _power_off := false
var _lights_before := {}
var _alarm_t := 0.0
var _alarm_loop: AudioStreamPlayer3D
var _alarm_at := Vector3.ZERO
var _player_inside := false
var _last_outside := Vector3.ZERO
var _areas_seen := {}
var _at_way_out := ""


func _enter_tree() -> void:
	current = self


func _exit_tree() -> void:
	if current == self:
		current = null


## Builds the whole level. Levels override this.
func build() -> void:
	pass


## Puts the treasure back where it was (the player was caught with it).
## Levels with their own treasure override this.
func return_treasure() -> void:
	if treasure_stand == null or _treasure_model != null:
		return
	_place_treasure_model()
	treasure_stand.set_action_text("interact", "Take it")


## The voices of this level's people, for recording them: voice -> {who (a
## line describing them, for whoever records), kokoro (the Kokoro voice),
## speed}. Voice ids are unique across jobs ("market_clerk"). Levels override
## this.
func voice_info() -> Dictionary:
	return {}


## Viewpoints for tools/screenshot.tscn: name -> [feet position, yaw in
## degrees (0 looks north, -Z), pitch in degrees].
func screenshot_views() -> Dictionary:
	return {}


## Someone answered the front door and the player is on the step: the
## level decides what happens (the pizza delivery gets let in). Return true
## if it dealt with it; false, and they shrug and close the door.
func at_front_door(_person: Person, _p: Moth) -> bool:
	return false


## Does `person` think nothing of the player being here? By default, when
## the player wears a disguise the person accepts, walks upright (crouching
## and sprinting look shifty), and isn't in a zone that disguise doesn't
## belong in. Levels override this for special cases.
func expects(person: Person, p: Moth) -> bool:
	if p.disguise == "" or not p.disguise in person.accepts:
		return false
	if p.is_crouching or p.is_sprinting:
		return false
	return disguise_fits(p.disguise, p.global_position)


## Does `disguise` belong at `at`? (False inside a zone that doesn't list it.)
func disguise_fits(disguise: String, at: Vector3) -> bool:
	for z in zones:
		if z.box.has_point(at) and not disguise in z.allow:
			return false
	return true


## A place only some disguises belong (a stock room, a vault corridor).
func add_zone(zone_name: String, box: AABB, allow: Array = []) -> void:
	zones.append({"name": zone_name, "box": box, "allow": allow})


## Loud machinery: noises inside `box` carry `amount` (0..1) less far.
func add_masking(box: AABB, amount: float) -> void:
	masking.append([box, clampf(amount, 0.0, 0.95)])


## How much noise at `at` is drowned out (0 none, up to 0.95).
func masking_at(at: Vector3) -> float:
	var m := 0.0
	for pair in masking:
		if pair[0].has_point(at):
			m = maxf(m, pair[1])
	return m


## Adds the people (and pets) who live here. Levels override this.
func add_people(_run: JobRun) -> Array:
	return []


func _physics_process(delta: float) -> void:
	if alarm_ringing:
		_alarm_t -= delta
		if _alarm_t <= 0.0:
			silence_alarm()
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
## {id, into: Vector2 a point in the room it swings into, locked, key, pick,
## model, open, outside, slide, people_open, key_verb}).
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
	s.set_meta("dartable", true)
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


## The treasure on a stand (a table, a plinth): "Take it" puts `item` in the
## bag and records "took_treasure". [method return_treasure] puts it back.
func treasure(item: String, verb: String, path: String, pos: Vector3, scale := 1.0, yaw := 0.0, box := Vector3(0.5, 0.5, 0.5)) -> UsableBody:
	_treasure_item = item
	_treasure_path = path
	_treasure_scale = scale
	treasure_stand = UsableBody.new()
	treasure_stand.name = "Treasure"
	treasure_stand.position = pos
	treasure_stand.rotation.y = deg_to_rad(yaw)
	treasure_stand.collision_layer = Kit.LAYER_INTERACT
	treasure_stand.add_box(Vector3(0, box.y * 0.5, 0), box)
	treasure_stand.add_action("interact", verb, _take_treasure)
	add_child(treasure_stand)
	_place_treasure_model()
	return treasure_stand


func _place_treasure_model() -> void:
	_treasure_model = Kit.scene(_treasure_path).instantiate()
	_treasure_model.scale = Vector3.ONE * _treasure_scale
	treasure_stand.add_child(_treasure_model)


func _take_treasure(pic: PlayerInteractionComponent) -> void:
	if _treasure_model == null:
		return
	var player: Node = pic.get_parent()
	player.add_item(_treasure_item)
	_treasure_model.queue_free()
	_treasure_model = null
	Sfx.at(self, "caper_done", treasure_stand.global_position, -6.0)
	_record("took_treasure")
	treasure_stand.set_action_text("interact", "")


## A disguise to put on (a cap, an apron): wearing it records
## "wore:<disguise>". Wearing a new one swaps the old one.
func disguise_pickup(disguise: String, verb: String, path: String, pos: Vector3, scale := 1.0, yaw := 0.0, said := "") -> UsableBody:
	var d := pickup("disguise_" + disguise, verb, path, pos, scale, yaw)
	d.action("interact").on_use = _wear.bind(disguise, said, d)
	return d


func _wear(pic: PlayerInteractionComponent, disguise: String, said: String, d: UsableBody) -> void:
	var player: Node = pic.get_parent()
	player.set_disguise(disguise)
	Sfx.at(self, "kenney:cloth2", d.global_position, -8.0)
	if said != "":
		UsableBody.hint(pic, said)
	_record("wore:" + disguise)
	d.queue_free()


## Somewhere to hide: a wardrobe, a cupboard, a cardboard box. The player
## steps in and looks out from `eye` (in the spot's space) until they use it
## again. People don't see someone hiding, unless they watched them go in.
func hide_spot(spot_name: String, verb: String, pos: Vector3, yaw := 0.0, eye := Vector3(0, 1.4, 0), box := Vector3(1.0, 2.0, 0.6)) -> HideSpot:
	var h := HideSpot.make(spot_name, verb, eye, box)
	h.position = pos
	h.rotation.y = deg_to_rad(yaw)
	add_child(h)
	return h


## A fuse box: flipping it turns off the power to `circuit`, with the lamps,
## cameras, lasers and the alarm. People who fix the power come to it (the
## level's "fuse_box" point).
func fuse_box(pos: Vector3, yaw := 0.0) -> UsableBody:
	var fuse := UsableBody.new()
	fuse.name = "FuseBox"
	fuse.position = pos
	fuse.rotation.y = deg_to_rad(yaw)
	fuse.add_child(Kit.scene(Kit.PROPS + "fuse_box.glb").instantiate())
	fuse.add_box(Vector3(0, 0.25, 0.08), Vector3(0.4, 0.5, 0.16))
	fuse.add_action("interact", "Flip the main breaker", _flip_breaker.bind(fuse))
	fuse.set_meta("dartable", true)
	add_child(fuse)
	return fuse


func _flip_breaker(pic: PlayerInteractionComponent, fuse: Node3D) -> void:
	StealthNoise.make(self, fuse.global_position, 3.0, "breaker", pic.get_parent())
	set_power(_power_off)


## Turns the power on or off (the fuse box; people fix it too).
func set_power(on: bool) -> void:
	if on != _power_off:
		return
	_power_off = not on
	var at: Vector3 = points.get("fuse_box", Vector3.ZERO) + Vector3(0, 1.4, 0)
	Sfx.at(self, "breaker_on" if on else "breaker_off", at, -2.0)
	if not on:
		for r in circuit:
			_lights_before[r] = lights_on(r)
			set_lights(r, false)
		_record("lights_out")
		silence_alarm()
		get_tree().call_group("people", "lights_went_out")
	else:
		for r in circuit:
			set_lights(r, _lights_before.get(r, false))
	get_tree().call_group("powered", "set_powered", on)
	power_changed.emit(on)


func power_off() -> bool:
	return _power_off


## Raises the alarm at `at` (where the camera saw someone, the laser that was
## crossed): it rings, and people who answer alarms come running.
func raise_alarm(at: Vector3, cause := "") -> void:
	if _power_off or not alarm_armed:
		return
	_alarm_at = at
	_alarm_t = alarm_time
	if not alarm_ringing:
		alarm_ringing = true
		_record("alarm")
		if cause != "":
			_record("alarm:" + cause)
		_alarm_loop = Sfx.on(self, "alarm_loop", -6.0)
		_alarm_loop.global_position = at + Vector3(0, 2.0, 0)
		_alarm_loop.max_distance = 80.0
		alarm_changed.emit(true)
	get_tree().call_group("people", "on_alarm", at)


func silence_alarm() -> void:
	if not alarm_ringing:
		return
	alarm_ringing = false
	_alarm_t = 0.0
	if is_instance_valid(_alarm_loop):
		_alarm_loop.queue_free()
	alarm_changed.emit(false)


## A switch that arms and disarms the alarm (and stops it ringing).
func alarm_switch(pos: Vector3, yaw := 0.0) -> UsableBody:
	var s := UsableBody.new()
	s.name = "AlarmSwitch"
	s.position = pos
	s.rotation.y = deg_to_rad(yaw)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.3, 0.4, 0.08)
	bm.material = Kit.flat(Color(0.75, 0.2, 0.18))
	mi.mesh = bm
	s.add_child(mi)
	s.add_box(Vector3.ZERO, Vector3(0.34, 0.44, 0.12))
	s.add_action("interact", "Turn off the alarm", _toggle_alarm.bind(s))
	s.set_meta("dartable", true)
	add_child(s)
	return s


func _toggle_alarm(_pic: PlayerInteractionComponent, s: UsableBody) -> void:
	alarm_armed = not alarm_armed
	Sfx.at(self, "kenney:metalClick", s.global_position, -8.0, 1.2)
	if not alarm_armed:
		silence_alarm()
		_record("alarm_off")
	s.set_action_text("interact", "Turn on the alarm" if not alarm_armed else "Turn off the alarm")


## A security camera on a wall at `pos` (the wall plate), looking out along
## `yaw` (degrees; 0 looks south, +Z). opts: sweep, period, pitch (degrees,
## seconds, degrees) and accepts (disguises it ignores where they fit).
func camera(id: String, pos: Vector3, yaw: float, opts := {}) -> SecurityCamera:
	var c := SecurityCamera.make(id, self)
	c.position = pos
	c.rotation.y = deg_to_rad(yaw)
	c.sweep = opts.get("sweep", 45.0)
	c.period = opts.get("period", 8.0)
	c.pitch = opts.get("pitch", 25.0)
	c.accepts = opts.get("accepts", [])
	add_child(c)
	return c


## A keypad at `pos` on a wall facing `yaw`, unlocking door `door_id` (if
## any) with `code`.
func keypad(id: String, code: String, pos: Vector3, yaw := 0.0, door_id := "") -> Keypad:
	var k := Keypad.make(id, code)
	k.position = pos
	k.rotation.y = deg_to_rad(yaw)
	if door_id != "":
		k.door = doors.get(door_id)
	add_child(k)
	return k


## Laser beams between floor points `a` and `b` at `heights` (metres).
func lasers(id: String, a: Vector3, b: Vector3, heights := [0.35, 0.9, 1.45], period := 0.0) -> LaserGate:
	var g := LaserGate.make(id, self, a, b, heights)
	g.period = period
	add_child(g)
	return g


## A switch (a security office's panel) for every node in `group`
## ("cameras" or "lasers"), recording "<group>_off" when it turns them off.
func group_switch(group: String, verb_off: String, verb_on: String, pos: Vector3, yaw := 0.0) -> UsableBody:
	var s := UsableBody.new()
	s.name = "Switch_" + group
	s.position = pos
	s.rotation.y = deg_to_rad(yaw)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.3, 0.2, 0.06)
	bm.material = Kit.flat(Color(0.3, 0.32, 0.36))
	mi.mesh = bm
	s.add_child(mi)
	s.add_box(Vector3.ZERO, Vector3(0.34, 0.24, 0.1))
	s.set_meta("on", true)
	s.add_action("interact", verb_off, _flip_group.bind(group, verb_off, verb_on, s))
	s.set_meta("dartable", true)
	add_child(s)
	return s


func _flip_group(_pic: PlayerInteractionComponent, group: String, verb_off: String, verb_on: String, s: UsableBody) -> void:
	var on: bool = not s.get_meta("on")
	s.set_meta("on", on)
	get_tree().call_group(group, "set_switched_on", on)
	Sfx.at(self, "kenney:metalClick", s.global_position, -8.0, 1.3)
	if not on:
		_record(group + "_off")
	s.set_action_text("interact", verb_on if not on else verb_off)


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
	# The navigation map takes in the new mesh over the next few physics
	# frames; paths come back empty until it has.
	var map := get_world_3d().navigation_map
	var probe: Vector3 = points.values()[0] if not points.is_empty() else Vector3.ZERO
	for i in 120:
		await get_tree().physics_frame
		if NavigationServer3D.map_get_iteration_id(map) > 0 and NavigationServer3D.map_get_closest_point(map, probe) != Vector3.ZERO:
			break
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
	d.slide = spec.get("slide", false)
	d.people_open = spec.get("people_open", true)
	d.key_verb = spec.get("key_verb", "")
	add_child(d)
	doors[d.id] = d
	if spec.get("outside", false):
		openings.append({"id": d.id, "kind": "door", "pos": c + Vector3(0, 1.0, 0)})


func _glass(wall: StaticBody3D) -> void:
	var glass := StaticBody3D.new()
	glass.name = "Glass"
	glass.collision_layer = Kit.LAYER_GLASS
	glass.collision_mask = 0
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.04, WINDOW_TOP - WINDOW_SILL, OPENING_HALF * 2.0)
	cs.shape = shape
	cs.position = Vector3(0, (WINDOW_SILL + WINDOW_TOP) * 0.5, 0)
	glass.add_child(cs)
	wall.add_child(glass)


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
	w.collision_layer = Kit.LAYER_GLASS | Kit.LAYER_INTERACT
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
