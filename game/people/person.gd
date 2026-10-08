class_name Person
extends CharacterBody3D
## Someone who lives in the house. They follow a routine, and notice the
## player by sight (lit, near and in front of them) and by sound. Suspicion
## fills a meter: a little makes them come and look, a full meter means
## they've spotted you and give chase, and catching you means a firm walk
## back out of the garden.
##
## They also answer the doorbell, go and fix the fuse box when the lights go
## out, and let in the pizza delivery.

signal said(person: Person, text: String)
signal caught_player(person: Person)

enum State { ROUTINE, INVESTIGATE, SEARCH, CHASE, ANSWER_DOOR, FIX_FUSE, WAIT }

const WALK_SPEED := 1.5
const HURRY_SPEED := 2.6
const CHASE_SPEED := 4.4
const SIGHT_RANGE := 14.0
const SIGHT_HALF_ANGLE := 55.0
## Within this you're seen even in the dark.
const TOUCH_RANGE := 1.6
const CATCH_RANGE := 1.1
const EYE_HEIGHT := 1.55
const SENSE_INTERVAL := 0.15
## Suspicion: investigating above this, spotted at 1.
const CURIOUS := 0.3
const DECAY := 0.12
const GRAVITY := 12.0

## Shown in speech, like "Ted".
var display_name := ""
var level: JobLevel
var run: JobRun
var voice := "low"
## [{at, face (Vector3), clip, time, room}] in order, looping.
var routine: Array = []
var state := State.ROUTINE
var suspicion := 0.0
var rig: RigCharacter
var agent: NavigationAgent3D
var _step := 0
var _step_time := 0.0
var _arrived := false
var _target := Vector3.ZERO
var _speed := WALK_SPEED
var _sense_t := 0.0
var _state_t := 0.0
var _last_seen := Vector3.ZERO
var _sees_player := false
var _bubble: Label3D
var _mark: Label3D
var _doors_opened: Array = []
var _spotted_this_time := false
var _search_points: Array = []
var _let_in_until := 0.0
var _nav_ready := false
## For noticing they're stuck: where they were, and how long ago.
var _stuck_at := Vector3.ZERO
var _stuck_t := 0.0
var _leg_t := 0.0


func setup(p_name: String, look: String, p_level: JobLevel, p_run: JobRun, p_routine: Array, p_voice := "low") -> void:
	display_name = p_name
	name = p_name
	level = p_level
	run = p_run
	routine = p_routine
	voice = p_voice
	collision_layer = Kit.LAYER_WORLD | Kit.LAYER_PEOPLE
	collision_mask = Kit.LAYER_WORLD
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.7
	cs.shape = cap
	cs.position = Vector3(0, 0.85, 0)
	add_child(cs)
	rig = Rigs.person(look)
	add_child(rig)
	agent = NavigationAgent3D.new()
	agent.path_desired_distance = 0.4
	agent.target_desired_distance = 0.45
	agent.radius = 0.3
	agent.height = 1.7
	agent.path_height_offset = 0.0
	add_child(agent)
	_bubble = _label3d(Vector3(0, 2.15, 0), 40)
	_mark = _label3d(Vector3(0, 2.0, 0), 96)
	_mark.text = ""
	add_to_group("hears")
	add_to_group("people")
	level.navigation_ready.connect(_on_navigation_ready)


func _on_navigation_ready() -> void:
	_nav_ready = true
	_start_step()


func _physics_process(delta: float) -> void:
	_state_t += delta
	_sense_t -= delta
	if _sense_t <= 0.0:
		_sense_t = SENSE_INTERVAL
		_look(SENSE_INTERVAL)
	if not _sees_player:
		suspicion = maxf(0.0, suspicion - DECAY * delta)
	_update_mark()
	_think(delta)
	_move(delta)
	_close_doors_behind()


## Hears a noise (see [StealthNoise]).
func hear(noise: StealthNoise) -> void:
	if noise.source == self or state == State.CHASE:
		return
	# The doorbell rings through the whole house.
	if noise.kind == "bell":
		if state in [State.ROUTINE, State.WAIT] and display_name == "Ted":
			_answer_door()
		return
	var loud := noise.loudness_at(self, global_position + Vector3(0, EYE_HEIGHT, 0))
	if loud <= 0.0:
		return
	match noise.kind:
		"bark":
			_curious(noise.position, 0.25 * loud, "Biscuit? What is it?")
			return
		"breaker":
			return
	var bump := 0.35
	match noise.kind:
		"step":
			bump = 0.4
		"door", "climb":
			bump = 0.55
		"rattle", "pry", "knock":
			bump = 1.0
		"pick":
			bump = 0.3
	_curious(noise.position, bump * loud, "")


