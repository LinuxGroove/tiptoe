extends Node
## Headless tests: run with
##   godot --headless --path . tests/run_tests.tscn
## Add `-- --games=N` to also play N scripted nights against the people's
## AI (default 1), or `-- --job=<id>` to test only one job after Maple Close.
## Exits non-zero on failure.

## A job's own tests: game/jobs/<id>/<id>_tests.gd, a RefCounted whose
## run(t, games) uses this runner's check(), _until(), _make_job() and so on.
const JOB_TESTS := "res://game/jobs/%s/%s_tests.gd"

var failures := 0
var checks := 0


func _ready() -> void:
	var games := 1
	var only := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--games="):
			games = maxi(1, arg.substr(8).to_int())
		elif arg.begins_with("--job="):
			only = arg.substr(6)
	LGSettings.register_defaults(GameConfig.SETTING_DEFAULTS)
	LGTheme.apply(get_tree().root)
	LGInput.register_actions(GameConfig.ACTIONS)
	LGInput.extend_ui_actions()
	Progress.in_memory = true
	Progress.load_progress()
	if only != "":
		await _test_jobs([only], games)
		print("\n%d checks, %d failed" % [checks, failures])
		get_tree().quit(1 if failures > 0 else 0)
		return
	printerr("- _test_job_data")
	_test_job_data()
	printerr("- _test_run_capers")
	_test_run_capers()
	printerr("- _test_run_leads")
	_test_run_leads()
	printerr("- _test_run_score")
	_test_run_score()
	printerr("- _test_progress")
	_test_progress()
	printerr("- _test_noise")
	_test_noise()
	printerr("- _test_audio_manifest")
	_test_audio_manifest()
	printerr("- _test_title_menu")
	await _test_title_menu()
	printerr("- _test_systems")
	await _test_systems()
	printerr("- _test_level")
	await _test_level()
	for i in games:
		printerr("- _test_night %d" % (i + 1))
		await _test_night()
	await _test_jobs(Jobs.ids(), games)
	print("\n%d checks, %d failed" % [checks, failures])
	get_tree().quit(1 if failures > 0 else 0)


