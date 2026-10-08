class_name Gadgets
extends Node
## The gadget in hand. The mouse wheel (or the d-pad) picks one from the bag
## and the primary action uses it:
##   foam darts: the blaster flips switches and presses buttons from across
##     the room, knocks out a camera for a while, or makes a noise where it
##     lands; snooze darts send someone off for a nap.
##   the noisemaker: a wind-up toy that rattles where it lands.
##   treats: thrown where the dog can smell them (the secondary action throws
##     one whatever's in hand).

signal selected_changed(gadget: String)

## Gadgets in the order the wheel goes through them.
const ORDER := ["darts", "snooze_darts", "noisemaker", "treats"]
const TITLES := {
	"darts": "Foam darts", "snooze_darts": "Snooze darts",
	"noisemaker": "Noisemaker", "treats": "Dog treats",
}
const THROW_SPEED := 7.0
const RATTLE_DELAY := 1.2
const RATTLE_TIME := 6.0
const RATTLE_RADIUS := 11.0
const DART_RANGE := 30.0
const DART_NOISE := 5.0
## How close a dart has to pass a camera's lens to knock it out.
const CAMERA_HIT := 0.35

var player: Moth
var selected := ""


func _ready() -> void:
	if player:
		player.bag_changed.connect(_on_bag_changed)
	_on_bag_changed()


func _unhandled_input(event: InputEvent) -> void:
	if player == null or player.is_movement_paused or player.is_showing_ui or player.hiding != null:
		return
	if event.is_action_pressed("quickslot_next_wieldable"):
		cycle(1)
	elif event.is_action_pressed("quickslot_prev_wieldable"):
		cycle(-1)
	elif event.is_action_pressed("action_secondary") and player.has_item("treats"):
		use("treats")
	elif event.is_action_pressed("action_primary") and selected != "":
		use(selected)
	else:
		for i in 4:
			if event.is_action_pressed("quickslot_%d" % (i + 1)):
				var have := held()
				if i < have.size():
					select(have[i])


## The gadgets in the bag, in wheel order.
func held() -> Array:
	return ORDER.filter(func(g): return player != null and player.has_item(g))


func select(g: String) -> void:
	if g == selected:
		return
	selected = g
	selected_changed.emit(g)


func cycle(step: int) -> void:
	var have := held()
	if have.is_empty():
		return
	var i := have.find(selected)
	select(have[posmod(i + step, have.size())])


## Uses one of a gadget (from the bag). False if there was none.
func use(g: String) -> bool:
	if not player.take_item(g):
		return false
	match g:
		"darts", "snooze_darts":
			fire(g == "snooze_darts")
		"noisemaker":
			_throw("noisemaker")
		"treats":
			_throw("treat")
	return true


func _on_bag_changed() -> void:
	var have := held()
	if not selected in have:
		select(have[0] if not have.is_empty() else "")


# --- The dart blaster -----------------------------------------------------------

## Fires a dart where the player is looking. Returns what it hit.
func fire(snooze: bool) -> Node:
	var cam := player.camera
	var from := cam.global_position
	var dir := -cam.global_basis.z
	var to := from + dir * DART_RANGE
	Sfx.at(player, "dart_fire", from, -6.0)
	_record("fired_dart")
	var q := PhysicsRayQueryParameters3D.create(from, to, Kit.LAYER_SOLID | Kit.LAYER_GLASS | Kit.LAYER_INTERACT | Kit.LAYER_PEOPLE)
	q.exclude = [player.get_rid()]
	var hit := player.get_world_3d().direct_space_state.intersect_ray(q)
	var end: Vector3 = hit.position if not hit.is_empty() else to
	# A camera's lens is small and has no collider: a dart passing close counts.
	for c in get_tree().get_nodes_in_group("cameras"):
		var lens: Vector3 = c.lens_position()
		var along := (lens - from).dot(dir)
		if along > 0.0 and along < from.distance_to(end) + 0.2 and (from + dir * along).distance_to(lens) < CAMERA_HIT:
			c.stun()
			return c
	if hit.is_empty():
		return null
	var body: Node = hit.collider
	_dart_landed(end, hit.normal)
	var person := body as Person
	if person == null and body.get_parent() is Person:
		person = body.get_parent()
	if person:
		if snooze:
			person.snooze()
		else:
			person._curious(person.global_position, 0.6, person.line("curious"))
		_record("darted_person")
		return person
	if body is UsableBody and body.get_meta("dartable", false):
		var a: UseAction = body.action("interact")
		if a and not a.is_disabled:
			a.interact(player.player_interaction_component)
			_record("darted_switch")
			return body
	if body is Dog:
		if snooze:
			body.snooze()
		return body
	StealthNoise.make(player, end, DART_NOISE, "knock", player)
	return body


func _dart_landed(at: Vector3, normal: Vector3) -> void:
	Sfx.at(player, "dart_hit_soft", at, -6.0)
	var d: Node3D = Kit.scene("res://assets/kenney/blaster-kit/bullet-foam.glb").instantiate()
	d.scale = Vector3.ONE * 0.5
	player.get_parent().add_child(d)
	d.global_position = at + normal * 0.03
	if normal.cross(Vector3.UP).length() > 0.01:
		d.look_at(at - normal, Vector3.UP)
	get_tree().create_timer(12.0).timeout.connect(d.queue_free)


# --- Throwing ----------------------------------------------------------------------

func _throw(kind: String) -> RigidBody3D:
	var b := RigidBody3D.new()
	b.collision_layer = 0
	b.collision_mask = Kit.LAYER_WORLD | Kit.LAYER_GLASS
	b.mass = 0.2
	var cs := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.08
	cs.shape = shape
	b.add_child(cs)
	var path := Kit.FOOD + "cookie.glb" if kind == "treat" else "res://assets/kenney/blaster-kit/grenade-a.glb"
	var m: Node3D = Kit.scene(path).instantiate()
	m.scale = Vector3.ONE * (0.35 if kind == "treat" else 0.5)
	b.add_child(m)
	player.get_parent().add_child(b)
	var cam := player.camera
	b.global_position = cam.global_position - cam.global_basis.z * 0.5
	b.linear_velocity = -cam.global_basis.z * THROW_SPEED + Vector3(0, 1.5, 0) + player.velocity
	Sfx.at(player, "kenney:woosh1", b.global_position, -10.0)
	if kind == "treat":
		b.add_to_group("treats")
		_record("threw_treat")
	else:
		_record("used_noisemaker")
		_rattle(b)
	return b


func _rattle(b: RigidBody3D) -> void:
	await get_tree().create_timer(RATTLE_DELAY).timeout
	if not is_instance_valid(b):
		return
	Sfx.at(b, "noisemaker_wind", b.global_position, -2.0)
	var loop := Sfx.on(b, "noisemaker_rattle_loop", 0.0)
	var left := RATTLE_TIME
	while left > 0.0 and is_instance_valid(b):
		StealthNoise.make(b, b.global_position, RATTLE_RADIUS, "rattle", b)
		await get_tree().create_timer(0.8).timeout
		left -= 0.8
	if is_instance_valid(loop):
		loop.stop()


func _record(event: String) -> void:
	if JobRun.current:
		JobRun.current.record(event)
