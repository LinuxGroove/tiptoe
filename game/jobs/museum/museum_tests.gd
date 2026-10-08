extends RefCounted
## The Hoard Museum's own tests: gossip, disguises at the party, serving
## drinks, the toast, the plinth and its lasers, the skylight, and the guard's
## birthday lead from the gossip to the escape.

var t


func run(p_t, _games: int) -> void:
	t = p_t
	var job: Job = t._make_job("steps", "museum")
	var ready := [false]
	job.level.navigation_ready.connect(func(): ready[0] = true)
	t.check(await t._until(func(): return ready[0], 30.0), "museum: the navigation bakes")
	await t._physics(5)
	var lvl: MuseumLevel = job.level
	var party := lvl.party
	var p := job.player
	_check_paths(job)
	await _check_disguises(job, lvl, party, p)
	await _check_gossip(job, lvl, party, p)
	_check_serving(job, party, p)
	await _check_toast(job, lvl, party, p)
	await _check_plinth(job, lvl, p)
	await _check_skylight(job, lvl, p)
	await _check_birthday_lead(job, lvl, party, p)
	Engine.time_scale = 1.0
	job.queue_free()
	await t._frames(2)


func _path_ok(job: Job, a: String, b: String) -> bool:
	var map := job.get_world_3d().navigation_map
	var path := NavigationServer3D.map_get_path(map, job.level.points[a], job.level.points[b], true)
	return not path.is_empty() and path[path.size() - 1].distance_to(job.level.points[b]) < 0.8


func _check_paths(job: Job) -> void:
	for pair in [["desk", "foyer"], ["desk", "kitchen"], ["hall_c", "toast_hoard"], ["castles", "office"],
			["pass", "buffet"], ["stove", "yard"], ["corridor_s", "desk"], ["pirates", "nature"],
			["hall_c", "fuse_box"], ["arch", "rotunda"], ["toast_guard", "desk"], ["p2_foyer_a", "p2_steps_a"]]:
		t.check(_path_ok(job, pair[0], pair[1]), "museum: people can walk from %s to %s" % pair)


func _check_disguises(job: Job, lvl: MuseumLevel, party: MuseumParty, p: Moth) -> void:
	p.global_position = Vector3(0, 0.9, 3)
	p.set_disguise("guest")
	await t._physics(2)
	t.check(lvl.expects(party.hoard, p), "museum: a guest is welcome in the hall")
	p.global_position = Vector3(12, 0.9, -9)
	t.check(not lvl.expects(party.cook, p), "museum: but not in the kitchen")
	p.set_disguise("waiter")
	t.check(lvl.expects(party.cook, p), "museum: a waiter is welcome in the kitchen")
	p.global_position = Vector3(0, 0.9, -9)
	t.check(not lvl.expects(party.ron, p), "museum: nobody belongs in the rotunda")
	p.global_position = Vector3(0, 0.9, 3)
	t.check(not lvl.expects(party.pring, p), "museum: the head waiter notices a waiter without a tray")
	lvl.get_node("Trays").action("interact").interact(p.player_interaction_component)
	t.check(p.bag.get("drinks", 0) == 4 and job.run.has("took:drinks"), "museum: a tray holds four drinks")
	t.check(lvl.expects(party.pring, p), "museum: a waiter with a tray is a waiter at work")
	p.set_disguise("")


func _check_gossip(job: Job, lvl: MuseumLevel, party: MuseumParty, p: Moth) -> void:
	Engine.time_scale = 3.0
	var a: Person = party.pairs[0][0]
	var b: Person = party.pairs[0][1]
	t.check(await t._until(func(): return MuseumParty._free(a) and MuseumParty._free(b), 20.0), "museum: the gossiping pair settle in")
	# Stand behind a pillar of the crowd: near enough to hear, in a disguise.
	p.set_disguise("guest")
	p.global_position = a.global_position + Vector3(0, 0.9, 2.5)
	var heard: bool = await t._until(func(): return job.run.has("heard:guard_code"), 15.0)
	t.check(heard, "museum: standing by the pair, the player overhears the door code")
	t.check(job.run.lead_steps.has("guards_birthday"), "museum: the gossip finds the guard's birthday lead")
	# Gossip goes on topic by topic; hearing the lot is a caper.
	for topic in MuseumParty.GOSSIP:
		party.hear(topic)
	t.check(job.run.has("heard_all_gossip") and job.run.is_caper_done("gossip"), "museum: all the gossip is a caper")
	# The chatter masks footsteps in the hall, but not in the galleries.
	var hall := StealthNoise.make(lvl, Vector3(0, 0.1, 2), 6.0, "step")
	var gallery := StealthNoise.make(lvl, Vector3(-11, 0.1, 2), 6.0, "step")
	t.check(hall.loudness_at(lvl, Vector3(0, 1.5, 4)) < gallery.loudness_at(lvl, Vector3(-11, 1.5, 4)), "museum: the party's chatter drowns out footsteps")
	p.set_disguise("")
	p.global_position = lvl.start_transform("steps").origin
	Engine.time_scale = 1.0


