class_name BottlingCrane
extends Node3D
## The jib crane in the loading dock, with a crate of lemonade on its hook.
## One lever swings it between the truck (A) and the dock catwalk (B): the
## crate goes up, round and down again, and put down at B it's a step up to
## the catwalk. The other lever lets go of the hook: a crate in the air
## falls and smashes, loud enough to bring everyone running.

## The crate hit the floor at `at`.
signal crashed(at: Vector3)

const MODEL := BottlingLevel.FACTORY + "crane.glb"
const SCALE := 1.3
## From the pillar to the hook, along the arm.
const REACH := 3.1
## How high the crate's bottom rides while it swings.
const LIFT := 2.9
const CRATE_SIZE := Vector3(1.54, 1.32, 1.4)
const HOIST_TIME := 2.0
const SWING_TIME := 4.0
const CRASH_RADIUS := 30.0
## Height of the arm's underside, where the chain hangs from.
const ARM_Y := 3.0 * SCALE - 0.15

## Arm angles (radians about Y; 0 points north) for A and B.
var angle_a := 0.0
var angle_b := 0.0
var angle := 0.0
## Height of the crate's bottom above the floor.
var crate_y := 0.0
## "a" or "b" while the crate rests at one of them, "" in between.
var at := "a"
var dropped := false
var crate: AnimatableBody3D
var lever_swing: UsableBody
var lever_drop: UsableBody
## Where the player has to get to after standing on the crate at B.
var catwalk_box := AABB()
var _arm: Node3D
var _chain: MeshInstance3D
var _hook: MeshInstance3D
var _tween: Tween
var _motor: AudioStreamPlayer3D
var _stood_at := -100.0


static func make(p_angle_a: float, p_angle_b: float) -> BottlingCrane:
	var c := BottlingCrane.new()
	c.name = "Crane"
	c.angle_a = p_angle_a
	c.angle_b = p_angle_b
	c.angle = p_angle_a
	return c


func _ready() -> void:
	var m: Node3D = Kit.scene(MODEL).instantiate()
	m.scale = Vector3.ONE * SCALE
	add_child(m)
	_arm = m.find_child("arm", true, false) as Node3D
	# The pillar blocks; the arm is overhead.
	var pillar := StaticBody3D.new()
	pillar.collision_layer = Kit.LAYER_WORLD
	pillar.collision_mask = 0
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.2, 4.0, 1.2)
	cs.shape = shape
	cs.position = Vector3(0, 2.0, 0)
	pillar.add_child(cs)
	add_child(pillar)
	pillar.add_to_group(Kit.NAV_GROUP)
	_hook = MeshInstance3D.new()
	var hm := BoxMesh.new()
	hm.size = Vector3(0.35, 0.2, 0.35)
	hm.material = Kit.flat(Color(0.85, 0.6, 0.15))
	_hook.mesh = hm
	add_child(_hook)
	_chain = MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.06, 1.0, 0.06)
	bm.material = Kit.flat(Color(0.25, 0.25, 0.28))
	_chain.mesh = bm
	add_child(_chain)
	crate = AnimatableBody3D.new()
	crate.name = "CraneCrate"
	crate.collision_layer = Kit.LAYER_WORLD
	crate.collision_mask = 0
	crate.sync_to_physics = false
	var box: Node3D = Kit.scene(BottlingLevel.FACTORY + "box-large.glb").instantiate()
	box.name = "Box"
	box.scale = Vector3(1.4, 2.4, 1.4)
	crate.add_child(box)
	var ccs := CollisionShape3D.new()
	var cshape := BoxShape3D.new()
	cshape.size = CRATE_SIZE
	ccs.shape = cshape
	ccs.position = Vector3(0, CRATE_SIZE.y * 0.5, 0)
	crate.add_child(ccs)
	Kit.add_surface(crate, "wood")
	add_child(crate)
	_motor = Sfx.on(self, "crane_motor_loop", -10.0, false)
	_place()


## The levers, on a post at `pos` (in the crane's parent's space).
func add_controls(level: Node3D, pos: Vector3, yaw: float) -> void:
	var post := Kit.block(level, pos + Vector3(0, 0.55, 0), Vector3(0.5, 1.1, 0.4), "", Kit.flat(Color(0.32, 0.34, 0.45)))
	post.name = "CraneControls"
	var basis := Basis(Vector3.UP, deg_to_rad(yaw))
	lever_swing = _lever(level, pos + basis * Vector3(-0.13, 1.1, 0), yaw, "Swing the crane", _on_swing)
	lever_drop = _lever(level, pos + basis * Vector3(0.13, 1.1, 0), yaw, "Let go of the hook", _on_drop)


func _lever(level: Node3D, pos: Vector3, yaw: float, verb: String, on_use: Callable) -> UsableBody:
	var u := UsableBody.new()
	u.name = "Lever_" + verb.get_slice(" ", 0)
	u.position = pos
	u.rotation.y = deg_to_rad(yaw)
	var m: Node3D = Kit.scene(BottlingLevel.FACTORY + "lever-single.glb").instantiate()
	m.scale = Vector3.ONE * 0.5
	u.add_child(m)
	u.add_box(Vector3(0, 0.12, 0), Vector3(0.24, 0.26, 0.2))
	u.add_action("interact", verb, on_use)
	u.set_meta("dartable", true)
	level.add_child(u)
	return u


## The crate's resting place on the floor at an arm angle.
func spot(a: float) -> Vector3:
	return global_position + Vector3(-sin(a), 0, -cos(a)) * REACH


func is_moving() -> bool:
	return _tween != null and _tween.is_valid() and _tween.is_running()


