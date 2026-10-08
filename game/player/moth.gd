class_name Moth
extends CogitoPlayer
## The player: Cogito's first person controller with what a burglar needs on
## top. Leaning round corners, climbing onto ledges and sills, footsteps that
## make noise people can hear, how lit you are, and a disguise. Cogito's own
## pause menu, health and sanity are left out; Tiptoe has no damage.

signal disguise_changed(disguise: String)
signal bag_changed

## Cogito player nodes Tiptoe doesn't use.
const UNUSED := ["CogtoTestCurrency", "StrengthAttribute", "LightMeterAttribute",
	"SanityAttribute", "StaminaAttribute", "HealthAttribute", "HealthAutoConsume",
	"StaminaAutoConsume", "AutoPickUpZone"]

const LEAN_OFFSET := 0.42
const LEAN_TILT := 9.0
const LEAN_SPEED := 9.0
## Ledges the player can climb onto, above their feet.
const MANTLE_MIN := 0.45
const MANTLE_MAX := 1.75
const MANTLE_TIME := 0.45

## How lit the player is, 0 (pitch dark) to 1 (in a lamp's glare).
var visibility := 0.0
## "" or the disguise being worn, like "pizza".
var disguise := ""
## What the player carries: item id -> how many.
var bag := {}
## Tiptoe's pause menu, set by the job before the player enters the tree.
var tiptoe_pause: Node
var light_probe: LightProbe
var _lean := 0.0
var _mantle_tween: Tween
var _feet_offset := 0.0


func _ready():
	$PlayerInteractionComponent.stamina_attribute = null
	for n in UNUSED:
		var node := get_node_or_null(n)
		if node:
			remove_child(node)
			node.free()
	var cogito_pause := get_node_or_null(pause_menu)
	if cogito_pause:
		cogito_pause.get_parent().remove_child(cogito_pause)
		cogito_pause.free()
	if tiptoe_pause:
		pause_menu = tiptoe_pause.get_path()
	fall_damage = 0
	CAN_BUNNYHOP = false
	disable_roll_anim = true
	WALKING_SPEED = 3.6
	SPRINTING_SPEED = 6.0
	CROUCHING_SPEED = 2.0
	walk_volume_db = -26.0
	sprint_volume_db = -18.0
	crouch_volume_db = -40.0
	_feet_offset = -_feet_height()
	_reload_options()
	super()
	light_probe = LightProbe.new()
	light_probe.name = "LightProbe"
	light_probe.player = self
	add_child(light_probe)
	var hud := get_node_or_null(player_hud)
	if hud:
		# Tiptoe's own HUD shows the bag; Cogito's inventory and bars stay hidden.
		for n in ["FixedStaminaBar", "InventoryInterface", "MarginContainer_BottomUI"]:
			var c := hud.get_node_or_null(n) as CanvasItem
			if c:
				c.hide()
				c.process_mode = Node.PROCESS_MODE_DISABLED
	add_to_group("moth")


## Settings come from LGSettings, not Cogito's own options file.
func _reload_options():
	MOUSE_SENS = float(LGSettings.get_value("play", "mouse_sensitivity", 0.25))
	# Cogito's INVERT_Y_AXIS = true is the usual (not inverted) look.
	INVERT_Y_AXIS = not bool(LGSettings.get_value("play", "invert_look", false))
	TOGGLE_CROUCH = bool(LGSettings.get_value("play", "toggle_crouch", true))
	HEADBOBBLE = float(LGSettings.get_value("play", "head_bob", 0.7))
	JOY_H_SENS = float(LGSettings.get_value("play", "stick_sensitivity", 2.0))
	JOY_V_SENS = JOY_H_SENS


func _physics_process(delta):
	if _mantle_tween and _mantle_tween.is_running():
		return
	if not is_movement_paused and not is_showing_ui and Input.is_action_just_pressed("jump") and _try_mantle():
		return
	super(delta)
	_update_lean(delta)


## Where people look for the player: the eyes, wherever a lean puts them.
func eye_position() -> Vector3:
	return camera.global_position


func chest_position() -> Vector3:
	return global_position + Vector3(0, 0.1 if is_crouching else 0.35, 0)


func feet_position() -> Vector3:
	return global_position + Vector3(0, _feet_offset, 0)


func has_item(item: String) -> bool:
	return int(bag.get(item, 0)) > 0


func add_item(item: String, count := 1) -> void:
	bag[item] = int(bag.get(item, 0)) + count
	bag_changed.emit()


