class_name Dog
extends CharacterBody3D
## Biscuit. Sleeps in his bed until noise adds up and wakes him; awake, he
## barks at the player when he sees them (which brings people), and he can't
## resist a treat on the floor. A fed dog is a friend: he follows you about
## for a while instead of barking.

enum State { SLEEP, AWAKE, BARK, TREAT, FRIEND }

const WALK_SPEED := 1.8
const RUN_SPEED := 3.5
## Noise needed to wake him (loudness adds up, and drains while it's quiet).
const WAKE_AT := 1.0
const DROWSE := 0.08
const SIGHT := 7.0
const SMELL := 9.0
const BARK_EVERY := 0.9
const BARK_RADIUS := 18.0
const GRAVITY := 12.0

var level: JobLevel
var run: JobRun
var state := State.SLEEP
var drowsy := 0.0
var rig: RigCharacter
var agent: NavigationAgent3D
var _bed := Vector3.ZERO
var _state_t := 0.0
var _bark_t := 0.0
var _treat: Node3D
var _snore: AudioStreamPlayer3D
var _nav_ready := false
var _target := Vector3.ZERO
var _speed := WALK_SPEED
var _moving := false
var _bubble: Label3D
## A snooze dart: sound asleep, deaf to noise, for this long.
var _deep_t := 0.0