## The power went off at the fuse box.
func lights_went_out() -> void:
	if display_name == "Ted" and state != State.CHASE:
		_say("Not again!")
		_set_state(State.FIX_FUSE)
		_go(level.points["fuse_box"], HURRY_SPEED)


func is_alert() -> bool:
	return state in [State.CHASE, State.SEARCH, State.INVESTIGATE]


# --- Senses ---------------------------------------------------------------

func _look(dt: float) -> void:
	_sees_player = false
	var p := get_tree().get_first_node_in_group("moth") as Moth
	if p == null or not run.running:
		return
	var eye := global_position + Vector3(0, EYE_HEIGHT, 0)
	var at := p.chest_position()
	var d := eye.distance_to(at)
	if d > SIGHT_RANGE:
		return
	var facing := _facing()
	var to := (at - eye)
	to.y = 0
	if d > TOUCH_RANGE and rad_to_deg(facing.angle_to(to.normalized())) > SIGHT_HALF_ANGLE:
		return
	var q := PhysicsRayQueryParameters3D.create(eye, at, Kit.LAYER_SOLID)
	q.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty() or hit.collider != p:
		return
	var near := 1.0 - d / SIGHT_RANGE
	var seen := p.visibility * (0.6 + near * 1.6)
	if d < TOUCH_RANGE:
		seen = maxf(seen, 1.5)
	elif d < 4.0:
		seen = maxf(seen, 0.35 * (1.0 - d / 4.0) + p.visibility)
	if seen < 0.08:
		return
	if _expects(p):
		return
	_sees_player = true
	_last_seen = p.global_position
	suspicion = minf(1.0, suspicion + seen * dt * 1.6)
	if suspicion >= 1.0 and state != State.CHASE:
		_spot()
	elif suspicion >= CURIOUS and state in [State.ROUTINE, State.WAIT, State.SEARCH]:
		_curious(_last_seen, 0.0, "Hm? Who's there?")
	elif state == State.INVESTIGATE:
		_go(_last_seen, HURRY_SPEED)


## Someone they're expecting isn't suspicious: the pizza delivery at the
## door, or in the hall and kitchen just after being let in.
func _expects(p: Moth) -> bool:
	if p.disguise != "pizza":
		return false
	if not level.in_house(p.global_position):
		return true
	return run.time < _let_in_until and p.global_position.y < 1.0


func _curious(at: Vector3, bump: float, line: String) -> void:
	suspicion = minf(0.99, suspicion + bump)
	if suspicion < CURIOUS and bump > 0.0:
		return
	if state in [State.ANSWER_DOOR, State.FIX_FUSE, State.CHASE]:
		return
	if state != State.INVESTIGATE:
		rig.play_once("startled")
		_say(line if line != "" else _pick(["Hm?", "What was that?", "Hello?"]))
		run.record("noticed")
	_set_state(State.INVESTIGATE)
	_go(at, HURRY_SPEED)


func _spot() -> void:
	_set_state(State.CHASE)
	if not _spotted_this_time:
		_spotted_this_time = true
		run.add_spotted()
		Sfx.at(self, "spotted", global_position + Vector3(0, 1.8, 0), -2.0)
	_say(_pick(["Hey! You!", "Oi! Stop right there!", "Burglar!"]))
	for o in get_tree().get_nodes_in_group("people"):
		if o != self and o.global_position.distance_to(global_position) < 12.0:
			o._curious(global_position, 0.6, "What's going on?")


# --- Decisions ----------------------------------------------------------------

