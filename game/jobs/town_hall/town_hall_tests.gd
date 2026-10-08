extends RefCounted
## Town hall's own tests: the building's paths, the seated crowd, the bell
## and the fuse box, both disguises and the seats, the clerk's numbers lead
## from the noticeboard to the front steps, and the mayor's trip to fetch
## the charter for the vote (snoozed with it in her arms, it falls at her
## feet).

var t


func run(runner, _games: int) -> void:
	t = runner
	await _test_building()
	await _test_vote()


func _make(start: String) -> Job:
	var job: Job = t._make_job(start, "town_hall")
	var ready := [false]
	job.level.navigation_ready.connect(func(): ready[0] = true)
	t.check(await t._until(func(): return ready[0], 30.0), "town hall: the navigation mesh bakes")
	await t._physics(3)
	return job


func _use(job: Job, node: Node, input := "interact") -> void:
	(node as UsableBody).action(input).interact(job.player.player_interaction_component)


func _test_building() -> void:
	var job: Job = await _make("front")
	var lvl := job.level as TownHallLevel
	var p := job.player
	var run := job.run
	t.check(lvl.crowd.size() >= 12, "town hall: the chamber is full (%d)" % lvl.crowd.size())
	t.check(lvl.mayor != null and lvl.clerk != null and lvl.caretaker != null and lvl.hoard != null, "town hall: the mayor, the clerk, the caretaker and Hoard are here")
	t.check(lvl.hoard.voice == "hoard", "town hall: Hoard has his own voice")
	t.check(not lvl.box_open and lvl.charter_at == "box", "town hall: the charter starts locked in the strongbox")
	t.check(lvl.doors.mayor_door.locked and lvl.doors.side_door.locked and not lvl.doors.front_left.locked, "town hall: the front doors are open for the meeting, the mayor's door and the side door are locked")
	# People can walk everywhere their routines take them.
	for pair in [["lobby", "mayor_box"], ["cupboard", "roof_house"], ["clerk_desk", "archive_shelf"], ["minutes_desk", "reception"],
			["mayor_chair", "mayor_box"], ["west_hall", "car_park"], ["minutes_desk", "clerk_desk"], ["corridor_e", "cloak_mayor"]]:
		var path: PackedVector3Array = t._nav_path(job, pair[0], pair[1])
		var ok := not path.is_empty() and path[path.size() - 1].distance_to(lvl.points[pair[1]]) < 0.8
		t.check(ok, "town hall: people can walk from %s to %s" % pair)
	# The crowd's chatter drowns footsteps at the back, not on the dais.
	t.check(lvl.masking_at(Vector3(0, 1, -1)) > 0.5 and lvl.masking_at(Vector3(0, 1, -9)) == 0.0, "town hall: the chatter masks the back of the chamber")
	var step := StealthNoise.make(lvl, Vector3(0, 0.1, -1), 6.0, "step")
	var hall := StealthNoise.make(lvl, Vector3(0, 0.1, 6), 6.0, "step")
	t.check(step.loudness_at(lvl, Vector3(0, 1.5, -3.5)) < hall.loudness_at(lvl, Vector3(0, 1.5, 3.5)), "town hall: footsteps behind the crowd go unheard")
	# The back of the chamber is dark; the dais is lit.
	p.global_position = Vector3(-1, 0.9, -0.8)
	await t._physics(40)
	var back: float = p.visibility
	p.global_position = Vector3(-0.6, 1.1, -7.8)
	await t._physics(40)
	t.check(back < 0.15 and p.visibility > 0.3, "town hall: the back of the chamber is dark, the dais lit (%.2f, %.2f)" % [back, p.visibility])
	p.global_position = Vector3(-1, 0.9, 12)
	# The crowd stays seated whatever they hear.
	var c: TownHallCrowd = lvl.crowd[3]
	var seat := c.global_position
	for i in 3:
		StealthNoise.make(lvl, seat + Vector3(1.2, 0.1, 0), 8.0, "rattle")
	await t._physics(30)
	t.check(c.global_position.distance_to(seat) < 0.05 and c.state == Person.State.ROUTINE, "town hall: a noise turns heads but nobody leaves their seat")
	# The bell: Stanley goes up to see who rang it.
	_use(job, lvl.rope)
	t.check(run.has("rang_bell") and run.is_caper_done("ring_bell"), "town hall: pulling the rope rings the bell")
	t.check(lvl.caretaker.state == Person.State.INVESTIGATE, "town hall: the caretaker goes to see who rang the bell")
	# The fuse box: the meeting goes dark, and Stanley heads for the fuses.
	lvl.set_power(false)
	t.check(run.is_caper_done("lights_out") and not lvl.lights_on("chamber_front") and not lvl.lights_on("lobby"), "town hall: the main breaker puts the meeting in the dark")
	t.check(lvl.caretaker.state == Person.State.FIX_FUSE, "town hall: Stanley goes to fix the fuses")
	lvl.set_power(true)
	t.check(lvl.lights_on("chamber_front"), "town hall: and the lights come back")
	# A coat from the cloakroom: one of the townsfolk in the lobby and the
	# chamber, but not in the staff rooms or upstairs.
	_use(job, lvl.get_node("CoatRail"))
	t.check(p.disguise == "townsfolk" and run.has("wore:townsfolk"), "town hall: borrowing a coat makes you one of the townsfolk")
	p.global_position = Vector3(0, 0.9, -1.0)
	t.check(lvl.expects(c, p) and lvl.expects(lvl.mayor, p), "town hall: the crowd and the mayor think nothing of townsfolk at the back")
	p.global_position = Vector3(10, 0.9, -7)
	t.check(not lvl.expects(lvl.caretaker, p), "town hall: townsfolk don't belong in the clerk's office")
	p.global_position = Vector3(-6, UP_EYE, 1)
	t.check(not lvl.expects(lvl.caretaker, p), "town hall: or upstairs")
	# An empty seat at the back: in the coat you sit down unseen.
	p.global_position = lvl.seats[1].global_position + Vector3(0, 0.9, 1.2)
	await t._physics(2)
	_use(job, lvl.seats[1])
	t.check(p.hiding == lvl.seats[1] and run.is_caper_done("sit_in"), "town hall: in a coat you can sit in on the meeting")
	p.leave_hiding()
	p.set_disguise("")
	_use(job, lvl.seats[1])
	t.check(p.hiding == null, "town hall: without a coat you'd stand out")
	# The mayor's key is in her red coat.
	_use(job, lvl.mayor_coat)
	t.check(p.has_item("mayor_key") and run.is_caper_done("pickpocket"), "town hall: the mayor's key is in her coat")
	# The clerk's numbers: the noticeboard, the lanyard, the sticky note,
	# the photo in the archive, the dial, the charter and away.
	var lead: LeadDef = run.job.lead("clerks_numbers")
	_use(job, lvl.get_node("Note_staff_notice"))
	t.check(run.lead_steps.has("clerks_numbers") and run.lead_text(lead) == lead.steps[0][0], "town hall: the staff notice finds the clerk's numbers lead")
	_use(job, lvl.get_node("Lanyard"))
	t.check(p.disguise == "clerk" and p.has_item("staff_key") and run.lead_text(lead) == lead.steps[1][0], "town hall: the spare lanyard passes for a clerk and has the staff key")
	t.check(run.is_caper_done("both_looks"), "town hall: both disguises worn")
	p.global_position = Vector3(-6, UP_EYE, 1)
	t.check(lvl.expects(lvl.mayor, p) and lvl.expects(lvl.caretaker, p), "town hall: a clerk belongs upstairs")
	t.check(not lvl.expects(lvl.clerk, p), "town hall: but Dobbs knows he's the only clerk")
	_use(job, lvl.get_node("Note_sticky_note"))
	t.check(run.lead_text(lead) == lead.steps[2][0], "town hall: the sticky note has the first half")
	_use(job, lvl.get_node("Note_green_photo"))
	t.check(run.lead_text(lead) == lead.steps[3][0], "town hall: the photo has the second half")
	t.check(not lvl.strongbox_pad.enter("1846") and not lvl.box_open, "town hall: the wrong numbers don't open the strongbox")
	t.check(lvl.strongbox_pad.enter(TownHallLevel.CODE) and lvl.box_open and run.is_caper_done("codebreaker"), "town hall: the right numbers do")
	t.check(run.lead_text(lead) == lead.steps[4][0], "town hall: the lead moves on to taking the charter")
	_use(job, lvl.treasure_stand)
	t.check(p.has_item("charter") and run.has("took_treasure"), "town hall: the charter is in the bag")
	t.check(run.is_caper_done("before_vote"), "town hall: taken before the vote")
	t.check(not lvl.expects(lvl.mayor, p), "town hall: the mayor knows her charter, whatever you wear")
	# Out of the front doors with it.
	var finished := [false]
	run.finished.connect(func(_r): finished[0] = true)
	p.global_position = lvl.way_outs["front"] + Vector3(0, 0.9, 0)
	t.check(await t._until(func(): return finished[0], 3.0), "town hall: the front steps are a way out")
	t.check(run.result().get("treasure", false) and run.has("way_out:front"), "town hall: away with the charter")
	t.check(run.lead_steps.get("clerks_numbers", 0) == lead.steps.size(), "town hall: the clerk's numbers lead is finished")
	job.queue_free()
	await t._frames(2)


