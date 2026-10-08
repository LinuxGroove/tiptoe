class_name BottlingLine
extends Node3D
## Hoard's bottling line: a conveyor belt through the washer, filler, capper
## and labeller, driven by the clock tower's cog on top of the capper. While
## it runs the belt carries whatever stands on it (bottles, noisemakers, a
## crouching burglar), the cog turns, and the machines' din drowns out
## footsteps near them ([method JobLevel.add_masking]). Stopped, the plant
## goes quiet. It can't start again without its cog.

## The line started (true) or stopped (false).
signal changed(running: bool)

## Metres a second the belt moves things west.
const BELT_SPEED := 1.1
## The conveyor model is 2 x 0.4 x 1 m; pieces are stretched to 4 m long,
## 0.8 m high and 1.2 m wide.
const BELT_SCALE := Vector3(2.0, 2.0, 1.2)
const BELT_TOP := 0.8
const BELT_WIDTH := 1.2
const BOTTLE_GAP := 1.6
## Seconds on the moving belt that count as a ride.
const RIDE_TIME := 1.5

var level: JobLevel
var running := true
## Who or what stopped it: "lever", "estop", "office", "power", "jam".
var stopped_by := ""
var has_cog := true
## West and east ends of the belt (x), and its middle line (z).
var west_x := 0.0
var east_x := 0.0
var belt_z := 0.0
## The wall the belt goes through on its way in from the dock (x).
var hatch_x := 0.0
var cog_model: Node3D
var belts: Array[StaticBody3D] = []
var _spinners: Array = []
var _hums: Array[AudioStreamPlayer3D] = []
var _bottles: Array[Node3D] = []
var _masks: Array = []
var _ride_t := 0.0
var _ride_from_x := INF


## Lays the belt from `from_x` west to `to_x` (from_x > to_x) along `z`.
func lay_belt(from_x: float, to_x: float, z: float) -> void:
	east_x = from_x
	west_x = to_x
	belt_z = z
	var x := from_x - 2.0
	while x > to_x:
		var body := StaticBody3D.new()
		body.name = "Belt"
		body.position = Vector3(x, 0, z)
		body.collision_layer = Kit.LAYER_WORLD
		body.collision_mask = 0
		var m: Node3D = Kit.scene(BottlingLevel.FACTORY + "conveyor-long-stripe-sides.glb").instantiate()
		m.scale = BELT_SCALE
		body.add_child(m)
		var cs := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(4.0, BELT_TOP, BELT_WIDTH - 0.04)
		cs.shape = shape
		cs.position = Vector3(0, BELT_TOP * 0.5, 0)
		body.add_child(cs)
		Kit.add_surface(body, "concrete")
		body.add_to_group(Kit.NAV_GROUP)
		add_child(body)
		belts.append(body)
		x -= 4.0
	# Bottles riding along, for show.
	var n := int((from_x - to_x) / BOTTLE_GAP)
	for i in n:
		var b: Node3D = Kit.scene(Kit.FOOD + "soda-bottle.glb").instantiate()
		b.scale = Vector3.ONE * 0.7
		b.position = Vector3(to_x + 0.4 + i * BOTTLE_GAP, BELT_TOP, z + (0.15 if i % 2 == 0 else -0.15))
		add_child(b)
		_bottles.append(b)
	_set_belt_speed(BELT_SPEED if running else 0.0)


## Something that turns while the line runs (`speed` radians a second about
## its own Y).
func add_spinner(node: Node3D, speed: float) -> void:
	_spinners.append([node, speed])


## A machine's running sound.
func add_hum(at: Vector3, sound: String, volume_db := -8.0) -> void:
	var holder := Node3D.new()
	holder.position = at
	add_child(holder)
	var p := Sfx.on(holder, sound, volume_db, running)
	p.max_distance = 26.0
	_hums.append(p)


## Noise near the running machines is drowned out by `amount` inside `box`.
func add_mask(box: AABB, amount: float) -> void:
	_masks.append([box, amount])
	if running and level:
		level.add_masking(box, amount)


## Starts or stops the line. It won't start with the power off, and starting
## without the cog jams it (both return false). `by` says who or what did it, for events like "line_stopped:office".
func set_running(on: bool, by := "") -> bool:
	if on == running:
		return true
	if on and level and level.power_off():
		return false
	if on and not has_cog:
		jam()
		return false
	running = on
	stopped_by = "" if on else by
	_set_belt_speed(BELT_SPEED if on else 0.0)
	for p in _hums:
		if is_instance_valid(p):
			if on:
				p.play()
			else:
				p.stop()
	if level:
		if on:
			for m in _masks:
				level.add_masking(m[0], m[1])
		else:
			level.masking = level.masking.filter(func(pair): return not _is_mask(pair[0]))
	var at := cog_model.global_position if cog_model and cog_model.is_inside_tree() else global_position
	Sfx.at(self, "line_start" if on else "line_stop", at, -2.0)
	if on:
		_record("line_started")
	else:
		_record("line_stopped")
		if by != "":
			_record("line_stopped:" + by)
	changed.emit(on)
	return true


## Tries to start without the drive cog: a grinding clunk anyone near hears.
func jam() -> void:
	var at := cog_model.global_position if cog_model and cog_model.is_inside_tree() else global_position
	Sfx.at(self, "kenney:metalLatch", at, 0.0, 0.6)
	StealthNoise.make(self, at, 8.0, "machine", self)
	_record("line_jammed")


func _is_mask(box: AABB) -> bool:
	for m in _masks:
		if m[0] == box:
			return true
	return false


func _set_belt_speed(speed: float) -> void:
	for b in belts:
		b.constant_linear_velocity = Vector3(-speed, 0, 0)


func _physics_process(delta: float) -> void:
	if not running:
		_ride_t = 0.0
		_ride_from_x = INF
		return
	for s in _spinners:
		if is_instance_valid(s[0]):
			s[0].rotate_y(s[1] * delta)
	var span := east_x - west_x
	for b in _bottles:
		b.position.x -= BELT_SPEED * delta
		if b.position.x < west_x + 0.2:
			b.position.x += span - 0.4
	_carry_player(delta)


## Carries the player along while they stand on the belt.
func _carry_player(delta: float) -> void:
	var p := get_tree().get_first_node_in_group("moth") as Moth
	if p == null or p.hiding != null or not on_belt(p.feet_position()) or not p.is_on_floor():
		_ride_t = 0.0
		_ride_from_x = INF
		return
	p.move_and_collide(Vector3(-BELT_SPEED * delta, 0, 0))
	if _ride_from_x == INF:
		_ride_from_x = p.global_position.x
	_ride_t += delta
	if _ride_t > RIDE_TIME:
		_record("rode_conveyor")
	if _ride_from_x > hatch_x + 0.5 and p.global_position.x < hatch_x - 0.8:
		_record("rode_in")


## Is `feet` standing on the belt?
func on_belt(feet: Vector3) -> bool:
	return feet.x > west_x and feet.x < east_x and absf(feet.z - belt_z) < BELT_WIDTH * 0.5 \
		and feet.y > BELT_TOP - 0.25 and feet.y < BELT_TOP + 0.4


func _record(event: String) -> void:
	if JobRun.current:
		JobRun.current.record(event)
