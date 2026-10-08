class_name LaserGate
extends Node3D
## Laser beams across a corridor between two posts. Walking through a beam
## raises the alarm. Beams at knee height can be stepped over (jump), beams
## at chest height crouched under, and a gate with `period` blinks on and off.
## The beams go dark with the power, or from a switch.

const BEAM_COLOR := Color(1.0, 0.12, 0.1)

var id := ""
var level: JobLevel
## Seconds for one on-and-off blink (0: always on).
var period := 0.0
var powered := true
var switched_on := true
var _beams: Array[MeshInstance3D] = []
var _areas: Array[Area3D] = []
var _t := 0.0
var _hum: AudioStreamPlayer3D
var _cool_t := 0.0


## Beams from `a` to `b` (floor points, metres) at each height in `heights`.
static func make(p_id: String, p_level: JobLevel, a: Vector3, b: Vector3, heights: Array) -> LaserGate:
	var g := LaserGate.new()
	g.id = p_id
	g.name = "Lasers_" + p_id
	g.level = p_level
	g.position = (a + b) * 0.5
	var span := b - a
	span.y = 0
	g.rotation.y = atan2(span.x, span.z)
	var length := span.length()
	var top: float = heights.max() + 0.25
	for end in [-1.0, 1.0]:
		var post := MeshInstance3D.new()
		var pm := BoxMesh.new()
		pm.size = Vector3(0.12, top, 0.12)
		pm.material = Kit.flat(Color(0.25, 0.26, 0.3))
		post.mesh = pm
		post.position = Vector3(0, top * 0.5, end * (length * 0.5 + 0.06))
		g.add_child(post)
	var glow := StandardMaterial3D.new()
	glow.albedo_color = BEAM_COLOR
	glow.emission_enabled = true
	glow.emission = BEAM_COLOR
	glow.emission_energy_multiplier = 3.0
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for h in heights:
		var beam := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.008
		cm.bottom_radius = 0.008
		cm.height = length
		cm.material = glow
		beam.mesh = cm
		beam.rotation.x = PI * 0.5
		beam.position = Vector3(0, h, 0)
		g.add_child(beam)
		g._beams.append(beam)
		var area := Area3D.new()
		area.collision_layer = 0
		area.collision_mask = Kit.LAYER_WORLD | Kit.LAYER_PEOPLE | 0xFFFF
		var cs := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(0.06, 0.06, length)
		cs.shape = box
		area.position = Vector3(0, h, 0)
		area.add_child(cs)
		area.body_entered.connect(g._on_body_entered)
		g.add_child(area)
		g._areas.append(area)
	return g


func _ready() -> void:
	add_to_group("powered")
	add_to_group("lasers")
	_hum = Sfx.on(self, "laser_hum_loop", -22.0)
	_update()


func set_powered(on: bool) -> void:
	powered = on
	_update()


func set_switched_on(on: bool) -> void:
	switched_on = on
	_update()


func is_on() -> bool:
	if not (powered and switched_on):
		return false
	return period <= 0.0 or fmod(_t, period) < period * 0.5


func _physics_process(delta: float) -> void:
	_cool_t = maxf(0.0, _cool_t - delta)
	if period > 0.0:
		var was := is_on()
		_t += delta
		if was != is_on():
			_update()
	if not is_on():
		return
	# Someone already standing in a beam as it blinks on.
	for a in _areas:
		for b in a.get_overlapping_bodies():
			_on_body_entered(b)


func _on_body_entered(b: Node) -> void:
	if not is_on() or _cool_t > 0.0 or not b.is_in_group("moth"):
		return
	_cool_t = 3.0
	Sfx.at(self, "camera_alert", global_position + Vector3(0, 1.0, 0), -2.0)
	if JobRun.current:
		JobRun.current.record("tripped_laser")
	level.raise_alarm(b.global_position, "laser")


func _update() -> void:
	var on := is_on()
	for beam in _beams:
		beam.visible = on
	for a in _areas:
		a.monitoring = on
	if _hum:
		if on and not _hum.playing:
			_hum.play()
		elif not on:
			_hum.stop()