func _on_swing(_pic: PlayerInteractionComponent) -> void:
	swing()


func _on_drop(_pic: PlayerInteractionComponent) -> void:
	let_go()


## Swings the crate to the other end (if it's on the hook and resting).
func swing() -> bool:
	_flip(lever_swing)
	if dropped or is_moving():
		return false
	var to := angle_b if at == "a" else angle_a
	var dest := "b" if at == "a" else "a"
	at = ""
	_tween = create_tween()
	_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_method(_set_lift, crate_y, LIFT, HOIST_TIME).set_trans(Tween.TRANS_SINE)
	_tween.tween_method(_set_angle, angle, to, SWING_TIME).set_trans(Tween.TRANS_SINE)
	_tween.tween_method(_set_lift, LIFT, 0.0, HOIST_TIME).set_trans(Tween.TRANS_SINE)
	_tween.finished.connect(_arrived.bind(dest))
	_motor.play()
	StealthNoise.make(self, global_position + Vector3(0, 3.0, 0), 8.0, "door", get_tree().get_first_node_in_group("moth"))
	_record("crane_moved")
	return true


## Lets go of the hook: a crate in the air falls and smashes.
func let_go() -> bool:
	_flip(lever_drop)
	if dropped or crate_y < 0.3:
		Sfx.at(self, "kenney:metalClick", lever_drop.global_position, -8.0, 0.8)
		return false
	if _tween:
		_tween.kill()
	_motor.stop()
	dropped = true
	at = ""
	var fall := sqrt(2.0 * crate_y / 9.8)
	_tween = create_tween()
	_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_method(_set_lift, crate_y, 0.0, fall).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.finished.connect(_smash)
	return true


func _arrived(dest: String) -> void:
	at = dest
	_motor.stop()
	Sfx.at(self, "kenney:stoneDrag4", crate.global_position, -6.0)
	if dest == "b":
		_record("crane_bridge")


func _smash() -> void:
	var where := crate.global_position
	Sfx.at(self, "crate_crash", where + Vector3(0, 0.5, 0), 4.0)
	Sfx.at(self, "kenney:explosion2", where + Vector3(0, 0.5, 0), -6.0, 1.6)
	# A heap of splintered crate and broken bottles, not a step any more.
	var box := crate.get_node("Box") as Node3D
	box.scale = Vector3(1.6, 0.9, 1.5)
	box.rotation.y = 0.3
	var cs := crate.get_child(1) as CollisionShape3D
	(cs.shape as BoxShape3D).size = Vector3(1.6, 0.5, 1.5)
	cs.position = Vector3(0, 0.25, 0)
	for i in 6:
		var b: Node3D = Kit.scene(Kit.FOOD + "soda-bottle.glb").instantiate()
		b.scale = Vector3.ONE * 0.7
		b.rotation = Vector3(PI * 0.5, randf() * TAU, 0)
		b.position = Vector3(randf_range(-1.3, 1.3), 0.06, randf_range(-1.3, 1.3))
		crate.add_child(b)
	var puddle := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 1.4
	cm.bottom_radius = 1.4
	cm.height = 0.01
	cm.material = Kit.flat(Color(0.95, 0.9, 0.45), 0.2)
	puddle.mesh = cm
	puddle.position = Vector3(0, 0.01, 0)
	crate.add_child(puddle)
	StealthNoise.make(self, where + Vector3(0, 0.5, 0), CRASH_RADIUS, "knock", get_tree().get_first_node_in_group("moth"))
	_record("crate_dropped")
	if JobRun.current:
		JobRun.current.add_knocked()
	crashed.emit(where)


func _set_lift(y: float) -> void:
	crate_y = y
	_place()


func _set_angle(a: float) -> void:
	angle = a
	_place()


func _place() -> void:
	if _arm:
		_arm.rotation.y = angle
	var tip := Vector3(-sin(angle), 0, -cos(angle)) * REACH + Vector3(0, ARM_Y, 0)
	if not dropped:
		crate.position = Vector3(tip.x, crate_y, tip.z)
		crate.rotation.y = angle
	var hook_y := crate_y + CRATE_SIZE.y + 0.1 if not dropped else ARM_Y - 0.8
	var chain_len := maxf(tip.y - hook_y, 0.05)
	_chain.scale = Vector3(1, chain_len, 1)
	_chain.position = Vector3(tip.x, hook_y + chain_len * 0.5, tip.z)
	_hook.position = Vector3(tip.x, hook_y, tip.z)


func _physics_process(_delta: float) -> void:
	var run := JobRun.current
	if run == null or at != "b":
		return
	var p := get_tree().get_first_node_in_group("moth") as Moth
	if p == null:
		return
	var feet := p.feet_position()
	var local := crate.global_transform.affine_inverse() * feet
	if absf(local.x) < CRATE_SIZE.x * 0.5 + 0.1 and absf(local.z) < CRATE_SIZE.z * 0.5 + 0.1 and absf(local.y - CRATE_SIZE.y) < 0.3:
		_stood_at = run.time
	elif catwalk_box.has_point(feet + Vector3(0, 0.1, 0)) and run.time - _stood_at < 8.0:
		_record("crane_climb")


func _flip(lever: UsableBody) -> void:
	if lever == null:
		return
	var handle := lever.find_child("handle", true, false) as Node3D
	if handle:
		var t := handle.create_tween()
		t.tween_property(handle, "rotation:x", 0.6, 0.15)
		t.tween_property(handle, "rotation:x", 0.0, 0.4)
	Sfx.at(self, "kenney:metalClick", lever.global_position, -8.0, 0.9)


func _record(event: String) -> void:
	if JobRun.current:
		JobRun.current.record(event)