## Uses up one of an item; false if there wasn't one.
func take_item(item: String) -> bool:
	if not has_item(item):
		return false
	bag[item] = int(bag[item]) - 1
	if bag[item] <= 0:
		bag.erase(item)
	bag_changed.emit()
	return true


func set_disguise(d: String) -> void:
	if d == disguise:
		return
	disguise = d
	disguise_changed.emit(d)


func _update_lean(delta: float) -> void:
	var want := 0.0
	if not is_movement_paused and not is_showing_ui and is_on_floor():
		want = Input.get_action_strength("lean_right") - Input.get_action_strength("lean_left")
	if want != 0.0:
		# Don't lean through walls: stop short of anything at the side.
		var side := body.global_transform.basis.x * signf(want)
		var from := neck.global_position - neck.transform.basis.x * neck.position.x
		var space := get_world_3d().direct_space_state
		var q := PhysicsRayQueryParameters3D.create(from, from + side * (LEAN_OFFSET + 0.25), 1)
		q.exclude = [get_rid()]
		var hit := space.intersect_ray(q)
		if hit:
			var room := maxf(0.0, from.distance_to(hit.position) - 0.25)
			want *= clampf(room / LEAN_OFFSET, 0.0, 1.0)
	_lean = lerpf(_lean, want, clampf(delta * LEAN_SPEED, 0.0, 1.0))
	neck.position.x = _lean * LEAN_OFFSET
	camera.rotation.z = -deg_to_rad(_lean * LEAN_TILT)


## Climbs onto a ledge in front (a sill, a low wall, a crate) if there is
## one between knee and head height with room to stand or crouch on top.
func _try_mantle() -> bool:
	var space := get_world_3d().direct_space_state
	var fwd := -body.global_transform.basis.z
	fwd.y = 0
	fwd = fwd.normalized()
	var feet := feet_position()
	# Something in front at waist height?
	var q := PhysicsRayQueryParameters3D.create(feet + Vector3(0, 0.7, 0), feet + Vector3(0, 0.7, 0) + fwd * 0.8, 1)
	q.exclude = [get_rid()]
	var front := space.intersect_ray(q)
	if front.is_empty():
		q = PhysicsRayQueryParameters3D.create(feet + Vector3(0, MANTLE_MIN + 0.05, 0), feet + Vector3(0, MANTLE_MIN + 0.05, 0) + fwd * 0.8, 1)
		q.exclude = [get_rid()]
		front = space.intersect_ray(q)
		if front.is_empty():
			return false
	# Find the top of it.
	# Just past the edge, so thin sills count.
	var probe: Vector3 = front.position + fwd * 0.12
	q = PhysicsRayQueryParameters3D.create(Vector3(probe.x, feet.y + MANTLE_MAX + 0.3, probe.z), Vector3(probe.x, feet.y + MANTLE_MIN - 0.05, probe.z), 1)
	q.exclude = [get_rid()]
	var top := space.intersect_ray(q)
	if top.is_empty() or top.normal.y < 0.7:
		return false
	var rise: float = top.position.y - feet.y
	if rise < MANTLE_MIN or rise > MANTLE_MAX:
		return false
	# Room on top for a crouching player?
	var standing_on: Vector3 = top.position
	var shape := crouching_collision_shape.shape
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.collision_mask = 1
	params.exclude = [get_rid()]
	params.transform = Transform3D(Basis(), standing_on + Vector3(0, _shape_half_height(shape) + 0.05, 0))
	if not space.intersect_shape(params, 1).is_empty():
		return false
	# Up, then over, crouched so low gaps (windows) fit.
	try_crouch = true
	is_crouching = true
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = false
	var target := standing_on + Vector3(0, -_feet_offset + 0.05, 0)
	var up := Vector3(global_position.x, target.y, global_position.z)
	main_velocity = Vector3.ZERO
	velocity = Vector3.ZERO
	_mantle_tween = create_tween()
	_mantle_tween.tween_property(self, "global_position", up, MANTLE_TIME * 0.6).set_trans(Tween.TRANS_SINE)
	_mantle_tween.tween_property(self, "global_position", target, MANTLE_TIME * 0.4)
	StealthNoise.make(self, feet, 2.5, "climb", self)
	return true


func _feet_height() -> float:
	var s := standing_collision_shape
	return -(s.position.y - _shape_half_height(s.shape))


static func _shape_half_height(shape: Shape3D) -> float:
	if shape is BoxShape3D:
		return shape.size.y * 0.5
	if shape is CapsuleShape3D or shape is CylinderShape3D:
		return shape.height * 0.5
	return 0.9
