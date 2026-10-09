class_name Person
extends CharacterBody3D
## Someone in the building: a homeowner, a clerk, a guard, a guest. They
## follow a routine, and notice the player by sight (lit, near and in front
## of them) and by sound. Suspicion fills a meter: a little makes them come
## and look, a full meter means they've spotted you and give chase, and
## catching you means a firm walk back out.
##
## What else they do comes from their options (see [method setup]): answer
## the doorbell, fix the fuse box, come running to the alarm, carry a torch,
## and which disguises they think nothing of. A snooze dart sends anyone off
## for a nap.

signal said(person: Person, text: String)
signal caught_player(person: Person)

enum State { ROUTINE, INVESTIGATE, SEARCH, CHASE, ANSWER_DOOR, FIX_FUSE, WAIT, SNOOZE }

const WALK_SPEED := 1.5
const HURRY_SPEED := 2.6
const CHASE_SPEED := 4.4
const SIGHT_RANGE := 14.0
const SIGHT_HALF_ANGLE := 55.0
## What people say: its size on screen, and how far off it can still be read.
const BUBBLE_PIXEL := 0.0011
const BUBBLE_RANGE := 22.0
## Within this you're seen even in the dark.
const TOUCH_RANGE := 1.6
const CATCH_RANGE := 1.1
const EYE_HEIGHT := 1.55
const SENSE_INTERVAL := 0.15
## Suspicion: investigating above this, spotted at 1.
const CURIOUS := 0.3
const DECAY := 0.12
const GRAVITY := 12.0
## How long a snooze dart puts someone to sleep.
const SNOOZE_TIME := 40.0

## What people say, by moment. Options can replace any of these per person.
const LINES := {
	"curious": ["Hm?", "What was that?", "Hello?"],
	"seen": ["Hm? Who's there?"],
	"spotted": ["Hey! You!", "Oi! Stop right there!", "Burglar!"],
	"others": ["What's going on?"],
	"lost": ["Where did they go?", "I know you're here!"],
	"give_up": ["Must be the wind.", "Just the house settling.", "I'm hearing things."],
	"catch": ["Got you! Out you go."],
	"door": ["Coming!", "Who's that at this hour?"],
	"door_nobody": ["Hello? ...Kids.", "Nobody there. Odd."],
	"power_out": ["Not again!"],
	"power_fixed": ["There. Light!"],
	"alarm": ["The alarm!", "Someone's in here!"],
	"bark": ["What's that dog barking at?"],
	"wake": ["Wha...? Must have dozed off."],
}

## Shown in speech, like "Ted".
var display_name := ""
var level: JobLevel
var run: JobRun
## Their recorded voice (assets/audio/voice/<voice>), and the mumble used
## when a line isn't recorded ("low" or "high").
var voice := "low"
var mumble := "low"
## Disguises they think nothing of (see [method JobLevel.expects]).
var accepts: Array = []
var answers_door := false
var fixes_power := false
var answers_alarm := false
## Lines they say instead of the usual ones: moment -> [lines].
var lines := {}
## Lines a level makes them say (recorded with the rest).
var extra_lines: Array = []
var sight_range := SIGHT_RANGE
var torch: SpotLight3D
## [{at, face (Vector3), clip, time, room, say, leave_dark, sit}] in order,
## looping. `at` is one of the level's points.
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
var _bubble_tween: Tween
var _mark: Label3D
var _doors_opened: Array = []
var _spotted_this_time := false
var _search_points: Array = []
var _nav_ready := false
## For noticing they're stuck: where they were, and how long ago.
var _stuck_at := Vector3.ZERO
var _stuck_t := 0.0
var _leg_t := 0.0
## They watched the player duck into a hiding spot.
var _saw_hide := false
var _snooze_t := 0.0