func _think(delta: float) -> void:
	match state:
		State.ROUTINE:
			if _arrived:
				_step_time -= delta
				if _step_time <= 0.0:
					var s: Dictionary = routine[_step]
					if s.get("leave_dark", false):
						level.set_lights(s.get("room", ""), false)
					_step = (_step + 1) % routine.size()
					_start_step()
		State.INVESTIGATE:
			if _arrived:
				rig.play("look-around")
				if _state_t > 4.0:
					_begin_search()
		State.SEARCH:
			if _arrived:
				rig.play("look-around")
				if _state_t > 2.5:
					if _search_points.is_empty():
						_give_up()
					else:
						_state_t = 0.0
						_go(_search_points.pop_back(), WALK_SPEED)
		State.CHASE:
			var p := get_tree().get_first_node_in_group("moth") as Moth
			if p == null:
				return
			if _sees_player:
				_go(p.global_position, CHASE_SPEED)
				_state_t = 0.0
			elif _state_t > 3.0 or _arrived:
				_say(_pick(["Where did they go?", "I know you're here!"]))
				_spotted_this_time = false
				_begin_search()
			var gap := p.global_position - global_position
			if Vector2(gap.x, gap.z).length() < CATCH_RANGE + 0.3 and absf(gap.y) < 1.8:
				_catch(p)
		State.ANSWER_DOOR:
			_answering(delta)
		State.FIX_FUSE:
			if _arrived:
				if _state_t > 3.0:
					var m := level as MapleCloseLevel
					if m and m.power_off():
						m.set_power(true)
						_say("There. Light!")
					_resume_routine()
		State.WAIT:
			if _state_t > _step_time:
				_resume_routine()


func _begin_search() -> void:
	_set_state(State.SEARCH)
	_search_points = []
	for i in 3:
		var off := Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
		_search_points.append(_last_seen + off)
	_go(_last_seen, WALK_SPEED)


func _give_up() -> void:
	_say(_pick(["Must be the wind.", "Just the house settling.", "I'm hearing things."]))
	run.record("lost_them")
	Sfx.at(self, "lost_them", global_position + Vector3(0, 1.8, 0), -10.0)
	suspicion = minf(suspicion, 0.2)
	_resume_routine()


func _resume_routine() -> void:
	_set_state(State.ROUTINE)
	_start_step()


func _catch(p: Moth) -> void:
	_set_state(State.WAIT)
	_step_time = 2.0
	suspicion = 0.0
	_spotted_this_time = false
	_say("Got you! Out you go.")
	caught_player.emit(self)


func _start_step() -> void:
	if routine.is_empty() or not _nav_ready:
		return
	var s: Dictionary = routine[_step]
	_step_time = float(s.get("time", 10.0))
	_go(level.points[s.at], WALK_SPEED)


## Arrived at a routine step: face the right way, play its clip, switch on
## its room's light.
func _arrive_step() -> void:
	var s: Dictionary = routine[_step]
	if s.has("face"):
		rig.rotation.y = atan2(s.face.x, s.face.z)
	# Sitting: the rig settles onto the seat, a little off the walkable floor.
	rig.position = s.get("sit", Vector3.ZERO)
	rig.play(s.get("clip", "idle"))
	var room: String = s.get("room", "")
	var m := level as MapleCloseLevel
	if room != "" and not (m and m.power_off()):
		level.set_lights(room, true)
	if s.has("say"):
		_say(s.say)


# --- The doorbell ---------------------------------------------------------------

func _answer_door() -> void:
	_say(_pick(["Coming!", "Who's that at this hour?"]))
	_set_state(State.ANSWER_DOOR)
	_go(level.points["front_door_in"], HURRY_SPEED)


func _answering(_delta: float) -> void:
	if not _arrived:
		return
	var door: HouseDoor = level.doors.get("front_door")
	if door and not door.is_open:
		door.locked = false
		door.person_open(self)
		_state_t = 0.0
		_face(Vector3(0, 0, 1))
		return
	var p := get_tree().get_first_node_in_group("moth") as Moth
	var at_door := p != null and p.global_position.distance_to(level.points["front_step"]) < 3.0
	if at_door and p.disguise == "pizza" and p.has_item("pizza") and _state_t > 1.0:
		p.take_item("pizza")
		_say("Pizza! Come in, come in, I'll find my wallet.")
		run.record("let_in_as_pizza")
		_let_in_until = run.time + 45.0
		_set_state(State.WAIT)
		_step_time = 18.0
		_go(level.points["kitchen"], WALK_SPEED)
		return
	if at_door and p.disguise == "pizza" and _state_t > 1.0:
		_say("Where's the pizza, then?")
		_state_t = -2.0
	elif _state_t > 4.0:
		_say(_pick(["Hello? ...Kids.", "Nobody there. Odd."]))
		if door:
			door.person_close(self)
			door.locked = true
		_resume_routine()


# --- Moving ----------------------------------------------------------------------