func setup(p_level: JobLevel, p_run: JobRun, bed: Vector3) -> void:
	name = "Biscuit"
	level = p_level
	run = p_run
	_bed = bed
	collision_layer = Kit.LAYER_PEOPLE
	collision_mask = Kit.LAYER_WORLD
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.4, 0.5, 0.6)
	cs.shape = box
	cs.position = Vector3(0, 0.25, 0)
	add_child(cs)
	rig = Rigs.dog()
	add_child(rig)
	agent = NavigationAgent3D.new()
	agent.radius = 0.3
	agent.path_desired_distance = 0.4
	agent.target_desired_distance = 0.6
	add_child(agent)
	_snore = Sfx.on(self, "snore_loop", -16.0)
	_bubble = Label3D.new()
	_bubble.position = Vector3(0, 1.0, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.font_size = 40
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 12
	add_child(_bubble)
	add_to_group("hears")
	level.navigation_ready.connect(_on_navigation_ready)
	rig.play("sleep")


func _on_navigation_ready() -> void:
	_nav_ready = true


func hear(noise: StealthNoise) -> void:
	if noise.source == self:
		return
	var loud := noise.loudness_at(self, global_position + Vector3(0, 0.4, 0))
	if loud <= 0.0:
		return
	if state == State.SLEEP:
		if _deep_t > 0.0:
			return
		drowsy += loud * (1.6 if noise.kind in ["bell", "rattle", "pry", "door"] else 0.9)
		if drowsy >= WAKE_AT:
			_wake()
	elif state == State.AWAKE and noise.kind != "bark":
		_go(noise.position, WALK_SPEED)


func _physics_process(delta: float) -> void:
	_state_t += delta
	_deep_t = maxf(0.0, _deep_t - delta)
	match state:
		State.SLEEP:
			drowsy = maxf(0.0, drowsy - DROWSE * delta)
			_smell_treat()
		State.AWAKE:
			if _sees_player():
				_set_state(State.BARK)
			elif _smell_treat():
				pass
			elif not _moving and _state_t > 20.0:
				_go(_bed, WALK_SPEED)
				if global_position.distance_to(_bed) < 0.8:
					_sleep()
		State.BARK:
			var p := _player()
			if p:
				_face(p.global_position - global_position)
			_bark_t -= delta
			if _bark_t <= 0.0:
				_bark_t = BARK_EVERY
				_bark()
			if _smell_treat():
				pass
			elif not _sees_player() and _state_t > 4.0:
				_set_state(State.AWAKE)
		State.TREAT:
			if not is_instance_valid(_treat):
				_set_state(State.AWAKE)
			elif global_position.distance_to(_treat.global_position) < 0.7:
				_treat.queue_free()
				Sfx.at(self, "dog_sniff", global_position, -4.0)
				run.record("fed_dog")
				_say("*munch*")
				_set_state(State.FRIEND)
			else:
				_go(_treat.global_position, RUN_SPEED)
		State.FRIEND:
			var p := _player()
			if p and global_position.distance_to(p.global_position) > 2.5:
				_go(p.global_position, WALK_SPEED)
			if _state_t > 40.0:
				_set_state(State.AWAKE)
	_move(delta)


func _wake() -> void:
	_set_state(State.AWAKE)
	_snore.stop()
	rig.play_once("wake")
	Sfx.at(self, "dog_whine", global_position, -8.0)
	run.record("dog_woke")
	_say("?")


## Hit by a snooze dart.
func snooze() -> void:
	_sleep()
	_deep_t = Person.SNOOZE_TIME
	_say("Zzz")
	run.record("snoozed")


func is_asleep() -> bool:
	return state == State.SLEEP


func _sleep() -> void:
	_set_state(State.SLEEP)
	drowsy = 0.0
	_moving = false
	rig.play("sleep")
	_snore.play()


func _bark() -> void:
	rig.play_once("bark")
	Sfx.at(self, "dog_bark_%d" % randi_range(1, 3), global_position + Vector3(0, 0.4, 0), 0.0)
	StealthNoise.make(self, global_position, BARK_RADIUS, "bark", self)
	_say("Woof!")


func _sees_player() -> bool:
	var p := _player()
	if p == null:
		return false
	var d := global_position.distance_to(p.global_position)
	var reach := SIGHT * clampf(0.35 + p.visibility * 1.5, 0.35, 1.0)
	if d > reach:
		return false
	var q := PhysicsRayQueryParameters3D.create(global_position + Vector3(0, 0.5, 0), p.chest_position(), Kit.LAYER_SOLID)
	q.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	return not hit.is_empty() and hit.collider == p


## Treats on the floor nearby pull him over (and wake him, if he's close).
func _smell_treat() -> bool:
	if _deep_t > 0.0:
		return false
	for t in get_tree().get_nodes_in_group("treats"):
		var d: float = global_position.distance_to(t.global_position)
		if d < (2.5 if state == State.SLEEP else SMELL) and absf(t.global_position.y - global_position.y) < 1.5:
			if state == State.SLEEP:
				_wake()
			_treat = t
			_set_state(State.TREAT)
			return true
	return false


func _go(at: Vector3, speed: float) -> void:
	_target = at
	_speed = speed
	_moving = true
	if _nav_ready:
		agent.target_position = at


func _move(delta: float) -> void:
	velocity.y = 0.0 if is_on_floor() else velocity.y - GRAVITY * delta
	var flat := Vector3.ZERO
	if _moving and _nav_ready and state != State.SLEEP and state != State.BARK:
		if agent.is_navigation_finished():
			_moving = false
		else:
			var dir := agent.get_next_path_position() - global_position
			dir.y = 0
			if dir.length() > 0.05:
				flat = dir.normalized() * _speed
	velocity.x = flat.x
	velocity.z = flat.z
	move_and_slide()
	if flat.length() > 0.1:
		_face(flat)
		rig.play("walk", 0.15, _speed / 1.8)
	elif state in [State.AWAKE, State.FRIEND]:
		rig.play("idle")


func _face(dir: Vector3) -> void:
	dir.y = 0
	if dir.length() > 0.01:
		rig.rotation.y = lerp_angle(rig.rotation.y, atan2(dir.x, dir.z), 0.3)


func _set_state(s: State) -> void:
	state = s
	_state_t = 0.0


func _say(text: String) -> void:
	_bubble.text = text
	_bubble.modulate.a = 1.0
	var t := _bubble.create_tween()
	t.tween_interval(1.0)
	t.tween_property(_bubble, "modulate:a", 0.0, 0.4)


func _player() -> Moth:
	return get_tree().get_first_node_in_group("moth") as Moth