## `opts` (all optional):
##   mumble: "low" or "high" (else "high" for the "high" voice, "low" otherwise)
##   accepts: [disguises]; answers_door, fixes_power, answers_alarm: bool
##   torch: bool, a torch that lights up whoever it points at
##   sight: metres they can see; lines: {moment: [lines]}; extra_lines: [lines]
func setup(p_name: String, look: String, p_level: JobLevel, p_run: JobRun, p_routine: Array, p_voice := "low", opts := {}) -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	display_name = p_name
	name = p_name
	level = p_level
	run = p_run
	routine = p_routine
	voice = p_voice
	mumble = opts.get("mumble", "high" if p_voice == "high" else "low")
	accepts = opts.get("accepts", [])
	answers_door = opts.get("answers_door", false)
	fixes_power = opts.get("fixes_power", false)
	answers_alarm = opts.get("answers_alarm", false)
	lines = opts.get("lines", {})
	extra_lines = opts.get("extra_lines", [])
	sight_range = opts.get("sight", SIGHT_RANGE)
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
	_bubble = _label3d(Vector3(0, 2.2, 0), 48)
	# What they say stays the same size on screen however far off they are,
	# in the game's font, and fades out past earshot.
	_bubble.fixed_size = true
	_bubble.pixel_size = BUBBLE_PIXEL
	_bubble.font = LGTheme.body_font
	_bubble.modulate = LGTheme.PARCHMENT
	_bubble.outline_modulate = Color(0.12, 0.08, 0.05, 0.95)
	_bubble.outline_size = 18
	_bubble.width = 900
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.visibility_range_end = BUBBLE_RANGE
	_mark = _label3d(Vector3(0, 2.0, 0), 96)
	_mark.text = ""
	add_to_group("hears")
	add_to_group("people")
	level.navigation_ready.connect(_on_navigation_ready)
	if opts.get("torch", false):
		torch = SpotLight3D.new()
		torch.name = "Torch"
		torch.position = Vector3(0.15, 1.45, 0.25)
		# The rig's front is +Z; a spotlight shines down its own -Z.
		torch.rotation = Vector3(deg_to_rad(-8), PI, 0)
		torch.spot_range = 9.0
		torch.spot_angle = 22.0
		torch.light_energy = 1.6
		torch.light_color = Color(1.0, 0.95, 0.8)
		torch.shadow_enabled = true
		torch.add_to_group("stealth_lights")
		rig.add_child(torch)


## Everything this person might say, for recording their voice.
func all_lines() -> PackedStringArray:
	var out := PackedStringArray()
	var skip := []
	if not answers_door:
		skip += ["door", "door_nobody"]
	if not fixes_power:
		skip += ["power_out", "power_fixed"]
	if not answers_alarm:
		skip += ["alarm"]
	for moment in LINES:
		if moment in skip:
			continue
		for l in lines.get(moment, LINES[moment]):
			if not l in out:
				out.append(l)
	for s in routine:
		if s.has("say") and not s.say in out:
			out.append(s.say)
	for l in extra_lines:
		if not l in out:
			out.append(l)
	return out


func _on_navigation_ready() -> void:
	_nav_ready = true
	if state == State.ROUTINE:
		_start_step()


func _ready() -> void:
	reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	_state_t += delta
	_sense_t -= delta
	if state == State.SNOOZE:
		_snooze_t -= delta
		if _snooze_t <= 0.0:
			_wake()
		_move(delta)
		return
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
	if noise.source == self or state in [State.CHASE, State.SNOOZE]:
		return
	# The doorbell rings through the whole house.
	if noise.kind == "bell":
		if state in [State.ROUTINE, State.WAIT] and answers_door:
			_answer_door()
		return
	var loud := noise.loudness_at(self, global_position + Vector3(0, EYE_HEIGHT, 0))
	if loud <= 0.0:
		return
	match noise.kind:
		"bark":
			_curious(noise.position, 0.25 * loud, line("bark"))
			return
		"breaker", "alarm", "machine":
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
	if fixes_power and state not in [State.CHASE, State.SNOOZE] and level.points.has("fuse_box"):
		say(line("power_out"))
		_set_state(State.FIX_FUSE)
		_go(level.points["fuse_box"], HURRY_SPEED)


## The alarm went off at `at`.
func on_alarm(at: Vector3) -> void:
	if not answers_alarm or state in [State.CHASE, State.SNOOZE, State.FIX_FUSE]:
		return
	if state != State.INVESTIGATE:
		say(line("alarm"))
		rig.play_once("startled")
	suspicion = maxf(suspicion, 0.9)
	_last_seen = at
	_set_state(State.INVESTIGATE)
	_go(at, HURRY_SPEED)


