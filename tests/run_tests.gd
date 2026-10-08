extends Node
## Headless tests: run with
##   godot --headless --path . tests/run_tests.tscn
## Add `-- --games=N` to also play N scripted nights against the people's
## AI (default 1). Exits non-zero on failure.

var failures := 0
var checks := 0


func _ready() -> void:
	var games := 1
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--games="):
			games = maxi(1, arg.substr(8).to_int())
	LGSettings.register_defaults(GameConfig.SETTING_DEFAULTS)
	LGTheme.apply(get_tree().root)
	LGInput.register_actions(GameConfig.ACTIONS)
	LGInput.extend_ui_actions()
	Progress.in_memory = true
	Progress.load_progress()
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
	printerr("- _test_title_menu")
	await _test_title_menu()
	printerr("- _test_level")
	await _test_level()
	for i in games:
		printerr("- _test_night %d" % (i + 1))
		await _test_night()
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
	check(job.open_gadgets(0).size() == 3 and job.open_gadgets(2).size() == 4, "gadgets unlock with mastery")
	check(Jobs.all().size() == 7 and not Jobs.all()[1].playable, "the job board lists later jobs as not playable")


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


func _test_title_menu() -> void:
	var title: Node = load("res://game/ui/title.tscn").instantiate()
	add_child(title)
	await _frames(2)
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
	await _frames(1)


func _find_button(root: Node, starts: String) -> Button:
	for b in root.find_children("*", "Button", true, false):
		if b.text.begins_with(starts) and b.is_inside_tree():
			return b
	return null


func _make_job(start := "") -> Job:
	var job: Job = load("res://game/jobs/job.tscn").instantiate()
	job.job = Jobs.get_job("maple_close")
	job.start_id = start
	add_child(job)
	return job


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