func _check_serving(job: Job, party: MuseumParty, p: Moth) -> void:
	p.bag.erase("drinks")
	p.add_item("drinks", 3)
	var served := 0
	for g in [party.hoard, party.pairs[0][0], party.pairs[1][1]]:
		var spot: UsableBody = g.get_node("Serve")
		g.suspicion = 0.0
		if g.state != Person.State.ROUTINE:
			g._resume_routine()
		spot.action("interact").interact(p.player_interaction_component)
		served += 1
	t.check(job.run.has("served:hoard") and job.run.is_caper_done("serve_hoard"), "museum: serving Hoard a drink is a caper")
	t.check(job.run.is_caper_done("three_served") and not p.has_item("drinks"), "museum: three drinks served, the tray's empty")


func _check_toast(job: Job, lvl: MuseumLevel, party: MuseumParty, p: Moth) -> void:
	Engine.time_scale = 3.0
	t.check(lvl.chatter_on(), "museum: the party chatters before the toast")
	t.check(party.start_toast(true) and job.run.is_caper_done("gong"), "museum: the gong starts an early toast")
	t.check(not lvl.chatter_on(), "museum: the chatter stops for the toast")
	t.check(party.ron.state == Person.State.WAIT, "museum: the guard leaves his desk for the toast")
	var up: bool = await t._until(func(): return party.hoard.global_position.distance_to(lvl.points["toast_hoard"]) < 1.0, 40.0)
	t.check(up, "museum: Hoard climbs to the balcony (%s)" % party.hoard.global_position)
	t.check(await t._until(func(): return job.run.has("guard_left_desk"), 20.0), "museum: the desk is empty")
	# Stand beside Hoard for the photo.
	p.set_disguise("guest")
	p.global_position = lvl.points["toast_hoard"] + Vector3(2.0, 0.9, 0.3)
	t.check(await t._until(func(): return job.run.has("in_photo"), 40.0), "museum: the player is in the photo")
	t.check(await t._until(func(): return not party.toasting, 15.0), "museum: the toast ends")
	t.check(lvl.chatter_on(), "museum: and the chatter starts again")
	p.set_disguise("")
	p.global_position = lvl.start_transform("steps").origin
	Engine.time_scale = 1.0
	await t._physics(2)


func _check_plinth(job: Job, lvl: MuseumLevel, p: Moth) -> void:
	# The north lasers blink; the others don't.
	var north: LaserGate = lvl.get_node("Lasers_rotunda_north")
	var south: LaserGate = lvl.get_node("Lasers_rotunda_south")
	var seen_off := false
	for i in 240:
		await t._physics(1)
		if not north.is_on():
			seen_off = true
			break
	t.check(seen_off and south.is_on(), "museum: the north lasers blink off while the rest stay on")
	# The curator's maintenance switch turns off the lasers and the camera.
	lvl.get_node("Maintenance").action("interact").interact(p.player_interaction_component)
	t.check(not south.is_on() and not lvl.rotunda_cam.is_working() and job.run.has("maintenance_mode"), "museum: the maintenance switch turns off the rotunda's lasers and camera")
	lvl.get_node("Maintenance").action("interact").interact(p.player_interaction_component)
	t.check(south.is_on() and lvl.rotunda_cam.is_working(), "museum: and back on")
	# Lights out: the plant room's breaker takes the lasers and cameras, and
	# the guard sets off to fix it.
	lvl.set_power(false)
	t.check(not south.is_on() and not lvl.rotunda_cam.is_working() and job.run.has("lights_out"), "museum: the breaker turns off the lasers and cameras")
	t.check(lvl.party.ron.state == Person.State.FIX_FUSE, "museum: the guard goes to the plant room")
	lvl.set_power(true)
	t.check(south.is_on(), "museum: the lasers come back with the power")
	# Take the statue, leave a toadstool.
	p.add_item("toadstool")
	var use := lvl.treasure_stand.action("interact")
	use.interact(p.player_interaction_component)
	t.check(p.has_item("statue") and job.run.has("took_treasure"), "museum: the statue goes in the bag")
	use.interact(p.player_interaction_component)
	t.check(job.run.is_caper_done("toadstool") and not p.has_item("toadstool"), "museum: a toadstool takes its place")
	# Caught: the statue goes back and the toadstool goes.
	p.take_item("statue")
	job.run.drop_treasure()
	lvl.return_treasure()
	t.check(lvl._treasure_model != null and lvl._toadstool == null, "museum: the statue goes back on the plinth")