## Hit by a snooze dart: asleep on the spot for a while.
func snooze() -> void:
	if state == State.SNOOZE:
		return
	_set_state(State.SNOOZE)
	_snooze_t = SNOOZE_TIME
	_arrived = true
	suspicion = 0.0
	_saw_hide = false
	_spotted_this_time = false
	rig.play("sleep")
	_mark.text = ""
	_bubble.text = "Zzz"
	_show_bubble()
	Sfx.at(self, "snooze", global_position + Vector3(0, 1.4, 0), -4.0)
	run.record("snoozed")


func is_asleep() -> bool:
	return state == State.SNOOZE


## The player ducked into a hiding spot: if they saw it, they know where.
func on_player_hid(_spot: Node3D) -> void:
	_saw_hide = _sees_player and state == State.CHASE


func _wake() -> void:
	_bubble.text = ""
	say(line("wake"))
	_resume_routine()


func is_alert() -> bool:
	return state in [State.CHASE, State.SEARCH, State.INVESTIGATE]


## A line for a moment ("curious", "spotted"...), theirs or the usual.
func line(moment: String) -> String:
	return _pick(lines.get(moment, LINES.get(moment, [""])))


# --- Senses ---------------------------------------------------------------

func _look(dt: float) -> void:
	_sees_player = false
	var p := get_tree().get_first_node_in_group("moth") as Moth
	if p == null or not run.running:
		return
	var eye := global_position + Vector3(0, EYE_HEIGHT, 0)
	var at := p.chest_position()
	var d := eye.distance_to(at)
	if p.hiding != null:
		# Hidden: unseen, unless they watched them go in.
		if _saw_hide and state == State.CHASE:
			_sees_player = true
			_last_seen = p.global_position
		return
	if d > sight_range:
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
	var near := 1.0 - d / sight_range
	var seen := p.visibility * (0.6 + near * 1.6)
	if d < TOUCH_RANGE:
		seen = maxf(seen, 1.5)
	elif d < 4.0:
		seen = maxf(seen, 0.35 * (1.0 - d / 4.0) + p.visibility)
	if seen < 0.08:
		return
	if level.expects(self, p):
		return
	_sees_player = true
	_last_seen = p.global_position
	suspicion = minf(1.0, suspicion + seen * dt * 1.6)
	if suspicion >= 1.0 and state != State.CHASE:
		_spot()
	elif suspicion >= CURIOUS and state in [State.ROUTINE, State.WAIT, State.SEARCH]:
		_curious(_last_seen, 0.0, line("seen"))
	elif state == State.INVESTIGATE:
		_go(_last_seen, HURRY_SPEED)


func _curious(at: Vector3, bump: float, said_line: String) -> void:
	suspicion = minf(0.99, suspicion + bump)
	if suspicion < CURIOUS and bump > 0.0:
		return
	if state in [State.ANSWER_DOOR, State.FIX_FUSE, State.CHASE, State.SNOOZE]:
		return
	if state != State.INVESTIGATE:
		rig.play_once("startled")
		say(said_line if said_line != "" else line("curious"))
		run.record("noticed")
	_set_state(State.INVESTIGATE)
	_go(at, HURRY_SPEED)


func _spot() -> void:
	_set_state(State.CHASE)
	if not _spotted_this_time:
		_spotted_this_time = true
		run.add_spotted()
		Sfx.at(self, "spotted", global_position + Vector3(0, 1.8, 0), -2.0)
	say(line("spotted"))
	for o in get_tree().get_nodes_in_group("people"):
		if o != self and o.global_position.distance_to(global_position) < 12.0 and not o.is_asleep():
			o._curious(global_position, 0.6, o.line("others"))


# --- Decisions ----------------------------------------------------------------

func _think(delta: float) -> void:
	match state:
		State.ROUTINE:
			if _arrived and not routine.is_empty():
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
				say(line("lost"))
				_spotted_this_time = false
				_saw_hide = false
				_begin_search()
			var gap := p.global_position - global_position
			if Vector2(gap.x, gap.z).length() < CATCH_RANGE + 0.3 and absf(gap.y) < 1.8:
				_catch(p)
		State.ANSWER_DOOR:
			_answering(delta)
		State.FIX_FUSE:
			if _arrived:
				if _state_t > 3.0:
					if level.power_off():
						level.set_power(true)
						say(line("power_fixed"))
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
	say(line("give_up"))
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
	_saw_hide = false
	say(line("catch"))
	if p.hiding != null:
		p.leave_hiding()
	caught_player.emit(self)


