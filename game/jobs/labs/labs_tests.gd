extends RefCounted
## Hoard Labs' own tests: the sliding doors (cards, the push button inside,
## shutting and locking again, following someone through), Officer Marsh's
## tea break and the cameras she watches, the office panel, the lasers you
## can crawl under, the vents, coffee, borrowing a napping guard's card, and
## the "Sputnik year" lead from the overheard code to the getaway.


func run(t, _games: int) -> void:
	var job: Job = t._make_job("car_park", "labs")
	var ready := [false]
	job.level.navigation_ready.connect(func(): ready[0] = true)
	t.check(await t._until(func(): return ready[0], 30.0), "labs: the navigation mesh bakes")
	await t._physics(5)
	var lvl: LabsLevel = job.level
	var p: Moth = job.player
	var pic: PlayerInteractionComponent = p.player_interaction_component
	var run: JobRun = job.run
	for pair in [["monitors", "coffee"], ["lobby", "cell_front"], ["car_park_w", "catwalk"],
			["fenwick_bench", "server_door_out"], ["yard", "bay_hangar_in"], ["hangar_in", "fuse_box"],
			["clean", "coffee"], ["office_visit", "hangar_west"]]:
		var path: PackedVector3Array = t._nav_path(job, pair[0], pair[1])
		var ok := not path.is_empty() and path[path.size() - 1].distance_to(lvl.points[pair[1]]) < 0.8
		t.check(ok, "labs: people can walk from %s to %s" % pair)
	# The guards and Dr Fenwick stay put while the systems are tested.
	for who in [lvl.dobbs, lvl.rook, lvl.fenwick]:
		who.process_mode = Node.PROCESS_MODE_DISABLED

	# Sliding doors: a card from the corridor, the push button from inside,
	# shutting and locking again on their own.
	var chem: HouseDoor = lvl.doors.chem_door
	_put(p, Vector3(-15, 0, 1.4))
	await t._physics(2)
	chem.action("interact").interact(pic)
	t.check(chem.locked and not chem.is_open, "labs: the lab doors need a card")
	p.add_item("lab_keycard")
	chem.action("interact").interact(pic)
	t.check(not chem.locked and chem.is_open and chem.slide and run.has("used_key") and run.has("opened:chem_door"), "labs: the lab card slides the door open")
	_put(p, Vector3(-9, 0, 1.4))
	t.check(await t._until(func(): return not chem.is_open, 9.0), "labs: a sliding door shuts by itself")
	t.check(chem.locked, "labs: and locks again behind you")
	p.take_item("lab_keycard")
	_put(p, Vector3(-15, 0, -1.4))
	await t._physics(2)
	chem.action("interact").interact(pic)
	t.check(chem.is_open, "labs: from inside, the push button opens it without a card")
	await t._until(func(): return not chem.is_open, 9.0)
	# Following someone through.
	_put(p, Vector3(-15.4, 0, 0.7))
	await t._physics(3)
	chem.locked = false
	chem.person_open(lvl.fenwick)
	await t._physics(2)
	_put(p, Vector3(-15.4, 0, -0.7))
	await t._physics(3)
	t.check(run.has("tailgated"), "labs: slipping through behind someone counts as tailgating")
	t.check(not run.has("opened:chem_door") or run.has("used_key"), "labs: and you didn't open it yourself")

	# The lab coat: welcome in the corridor, not in the hangar.
	p.set_disguise("labcoat")
	_put(p, Vector3(-7, 0, 1.0))
	t.check(lvl.expects(lvl.dobbs, p), "labs: the guards think nothing of a lab coat in the corridor")
	_put(p, Vector3(8, 0, -9))
	t.check(not lvl.expects(lvl.dobbs, p), "labs: but a lab coat doesn't belong in the hangar")
	t.check(not lvl.expects(lvl.fenwick, p), "labs: and Dr Fenwick knows her own team")
	p.set_disguise("")

	# Officer Marsh watches the cameras; on her tea break they only record.
	_put(p, Vector3(-12, LabsLevel.UP, -4))
	var marsh: LabsOfficer = lvl.marsh
	t.check(await t._until(func(): return marsh.watching(), 15.0), "labs: Marsh sits at the monitors")
	lvl.raise_alarm(Vector3(-7, 0, 1), "camera")
	t.check(lvl.alarm_ringing, "labs: a camera rings the alarm while Marsh watches")
	lvl.silence_alarm()
	lvl.get_node("CoffeeMachine").action("interact").interact(pic)
	t.check(run.has("made_coffee") and lvl.coffee_ready, "labs: the coffee machine makes a cup")
	Engine.time_scale = 3.0
	marsh.take_break()
	t.check(run.has("officer_on_break") and marsh.on_break and not lvl.cameras_watched(), "labs: Marsh goes for her tea")
	lvl.raise_alarm(Vector3(-7, 0, 1), "camera")
	t.check(not lvl.alarm_ringing and run.has("camera_unwatched"), "labs: nobody's watching the cameras while she's away")
	# The office panel while she's out.
	lvl._switches.cameras.action("interact").interact(pic)
	lvl._switches.lasers.action("interact").interact(pic)
	t.check(run.has("cameras_off") and run.has("lasers_off") and run.has("office_all_off"), "labs: everything switched off while she's on her break")
	var gate: LaserGate = lvl.get_node("Lasers_cell")
	t.check(not gate.is_on() and not lvl.get_node("Camera_cell").is_working(), "labs: the panel turns off the lasers and cameras")
	t.check(await t._until(func(): return run.has("coffee_drunk"), 25.0), "labs: Marsh finds the fresh coffee and stops for it")
	marsh._step_time = 1.0
	t.check(await t._until(func(): return lvl.cameras_on() and lvl.lasers_on(), 40.0), "labs: back at her desk, Marsh puts it all back on")
	t.check(run.has("officer_reset") and not marsh.on_break, "labs: and her break is over")
	Engine.time_scale = 1.0

	# The cell's lasers are high: crawl under, or trip them standing.
	_put(p, Vector3(13, 0, -8.6))
	await t._physics(3)
	_crouch(p, true)
	_put(p, Vector3(13, 0, -10.0))
	await t._physics(10)
	t.check(not run.has("tripped_laser"), "labs: you can crawl under the cell's lasers")
	_put(p, Vector3(13, 0, -11.2))
	await t._physics(3)
	_crouch(p, false)
	_put(p, Vector3(13, 0, -10.0))
	t.check(await t._until(func(): return run.has("tripped_laser"), 2.0), "labs: standing up in them trips them")
	lvl.silence_alarm()
	var corridor: LaserGate = lvl.get_node("Lasers_corridor")
	var states := {}
	for i in 30:
		states[corridor.is_on()] = true
		await t._physics(10)
	t.check(states.size() == 2, "labs: the corridor lasers blink on and off")

	# Vents: off with the covers and through every one.
	for id in lvl.vents:
		var v: LabsVent = lvl.vents[id]
		v.open()
		_put(p, v.hole + Vector3(0, 0.05, 0))
		await t._physics(2)
		t.check(run.has("vent:" + id), "labs: crawled through the %s vent" % id)
	t.check(run.has("all_vents"), "labs: every vent crawled through")

	# A napping guard's hangar card.
	var pocket: UsableBody = lvl.dobbs.get_node("Pocket")
	t.check(pocket.action("interact").is_disabled, "labs: no borrowing a card from a guard who's awake")
	lvl.dobbs.snooze()
	await t._physics(2)
	pocket.action("interact").interact(pic)
	t.check(p.has_item("hangar_keycard") and run.has("borrowed_keycard"), "labs: borrow the hangar card from a napping guard")
	p.take_item("hangar_keycard")
	marsh.snooze()
	await t._physics(2)
	t.check(run.has("officer_snoozed") and not lvl.cameras_watched(), "labs: Marsh asleep at her desk watches nothing")

	# The confetti cannon.
	lvl.get_node("ConfettiCannon").action("interact").interact(pic)
	t.check(await t._until(func(): return run.has("confetti"), 4.0), "labs: the confetti cannon goes off")

	# The "Sputnik year" lead, from the overheard code to the getaway.
	lvl.fenwick.global_position = lvl.points["server_door_out"]
	_put(p, Vector3(-6.5, 0, 1.0))
	await t._physics(2)
	lvl.fenwick.say(LabsLevel.CODE_LINE)
	var lead := run.job.lead("server_code")
	t.check(run.lead_steps.has("server_code"), "labs: overhearing Dr Fenwick finds the Sputnik year lead")
	var pad: Keypad = lvl.get_node("Keypad_server")
	t.check(not pad.enter("2069") and lvl.doors.server_door.locked, "labs: the wrong code keeps the server room shut")
	t.check(pad.enter(LabsLevel.SERVER_CODE) and not lvl.doors.server_door.locked, "labs: Sputnik year opens the server room")
	t.check(run.lead_text(lead) == lead.steps[1][0], "labs: the lead moves on to the door controller")
	lvl.get_node("DoorController").action("interact").interact(pic)
	var hangar: HouseDoor = lvl.doors.hangar_door
	t.check(run.has("hangar_released") and not hangar.locked, "labs: the door controller releases the hangar door")
	hangar.person_open(lvl.dobbs)
	hangar.person_close(lvl.dobbs)
	t.check(not hangar.locked, "labs: and it stays released after it shuts")
	_put(p, Vector3(9, 0, -8))
	t.check(await t._until(func(): return run.has("entered_hangar"), 2.0), "labs: into the hangar")
	_put(p, Vector3(13, 0, -12.6))
	await t._physics(2)
	lvl.treasure_stand.action("interact").interact(pic)
	t.check(p.has_item("rocket") and run.has("took_treasure"), "labs: the rocket comes off its stand")
	t.check(run.lead_text(lead) == lead.steps[4][0], "labs: the lead says to get out")
	p.add_item("bottle_rocket")
	lvl.treasure_stand.action("interact").interact(pic)
	t.check(run.has("bottle_on_stand") and run.is_caper_done("bottle_swap"), "labs: a bottle rocket left in its place")
	var finished := [false]
	run.finished.connect(func(_r): finished[0] = true)
	_put(p, lvl.way_outs["roof"])
	t.check(await t._until(func(): return finished[0], 3.0), "labs: over the roof with the rocket ends the night")
	t.check(run.result().get("treasure", false) and run.is_caper_done("by_the_roof"), "labs: away over the roof with the rocket")
	t.check(not run.lead_steps.has("server_code") or run.lead_text(lead) == "", "labs: the lead is finished")
	Engine.time_scale = 1.0
	job.queue_free()
	await t._frames(2)


## Puts the player's feet at `at`, standing still.
static func _put(p: Moth, at: Vector3) -> void:
	p.global_position = at + Vector3(0, 0.9, 0)
	p.velocity = Vector3.ZERO


static func _crouch(p: Moth, on: bool) -> void:
	p.is_crouching = on
	p.try_crouch = on
	p.standing_collision_shape.disabled = on
	p.crouching_collision_shape.disabled = not on