func _check_skylight(job: Job, lvl: MuseumLevel, p: Moth) -> void:
	var sky: UsableBody = lvl.get_node("Skylight")
	p.global_position = Vector3(0, MuseumLevel.TOP + 0.95, -9.2)
	await t._physics(10)
	t.check(p.global_position.y > MuseumLevel.TOP, "museum: the skylight holds the player up")
	sky.action("interact").interact(p.player_interaction_component)
	t.check(lvl.skylight_open and job.run.has("opened_skylight"), "museum: the skylight lifts")
	t.check(await t._until(func(): return job.run.has("dropped_through_skylight"), 3.0), "museum: dropping through the skylight is a caper")
	await t._physics(30)
	t.check(p.global_position.y > lvl.PLINTH_TOP and p.global_position.y < 2.5, "museum: the player lands on the plinth (%s)" % p.global_position)
	t.check(not job.run.has("tripped_laser"), "museum: inside the lasers without tripping them")
	lvl.silence_alarm()
	p.global_position = lvl.start_transform("steps").origin
	await t._physics(2)


## The guard's birthday: from the gossip to the escape.
func _check_birthday_lead(job: Job, lvl: MuseumLevel, party: MuseumParty, p: Moth) -> void:
	var lead := job.run.job.lead("guards_birthday")
	t.check(job.run.lead_text(lead) == lead.steps[1][0], "museum: with the desk empty, the lead asks for the code")
	var door: HouseDoor = lvl.doors.security_door
	door.person_open(party.ron)
	door.locked = false
	door.person_close(party.ron)
	t.check(door.locked, "museum: the security door locks again behind the guard")
	t.check(not lvl.pad.enter("1234") and lvl.pad.enter("0912"), "museum: the birthday opens the keypad")
	t.check(not lvl.doors.security_door.locked, "museum: the security door unlocks")
	lvl.get_node("Switch_lasers").action("interact").interact(p.player_interaction_component)
	lvl.get_node("Switch_cameras").action("interact").interact(p.player_interaction_component)
	var south: LaserGate = lvl.get_node("Lasers_rotunda_south")
	t.check(not south.is_on() and not lvl.rotunda_cam.is_working(), "museum: the desk panel turns off the lasers and cameras")
	t.check(job.run.is_caper_done("desk_lasers"), "museum: switching off the lasers at the desk is a caper")
	# Walk in through the arch: no lasers trip.
	p.global_position = Vector3(0, 0.9, -5.5)
	await t._physics(3)
	p.global_position = Vector3(0.9, 0.9, -8.0)
	await t._physics(5)
	t.check(not job.run.has("tripped_laser") and not lvl.alarm_ringing, "museum: no lasers trip with them switched off")
	lvl.treasure_stand.action("interact").interact(p.player_interaction_component)
	t.check(job.run.lead_text(lead) == lead.steps[5][0], "museum: the lead says to get out")
	# A snooze dart for the guard, then out: he's left asleep.
	party.ron.snooze()
	var done := [false]
	job.run.finished.connect(func(_r): done[0] = true)
	p.global_position = lvl.way_outs["roof"] + Vector3(0, 0.9, 0)
	t.check(await t._until(func(): return done[0], 3.0), "museum: reaching the roof with the statue ends the night")
	t.check(job.run.result().get("treasure", false), "museum: the founder goes home")
	t.check(job.run.lead_text(lead) == "" and job.run.lead_steps["guards_birthday"] == lead.steps.size(), "museum: the guard's birthday lead is finished")
	t.check(job.run.is_caper_done("guard_asleep") and job.run.is_caper_done("roof_exit"), "museum: left the guard asleep and left over the roof")