func check(ok: bool, what: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", what)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _physics(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


## Waits up to `seconds` of game time for `cond` to become true.
func _until(cond: Callable, seconds: float) -> bool:
	var steps := int(seconds * Engine.physics_ticks_per_second / Engine.time_scale)
	for i in steps:
		if cond.call():
			return true
		await get_tree().physics_frame
	return cond.call()


func _test_job_data() -> void:
	var job := Jobs.get_job("maple_close")
	check(job != null, "Maple Close exists")
	check(job.capers.size() == 12, "Maple Close has 12 capers")
	check(job.leads.size() == 2, "Maple Close has 2 leads")
	var ids := {}
	for c in job.capers:
		ids[c.id] = true
	check(ids.size() == job.capers.size(), "caper ids are unique")
	check(job.open_start_points(0).size() == 1, "one start point at mastery 0")
	check(job.open_start_points(5).size() == 3, "every start point at mastery 5")
	check(job.open_gadgets(0).size() == 3 and job.open_gadgets(2).size() == 5, "gadgets unlock with mastery")
	check(Jobs.all().size() == 7 and Jobs.all()[0].id == "maple_close", "the job board lists all seven jobs in story order")


func _new_run() -> JobRun:
	var run := JobRun.new()
	add_child(run)
	run.setup(Jobs.get_job("maple_close"))
	return run


func _test_run_capers() -> void:
	var run := _new_run()
	var done := []
	run.caper_done.connect(func(c): done.append(c.id))
	run.record("read:shopping_list")
	check("shopping_list" in done, "reading the list finishes its caper")
	run.record("entered_by:back_door")
	check(not "bell_then_back" in done, "back door without the bell isn't the caper")
	run.record("used_key")
	run.record("entered_house")
	check(not "no_key" in done, "entering after using a key isn't 'no key'")
	run.record("took_treasure")
	run.record("cupcake_on_stand")
	check("cupcake_swap" in done, "cupcake after the trophy is the swap caper")
	run.record("read:shopping_list")
	check(done.count("shopping_list") == 1, "capers finish once")
	var res := run.escape("window")
	check(res.escaped and res.treasure, "escaping with the trophy counts")
	check("no_door" in done and "ghost" in done and "tidy" in done and "dog_asleep" in done, "escape capers finish at the end")
	run.queue_free()
	var run2 := _new_run()
	var done2 := []
	run2.caper_done.connect(func(c): done2.append(c.id))
	run2.record("doorbell_rung")
	run2.record("entered_by:back_door")
	run2.record("entered_house")
	check("bell_then_back" in done2 and "no_key" in done2, "bell then back door, and no key")
	run2.record("dog_woke")
	run2.record("took_treasure")
	run2.add_spotted()
	run2.escape("door")
	check(not "dog_asleep" in done2 and not "ghost" in done2 and not "no_door" in done2, "waking the dog, being seen and using a door rule capers out")
	run2.queue_free()


func _test_run_leads() -> void:
	var run := _new_run()
	var steps := []
	run.lead_step.connect(func(l, t): steps.append([l.id, t]))
	run.record("got_pizza_cap")
	check(steps.is_empty(), "lead steps don't show before the lead is found")
	run.record("read:pizza_flyer")
	var lead := run.job.lead("pizza_night")
	check(run.lead_steps.has("pizza_night"), "reading the flyer finds the lead")
	check(run.lead_text(lead) == lead.steps[1][0], "a step done before finding the lead is skipped")
	var n := steps.size()
	run.record("something_else")
	check(steps.size() == n, "unrelated events don't repeat the lead step")
	run.queue_free()


func _test_run_score() -> void:
	var run := _new_run()
	run.time = 100.0
	run.record("took_treasure")
	var res := run.escape("door")
	check(res.score >= JobRun.TREASURE_POINTS + JobRun.GHOST_POINTS, "a clean escape scores the treasure and ghost")
	check("Ghost" in res.ratings and "Quick" in res.ratings, "ratings for ghost and quick")
	run.queue_free()
	var run2 := _new_run()
	run2.add_caught()
	var res2 := run2.finish()
	check(not res2.treasure and res2.score == 0, "giving up after being caught scores nothing")
	run2.queue_free()


func _test_progress() -> void:
	Progress.reset()
	var u := Progress.record_run("maple_close", {"capers": ["a", "b", "c", "d"], "escaped": true, "treasure": true, "time": 200.0, "score": 900})
	check(u.mastery_from == 0 and u.mastery_to == 2, "four capers is mastery 2")
	check(Progress.best_score("maple_close") == 900 and is_equal_approx(Progress.best_time("maple_close"), 200.0), "best score and time kept")
	u = Progress.record_run("maple_close", {"capers": ["a"], "escaped": false, "score": 100})
	check(u.capers.is_empty() and Progress.best_score("maple_close") == 900, "repeat capers and a worse score change nothing")
	check(Progress.runs("maple_close") == 2 and Progress.treasures("maple_close") == 1, "runs and treasures counted")
	Progress.reset()


func _test_noise() -> void:
	check(StealthNoise.step_radius("carpet", false, false) < StealthNoise.step_radius("wood", false, false), "carpet is quieter than wood")
	check(StealthNoise.step_radius("wood", true, false) < StealthNoise.step_radius("wood", false, false), "crouching is quieter")
	check(StealthNoise.step_radius("wood", false, true) > StealthNoise.step_radius("wood", false, false), "sprinting is louder")


## tools/lemonade/audio.json names voice files the way the game looks them up.
func _test_audio_manifest() -> void:
	check(Sfx.slug("Oi! Stop right there!") == "oi_stop_right_there", "lines get plain file names")
	check(Sfx.slug("Hello? ...Kids.") == "hello_kids", "punctuation runs become one underscore")
	var m = JSON.parse_string(FileAccess.get_file_as_string("res://tools/lemonade/audio.json"))
	check(m is Dictionary, "the audio manifest reads")
	if not m is Dictionary:
		return
	var bad := []
	for v in m.voices.voices:
		for l in m.voices.voices[v].lines:
			if l.file != "assets/audio/voice/%s/%s.ogg" % [v, Sfx.slug(l.text)]:
				bad.append(l.file)
	check(bad.is_empty(), "voice files match their lines %s" % [bad])
	check(Sfx.voice_line("nobody", "Hello?") == "", "people without a recorded line mumble")
	check(Sfx.voice_line("low", "Burglar!") != "" and Sfx.voice_line("high", "Burglar!") != "", "Ted and Maggie have recorded lines")
	for track in ["title", "night", "chase", "escaped", "night_over"]:
		check(Sfx.music(track, "") != "", "the %s music is ours" % track)


func _test_title_menu() -> void:
	check(not Jobs.is_open("market"), "the corner market waits for the trophy")
	Progress.record_run("maple_close", {"capers": [], "escaped": true, "treasure": true, "score": 100})
	var title: Node = load("res://game/ui/title.tscn").instantiate()
	add_child(title)
	await _frames(2)
	check(title.bakery.shown.has("maple_close") and not title.bakery.shown.has("market"), "the trophy is back in the bakery window")
	check(Jobs.is_open("maple_close") and Jobs.is_open("market") and not Jobs.is_open("bottling"), "jobs open in story order")
	var board := _find_button(title, "Job board")
	check(board != null, "title has the job board")
	if board:
		board.pressed.emit()
		await _frames(1)
		check(_find_button(title, "Maple Close") != null, "the job board lists Maple Close")
		_find_button(title, "Maple Close").pressed.emit()
		await _frames(1)
		check(_find_button(title, "Start the job") != null, "a job shows its briefing")
	title.queue_free()
	Progress.reset()
	await _frames(1)


func _find_button(root: Node, starts: String) -> Button:
	for b in root.find_children("*", "Button", true, false):
		if b.text.begins_with(starts) and b.is_inside_tree():
			return b
	return null


func _make_job(start := "", id := "maple_close") -> Job:
	var job: Job = load("res://game/jobs/job.tscn").instantiate()
	job.job = Jobs.get_job(id)
	job.start_id = start
	add_child(job)
	return job


## The shared pieces in a bare test room: cameras, the alarm, keypads,
## lasers, hiding, darts, disguises, the fuse box and machinery noise.
func _test_systems() -> void:
	var def := JobDef.new()
	def.id = "test_room"
	def.title = "Test room"
	def.treasure_item = "cog"
	def.scene = "res://tests/test_level.gd"
	def.start_points = [{"id": "start", "title": "Start", "mastery": 0}]
	def.gadgets = [{"id": "darts", "title": "Darts", "mastery": 0}, {"id": "snooze_darts", "title": "Snooze darts", "mastery": 0}]
	var job: Job = load("res://game/jobs/job.tscn").instantiate()
	job.job = def
	job.start_id = "start"
	add_child(job)
	var ready := [false]
	job.level.navigation_ready.connect(func(): ready[0] = true)
	check(await _until(func(): return ready[0], 30.0), "the test room's navigation bakes")
	await _physics(5)
	var lvl = job.level
	var p := job.player
	var guard: Person = lvl.guard
	# The gadget in hand, and switching.
	check(job.gadgets.selected == "darts", "the blaster is in hand")
	job.gadgets.cycle(1)
	check(job.gadgets.selected == "snooze_darts", "the wheel switches to snooze darts")
	# A keypad: wrong codes buzz, the right one opens the door.
	check(not lvl.pad.enter("1234") and lvl.doors.back_door.locked, "a wrong code keeps the door locked")
	check(lvl.pad.enter("4071") and not lvl.doors.back_door.locked and job.run.has("keypad:back"), "the right code unlocks it")
	# Disguises: welcome where they fit, not in a zone that doesn't list them.
	p.global_position = Vector3(0, 0.9, 8)
	p.set_disguise("staff")
	await _physics(2)
	check(lvl.expects(guard, p), "the guard thinks nothing of staff in the hall")
	p.global_position = Vector3(0, 0.9, -10)
	check(not lvl.expects(guard, p), "but staff don't belong in the stock room")
	p.set_disguise("")
	# Hiding: in plain sight of the guard, then in the wardrobe, unseen.
	p.global_position = guard.global_position + Vector3(0, 0.9, 3.0)
	await _physics(3)
	lvl.spot.action("interact").interact(p.player_interaction_component)
	check(p.hiding == lvl.spot and p.visibility == 0.0 and job.run.has("hid"), "the player hides in the wardrobe")
	guard.suspicion = 0.0
	await _physics(20)
	check(guard.suspicion == 0.0, "nobody sees someone hiding")
	p.leave_hiding()
	check(p.hiding == null and p.global_position.distance_to(lvl.spot.global_position) < 2.0, "and steps back out")
	# Machinery drowns out quiet noises.
	var quiet := StealthNoise.make(lvl, Vector3(11, 0.1, 11), 6.0, "step")
	var plain := StealthNoise.make(lvl, Vector3(-11, 0.1, 11), 6.0, "step")
	check(quiet.loudness_at(lvl, Vector3(11, 1.5, 13)) < plain.loudness_at(lvl, Vector3(-11, 1.5, 13)), "machinery drowns out footsteps")
	# The camera sees a lit player and raises the alarm; the guard comes.
	p.global_position = lvl.cam.global_position + Vector3(0, -1.5, 5.0)
	check(await _until(func(): return lvl.alarm_ringing, 6.0), "the camera sees the player and raises the alarm")
	check(guard.state == Person.State.INVESTIGATE, "the guard runs to the alarm")
	check(job.hud._alarm.visible, "the HUD shows the alarm")
	# The fuse box: power off stops the camera, the lasers and the alarm.
	lvl.set_power(false)
	check(not lvl.alarm_ringing and not lvl.cam.is_working() and not lvl.gate.is_on(), "the power off stops the camera, lasers and alarm")
	check(guard.state == Person.State.FIX_FUSE, "the guard goes to fix the power")
	lvl.set_power(true)
	await _physics(2)
	# A dart knocks the camera out.
	p.global_position = lvl.cam.global_position + Vector3(0, -1.0, 4.0)
	p.body.global_rotation.y = 0.0
	p.head.rotation.x = 0.0
	await _physics(1)
	p.camera.look_at(lvl.cam.lens_position())
	check(job.gadgets.fire(false) == lvl.cam and not lvl.cam.is_working(), "a dart knocks out the camera")
	p.camera.rotation = Vector3.ZERO
	lvl.silence_alarm()
	# Lasers: walking through raises the alarm.
	lvl.alarm_armed = true
	p.global_position = Vector3(8, 0.9, 2)
	await _physics(3)
	p.global_position = Vector3(10, 0.9, 2)
	check(await _until(func(): return job.run.has("tripped_laser"), 2.0), "walking through the lasers trips them")
	check(lvl.alarm_ringing, "and rings the alarm")
	lvl.silence_alarm()
	lvl.alarm_armed = false
	lvl.raise_alarm(Vector3.ZERO)
	check(not lvl.alarm_ringing, "a switched-off alarm stays quiet")
	# A snooze dart puts the guard to sleep.
	p.global_position = Vector3(8, 0.9, 12)
	await _physics(3)
	p.camera.look_at(guard.global_position + Vector3(0, 1.0, 0))
	check(job.gadgets.fire(true) == guard and guard.is_asleep(), "a snooze dart sends the guard to sleep")
	p.camera.rotation = Vector3.ZERO
	job.queue_free()
	await _frames(2)


func _nav_path(job: Job, a: String, b: String) -> PackedVector3Array:
	var map := job.get_world_3d().navigation_map
	return NavigationServer3D.map_get_path(map, job.level.points[a], job.level.points[b], true)


func _test_level() -> void:
	var job := _make_job()
	var ready := [false]
	job.level.navigation_ready.connect(func(): ready[0] = true)
	check(await _until(func(): return ready[0], 30.0), "the people's navigation mesh bakes")
	await _physics(2)
	var lvl := job.level
	check(lvl.doors.has("front_door") and lvl.doors.front_door.locked, "the front door is locked")
	check(lvl.starts.size() == 3, "three start points")
	check(job.player.global_position.distance_to(lvl.start_transform("street").origin) < 0.5, "the player starts in the street")
	check(job.player.has_item("lockpicks") and job.player.bag.get("treats", 0) == 3, "the bag holds the gadgets")
	check(lvl.in_house(Vector3(0, 1, 0)) and not lvl.in_house(Vector3(0, 1, 9)), "inside and outside the house")
	check(lvl.indoors(Vector3(9, 1, -2)) and not lvl.in_house(Vector3(9, 1, -2)), "the garage is indoors but not the house")
	for pair in [["sofa", "study"], ["fridge", "bed"], ["garage", "bathroom"], ["front_step", "kitchen"]]:
		var path := _nav_path(job, pair[0], pair[1])
		var end_ok := not path.is_empty() and path[path.size() - 1].distance_to(lvl.points[pair[1]]) < 0.8
		check(end_ok, "people can walk from %s to %s" % pair)
	# Moving the mouse down looks down, unless invert look is on.
	var head: Node3D = job.player.head
	head.rotation.x = 0.0
	var move := InputEventMouseMotion.new()
	move.relative = Vector2(0, 40)
	job.player._input(move)
	check(head.rotation.x < -0.01, "moving the mouse down looks down (%.2f)" % head.rotation.x)
	LGSettings.set_value("play", "invert_look", true, false)
	job.player._reload_options()
	head.rotation.x = 0.0
	job.player._input(move)
	check(head.rotation.x > 0.01, "invert look turns that around")
	LGSettings.set_value("play", "invert_look", false, false)
	job.player._reload_options()
	head.rotation.x = 0.0
	# Escape opens the pause menu, and again closes it.
	var esc := InputEventKey.new()
	esc.keycode = KEY_ESCAPE
	esc.physical_keycode = KEY_ESCAPE
	esc.pressed = true
	Input.parse_input_event(esc)
	await _frames(2)
	check(job.pause.visible and get_tree().paused, "Escape opens the pause menu")
	Input.parse_input_event(esc)
	await _frames(2)
	check(not job.pause.visible and not get_tree().paused, "Escape closes it again")
	get_tree().paused = false
	job.pause.visible = false
	# The player is lit under the porch light and hidden in the back garden.
	job.player.global_position = Vector3(0.4, 0.9, 6.0)
	await _physics(20)
	var lit: float = job.player.visibility
	job.player.global_position = Vector3(-10, 0.9, -12)
	await _physics(60)
	check(lit > 0.4 and job.player.visibility < 0.2, "the porch light shows you, the garden hides you (%.2f, %.2f)" % [lit, job.player.visibility])
	# Noises carry less through walls.
	var n := StealthNoise.make(lvl, Vector3(-4, 0.1, 2), 6.0, "test")
	check(n.loudness_at(lvl, Vector3(-4, 1.5, 3)) > n.loudness_at(lvl, Vector3(-4, 1.5, -2.5)), "walls muffle noise")
	job.queue_free()
	await _frames(2)


## A scripted night: checks the people notice noise and sight, answer the
## doorbell, wake the dog, catch the player, and that escaping ends the job.
func _test_night() -> void:
	Engine.time_scale = 3.0
	var job := _make_job()
	var ready := [false]
	job.level.navigation_ready.connect(func(): ready[0] = true)
	await _until(func(): return ready[0], 30.0)
	var ted: Person = job.level.get_node("Ted")
	var maggie: Person = job.level.get_node("Maggie")
	var dog: Dog = job.level.get_node("Biscuit")
	var p := job.player
	check(await _until(func(): return ted.rig.current_clip() == "sit-watch", 10.0), "Ted settles in front of the telly")
	check(await _until(func(): return maggie.global_position.distance_to(job.level.points["bed"]) < 1.0, 10.0), "Maggie goes to bed")
	# A rattle in the hall makes Ted come and look.
	StealthNoise.make(job.level, Vector3(-1, 0.1, 1), 9.0, "rattle")
	StealthNoise.make(job.level, Vector3(-1, 0.1, 1), 9.0, "rattle")
	check(ted.state == Person.State.INVESTIGATE, "a rattle nearby makes Ted investigate")
	var gave_up := await _until(func(): return ted.state == Person.State.ROUTINE, 60.0)
	check(gave_up, "Ted gives up and goes back to his routine")
	if not gave_up:
		printerr("  Ted state %d suspicion %.2f at %s target %s arrived %s" % [ted.state, ted.suspicion, ted.global_position, ted._target, ted._arrived])
	# The doorbell brings Ted to the front door, which he opens.
	StealthNoise.make(job.level, Vector3(0.3, 1.3, 5.1), 30.0, "bell", p)
	check(ted.state == Person.State.ANSWER_DOOR, "Ted answers the doorbell")
	check(await _until(func(): return job.level.doors.front_door.is_open, 20.0), "Ted opens the front door")
	check(await _until(func(): return ted.state == Person.State.ROUTINE, 20.0), "Ted shuts the door on nobody")
	# Noise near the dog wakes him.
	for i in 6:
		StealthNoise.make(job.level, dog.global_position + Vector3(1.5, 0, 0), 5.0, "step", p)
	check(dog.state != Dog.State.SLEEP and job.run.has("dog_woke"), "noise wakes Biscuit")
	# Standing right in front of Ted gets you spotted and caught.
	await _until(func(): return ted.state == Person.State.ROUTINE, 30.0)
	p.add_item("trophy")
	job.level.return_treasure()
	p.global_position = ted.global_position + ted._facing() * 1.2 + Vector3(0, 0.9, 0)
	var spotted := await _until(func(): return job.run.spotted > 0, 10.0)
	check(spotted, "Ted spots the player in his living room")
	if not spotted:
		printerr("  Ted state %d suspicion %.2f at %s rig %s, player at %s vis %.2f clip %s" % [ted.state, ted.suspicion, ted.global_position, ted.rig.rotation_degrees, p.global_position, p.visibility, ted.rig.current_clip()])
	check(await _until(func(): return job.run.caught > 0, 15.0), "Ted catches the player")
	await _until(func(): return not p.is_movement_paused, 5.0)
	check(p.global_position.distance_to(job.level.start_transform("street").origin) < 1.0, "the caught player is marched back out")
	check(not p.has_item("trophy"), "the trophy is taken back")
	# With the trophy at a way out, the night ends.
	var finished := [false]
	job.run.finished.connect(func(_r): finished[0] = true)
	p.add_item("trophy")
	p.global_position = job.level.way_outs["garden"] + Vector3(0, 0.9, 0)
	check(await _until(func(): return finished[0], 3.0), "reaching a way out with the trophy ends the night")
	check(job.run.result().get("treasure", false), "the result has the treasure")
	Engine.time_scale = 1.0
	job.queue_free()
	await _frames(2)


## The common checks and each job's own tests for the jobs after Maple
## Close (`-- --job=<id>` runs just one).
func _test_jobs(ids: Array, games: int) -> void:
	for id in ids:
		if Jobs.get_job(id) == null or id == "maple_close":
			continue
		printerr("- _test_built_job %s" % id)
		await _test_built_job(id)
		var suite := JOB_TESTS % [id, id]
		if ResourceLoader.exists(suite):
			printerr("- %s" % suite.get_file())
			var script: GDScript = load(suite)
			check(script != null and script.can_instantiate(), "%s's tests load" % id)
			if script != null and script.can_instantiate():
				await script.new().run(self, games)


## What every built job needs: enough capers and leads, start points that open
## with mastery, a treasure, people with voices of their own, a navigation
## mesh, and a player who can start from each start point.
func _test_built_job(id: String) -> void:
	var def := Jobs.get_job(id)
	check(def.id == id and def.title != "" and def.blurb != "", "%s has a title and a briefing" % id)
	check(def.capers.size() >= 12, "%s has at least 12 capers (%d)" % [id, def.capers.size()])
	check(def.leads.size() >= 2, "%s has at least 2 leads" % id)
	check(def.start_points.size() >= 3 and def.open_start_points(0).size() >= 1, "%s has 3 or more start points, one open from the start" % id)
	check(def.treasure_item != "", "%s names its treasure item" % id)
	var caper_ids := {}
	for c in def.capers:
		caper_ids[c.id] = true
	check(caper_ids.size() == def.capers.size(), "%s caper ids are unique" % id)
	var job := _make_job("", id)
	var ready := [false]
	job.level.navigation_ready.connect(func(): ready[0] = true)
	check(await _until(func(): return ready[0], 30.0), "%s's navigation mesh bakes" % id)
	await _physics(2)
	var lvl := job.level
	check(lvl.treasure_stand != null, "%s has its treasure" % id)
	check(lvl.starts.size() == def.start_points.size(), "%s builds every start point" % id)
	for s in def.start_points:
		check(lvl.starts.has(s.id), "%s builds start point %s" % [id, s.id])
	check(not lvl.way_outs.is_empty(), "%s has a way out" % id)
	var voices := lvl.voice_info()
	var people := 0
	for p in lvl.get_children():
		if p is Person:
			people += 1
			check(voices.has(p.voice), "%s: %s has a described voice" % [id, p.name])
			check(not p.voice in ["low", "high"], "%s: %s has a voice of their own" % [id, p.name])
	check(people > 0, "%s has people" % id)
	check(job.player.global_position.distance_to(lvl.start_transform(def.start_points[0].id).origin) < 0.5, "%s: the player starts at the first start point" % id)
	job.queue_free()
	await _frames(2)