func _go(at: Vector3, speed: float) -> void:
	rig.position = Vector3.ZERO
	_leg_t = 0.0
	_stuck_t = 0.0
	_stuck_at = global_position
	_target = at
	_speed = speed
	_arrived = false
	if _nav_ready:
		agent.target_position = at


func _move(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	var flat := Vector3.ZERO
	if not _arrived and _nav_ready:
		if agent.is_navigation_finished():
			_on_arrived()
		else:
			var next := agent.get_next_path_position()
			var dir := next - global_position
			dir.y = 0
			if dir.length() > 0.05:
				flat = dir.normalized() * _speed
				_open_doors_ahead(dir.normalized())
	velocity.x = flat.x
	velocity.z = flat.z
	move_and_slide()
	if flat.length() > 0.1:
		# Stuck (or the place can't be reached): call it arrived.
		_leg_t += delta
		_stuck_t += delta
		if _stuck_t > 1.5:
			if global_position.distance_to(_stuck_at) < 0.3 or _leg_t > 30.0:
				_on_arrived()
			_stuck_t = 0.0
			_stuck_at = global_position
		_face(flat)
		rig.play("sprint" if _speed > 3.0 else "walk", 0.15, clampf(_speed / 2.0, 0.7, 1.3))
	elif not _arrived:
		rig.play("idle")


func _on_arrived() -> void:
	_arrived = true
	_state_t = 0.0
	if state == State.ROUTINE:
		_arrive_step()
	else:
		rig.play("idle")


func _face(dir: Vector3) -> void:
	dir.y = 0
	if dir.length() < 0.01:
		return
	var want := atan2(dir.x, dir.z)
	rig.rotation.y = lerp_angle(rig.rotation.y, want, 0.25)


## The way they're looking (the rig's front is +Z).
func _facing() -> Vector3:
	return Vector3(sin(rig.rotation.y), 0, cos(rig.rotation.y))


func _open_doors_ahead(dir: Vector3) -> void:
	for d in level.doors.values():
		if d.is_open:
			continue
		var c := _door_center(d)
		var to: Vector3 = c - global_position
		to.y = 0
		if absf(c.y - global_position.y - 1.0) > 1.2:
			continue
		if to.length() < 1.4 and to.normalized().dot(dir) > 0.3:
			d.locked = false
			d.person_open(self)
			if not d in _doors_opened:
				_doors_opened.append(d)


## Closes doors they opened once they're through, as tidy people do.
func _close_doors_behind() -> void:
	for d in _doors_opened.duplicate():
		if global_position.distance_to(_door_center(d)) > 2.2:
			if d.id != "front_door":
				d.person_close(self)
			_doors_opened.erase(d)


static func _door_center(d: HouseDoor) -> Vector3:
	return d.global_position + Basis(Vector3.UP, d.closed_yaw) * Vector3(0, 1.0, HouseDoor.WIDTH * 0.5)


# --- Showing what they think -------------------------------------------------------

func _set_state(s: State) -> void:
	state = s
	_state_t = 0.0


func _say(text: String) -> void:
	if text == "":
		return
	_bubble.text = text
	_bubble.modulate.a = 1.0
	var t := _bubble.create_tween()
	t.tween_interval(2.5)
	t.tween_property(_bubble, "modulate:a", 0.0, 0.5)
	var line := Sfx.voice_line(voice, text)
	if line != "":
		Sfx.at(self, line, global_position + Vector3(0, 1.6, 0), -2.0)
	else:
		Sfx.at(self, "mumble_%s_%d" % [voice, randi_range(1, 3)], global_position + Vector3(0, 1.6, 0), -6.0)
	said.emit(self, text)


func _update_mark() -> void:
	if state == State.CHASE:
		_mark.text = "!"
		_mark.modulate = Color(1.0, 0.25, 0.2)
	elif suspicion > 0.05:
		_mark.text = "?"
		_mark.modulate = Color(1.0, 0.85, 0.3, clampf(suspicion * 2.0, 0.3, 1.0))
	else:
		_mark.text = ""


func _label3d(pos: Vector3, font_size: int) -> Label3D:
	var l := Label3D.new()
	l.position = pos
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.font_size = font_size
	l.pixel_size = 0.004
	l.outline_size = 12
	l.no_depth_test = true
	l.fixed_size = false
	add_child(l)
	return l


static func _pick(lines: Array) -> String:
	return lines[randi() % lines.size()]