func _start_step() -> void:
	if not _nav_ready:
		return
	if routine.is_empty():
		_arrived = true
		rig.play("idle")
		return
	var s: Dictionary = routine[_step]
	_step_time = float(s.get("time", 10.0))
	_go(level.points[s.at], WALK_SPEED)


## Arrived at a routine step: face the right way, play its clip, switch on
## its room's light.
func _arrive_step() -> void:
	if routine.is_empty():
		return
	var s: Dictionary = routine[_step]
	if s.has("face"):
		rig.rotation.y = atan2(s.face.x, s.face.z)
	# Sitting: the rig settles onto the seat, a little off the walkable floor.
	rig.position = s.get("sit", Vector3.ZERO)
	rig.play(s.get("clip", "idle"))
	var room: String = s.get("room", "")
	if room != "" and not level.power_off():
		level.set_lights(room, true)
	if s.has("say"):
		say(s.say)


# --- The doorbell ---------------------------------------------------------------

## Goes to the front door (the level's "front_door_in" point and its door
## "front_door"). Who's on the step is up to [method JobLevel.at_front_door].
func _answer_door() -> void:
	if not level.points.has("front_door_in"):
		return
	say(line("door"))
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
	var at_door := p != null and level.points.has("front_step") and p.global_position.distance_to(level.points["front_step"]) < 3.0
	if at_door and _state_t > 1.0 and level.at_front_door(self, p):
		return
	if _state_t > 4.0:
		say(line("door_nobody"))
		if door:
			door.person_close(self)
			door.locked = true
		_resume_routine()


## Stops what they're doing and waits `seconds` at a point of the level.
func wait_at(point: String, seconds: float) -> void:
	_set_state(State.WAIT)
	_step_time = seconds
	_go(level.points[point], WALK_SPEED)


## Keeps them where they are a little longer (answering the door).
func hold(seconds: float) -> void:
	_state_t = -seconds


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
	if not _arrived and _nav_ready and state != State.SNOOZE:
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
	if not _arrived and _nav_ready and state != State.SNOOZE:
		# Stuck, standing on a path that goes nowhere, or the place can't be
		# reached: call it arrived.
		_leg_t += delta
		_stuck_t += delta
		if _stuck_t > 1.5:
			if global_position.distance_to(_stuck_at) < 0.3 or _leg_t > 30.0:
				_on_arrived()
			_stuck_t = 0.0
			_stuck_at = global_position
	if flat.length() > 0.1:
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
		if d.is_open or not d.people_open:
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


func say(text: String) -> void:
	if text == "":
		return
	_bubble.text = text
	_show_bubble()
	_bubble_tween = _bubble.create_tween()
	# Longer lines stay up longer, so they can be read.
	_bubble_tween.tween_interval(2.5 + text.length() * 0.03)
	# Transparency fades the text and its outline together.
	_bubble_tween.tween_property(_bubble, "transparency", 1.0, 0.5)
	var recorded := Sfx.voice_line(voice, text)
	if recorded != "":
		Sfx.at(self, recorded, global_position + Vector3(0, 1.6, 0), -2.0)
	else:
		Sfx.at(self, "mumble_%s_%d" % [mumble, randi_range(1, 3)], global_position + Vector3(0, 1.6, 0), -6.0)
	said.emit(self, text)


## Shows a line over their head and leaves it there, silently (for
## screenshots; [method say] is the real thing).
func show_line(text: String) -> void:
	_show_bubble()
	_bubble.text = text


## Puts away whatever they were saying or thinking.
func hush() -> void:
	_show_bubble()
	_bubble.text = ""
	_mark.text = ""


## The first thing their routine has them say, or "".
func first_line() -> String:
	for step in routine:
		if step.get("say", "") != "":
			return step.say
	return ""


func _show_bubble() -> void:
	if _bubble_tween:
		_bubble_tween.kill()
	_bubble.transparency = 0.0


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


static func _pick(lines_: Array) -> String:
	return lines_[randi() % lines_.size()]
