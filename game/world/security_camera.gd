class_name SecurityCamera
extends Node3D
## A CCTV camera on a wall. It pans back and forth, and its faint cone of
## light shows where it's looking. Someone in its view fills its meter (faster
## when lit and near); a full meter raises the level's alarm where they stand.
## It stops with the power off, while the security office has the cameras
## switched off, and for a while after a dart hits it. Disguises it
## `accepts` don't bother it where the disguise fits.

const MODEL := "res://assets/models/props/security_camera.glb"
const RANGE := 12.0
const HALF_ANGLE := 28.0
const FILL := 1.4
const DRAIN := 0.35
## Seconds a dart knocks it out for.
const STUN_TIME := 20.0
const COOLDOWN := 8.0

var id := ""
## Degrees either side of straight out from the wall it pans through.
var sweep := 45.0
## Seconds for one pan across and back.
var period := 8.0
## Degrees it looks down.
var pitch := 25.0
var accepts: Array = []
var level: JobLevel
## 0..1: how sure it is someone's there.
var meter := 0.0
var powered := true
var switched_on := true
var _head: Node3D
var _cone: SpotLight3D
var _led: OmniLight3D
var _t := 0.0
var _stun_t := 0.0
var _cool_t := 0.0
var _tracking := false
var _was_working := true
var _servo: AudioStreamPlayer3D


static func make(p_id: String, p_level: JobLevel) -> SecurityCamera:
	var c := SecurityCamera.new()
	c.id = p_id
	c.name = "Camera_" + p_id
	c.level = p_level
	return c


func _ready() -> void:
	add_to_group("powered")
	add_to_group("cameras")
	var m: Node3D = Kit.scene(MODEL).instantiate()
	add_child(m)
	_head = m.find_child("head", true, false) as Node3D
	if _head == null:
		_head = m
	_cone = SpotLight3D.new()
	_cone.spot_range = RANGE
	_cone.spot_angle = HALF_ANGLE
	_cone.light_energy = 0.35
	_cone.light_color = Color(0.6, 0.85, 1.0)
	_cone.shadow_enabled = false
	# The head looks along +Z; a spotlight shines down its own -Z.
	_cone.rotation.y = PI
	_head.add_child(_cone)
	_led = OmniLight3D.new()
	_led.omni_range = 0.6
	_led.light_energy = 1.2
	_led.position = Vector3(0, 0.05, 0.2)
	_head.add_child(_led)
	_servo = Sfx.on(_head, "camera_servo_loop", -24.0)
	_t = randf() * period
	_head.rotation.x = deg_to_rad(pitch)
	_update_look()


## The power went off or came back (the "powered" group).
func set_powered(on: bool) -> void:
	powered = on
	_update_look()


## Switched off (or on) from a security office.
func set_switched_on(on: bool) -> void:
	switched_on = on
	_update_look()


## Hit by a dart: knocked out for a while.
func stun() -> void:
	_stun_t = STUN_TIME
	meter = 0.0
	Sfx.at(self, "dart_hit_soft", global_position, -4.0)
	if JobRun.current:
		JobRun.current.record("camera_darted")
	_update_look()


func lens_position() -> Vector3:
	return _head.global_position + _head.global_basis.z * 0.12


func is_working() -> bool:
	return powered and switched_on and _stun_t <= 0.0


func _physics_process(delta: float) -> void:
	_stun_t = maxf(0.0, _stun_t - delta)
	_cool_t = maxf(0.0, _cool_t - delta)
	var working := is_working()
	if working != _was_working:
		_was_working = working
		_update_look()
	if not working:
		return
	var p := get_tree().get_first_node_in_group("moth") as Moth
	var sees := p != null and _can_see(p)
	if sees:
		meter = minf(1.0, meter + _how_seen(p) * FILL * delta)
		_track(p, delta)
		if meter >= 1.0 and _cool_t <= 0.0:
			_cool_t = COOLDOWN
			Sfx.at(self, "camera_alert", global_position, -2.0)
			if JobRun.current:
				JobRun.current.record("camera_saw")
				JobRun.current.add_spotted()
			level.raise_alarm(p.global_position, "camera")
	else:
		meter = maxf(0.0, meter - DRAIN * delta)
		_t += delta
		var yaw := sin(_t / period * TAU) * deg_to_rad(sweep)
		_head.rotation.y = lerp_angle(_head.rotation.y, yaw, minf(1.0, delta * 3.0))
	if sees != _tracking:
		_tracking = sees
		_update_look()


func _can_see(p: Moth) -> bool:
	if p.hiding != null:
		return false
	var eye := _head.global_position
	var at := p.chest_position()
	var d := eye.distance_to(at)
	if d > RANGE:
		return false
	var fwd := _head.global_transform.basis.z.normalized()
	if rad_to_deg(fwd.angle_to((at - eye).normalized())) > HALF_ANGLE:
		return false
	if p.disguise != "" and p.disguise in accepts and level.disguise_fits(p.disguise, p.global_position) and not p.is_crouching:
		return false
	var q := PhysicsRayQueryParameters3D.create(eye, at, Kit.LAYER_SOLID)
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	return not hit.is_empty() and hit.collider == p


## How plainly it sees them: lit and near is quick, dark and far is slow.
func _how_seen(p: Moth) -> float:
	var d := _head.global_position.distance_to(p.chest_position())
	var near := 1.0 - d / RANGE
	return clampf(p.visibility * 1.5 + near * 0.6, 0.15, 2.0)


func _track(p: Moth, delta: float) -> void:
	var local := global_transform.affine_inverse() * p.global_position
	var yaw := clampf(atan2(local.x, local.z), -deg_to_rad(sweep + 15.0), deg_to_rad(sweep + 15.0))
	_head.rotation.y = lerp_angle(_head.rotation.y, yaw, minf(1.0, delta * 4.0))


func _update_look() -> void:
	if _cone == null:
		return
	var on := is_working()
	_cone.visible = on
	_led.visible = on
	_led.light_color = Color(1.0, 0.15, 0.1) if _tracking else Color(0.3, 1.0, 0.3)
	_cone.light_color = Color(1.0, 0.45, 0.35) if _tracking else Color(0.6, 0.85, 1.0)
	if _servo:
		if on and not _servo.playing:
			_servo.play()
		elif not on:
			_servo.stop()