## Ten o'clock: the mayor fetches the charter, and a snooze dart makes her
## drop it.
func _test_vote() -> void:
	Engine.time_scale = 3.0
	var job: Job = await _make("roof")
	var lvl := job.level as TownHallLevel
	var p := job.player
	var run := job.run
	p.add_item("snooze_darts")
	t.check(p.global_position.y > TownHallLevel.ROOF, "town hall: the roof start is up on the roof")
	# Wait in her wardrobe.
	var robe := lvl.get_node("Hide_mayor_wardrobe") as HideSpot
	p.global_position = robe.global_position + Vector3(-1.0, 0.9, 0)
	await t._physics(2)
	_use(job, robe)
	t.check(p.hiding == robe, "town hall: hiding in the mayor's wardrobe")
	lvl.call_vote()
	t.check(run.has("vote_called"), "town hall: the vote is called")
	var carrying: bool = await t._until(func(): return lvl.charter_at == "mayor", 90.0)
	t.check(carrying, "town hall: the mayor fetches the charter from her office")
	if not carrying:
		printerr("  mayor state %d at %s step %d" % [lvl.mayor.state, lvl.mayor.global_position, lvl.mayor._step])
	t.check(lvl.box_open and run.has("strongbox_opened_by_mayor"), "town hall: she opened the strongbox herself")
	t.check(run.spotted == 0, "town hall: nobody sees you in the wardrobe")
	p.leave_hiding()
	lvl.mayor.snooze()
	t.check(lvl.charter_at == "floor" and lvl.treasure_stand.global_position.distance_to(lvl.mayor.global_position) < 1.5, "town hall: snoozed, she drops the charter at her feet")
	_use(job, lvl.treasure_stand)
	t.check(p.has_item("charter") and run.is_caper_done("mayor_opens") and run.is_caper_done("before_vote"), "town hall: the mayor opened the box for you")
	# When she wakes up, the vote is off.
	t.check(await t._until(func(): return run.has("vote_off"), 120.0), "town hall: without the charter the vote is off")
	# Had she reached the lectern with it, it would sit there for the vote.
	lvl.charter_at = "mayor"
	lvl._on_step_arrived(lvl.mayor, {"do": "place_charter"})
	t.check(run.has("vote_started") and lvl.charter_at == "lectern" and lvl.treasure_stand.global_position.distance_to(lvl.lectern.global_position) < 0.5, "town hall: the charter goes on the lectern for the vote")
	# Someone in the crowd points out a stranger, and the staff come.
	p.take_item("charter")
	run.drop_treasure()
	var c: TownHallCrowd = lvl.crowd[2]
	var seat := c.global_position
	p.set_disguise("")
	p.global_position = seat + Vector3(0, 0.9, -1.4)
	var spotted: bool = await t._until(func(): return run.spotted > 0, 10.0)
	t.check(spotted, "town hall: the crowd spots a stranger in front of them")
	t.check(c.global_position.distance_to(seat) < 0.05, "town hall: and points rather than gives chase")
	var staff_alert := false
	for o in [lvl.clerk, lvl.caretaker, lvl.hoard]:
		staff_alert = staff_alert or o.is_alert()
	t.check(staff_alert, "town hall: the staff come to see")
	Engine.time_scale = 1.0
	job.queue_free()
	await t._frames(2)


const UP_EYE := TownHallLevel.UP + 0.9
