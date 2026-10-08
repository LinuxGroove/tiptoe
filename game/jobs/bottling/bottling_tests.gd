extends RefCounted
## The bottling plant's own tests: the line (its levers, the emergency
## stop, the din, riding the belt, people coming to restart it, the cog
## that only comes off when it's stopped), the crane, the ladders, the
## kettle, the disguise, and the "Lights out" lead from start to finish.


func run(t, _games: int) -> void:
	Engine.time_scale = 3.0
	await _test_machines(t)
	await _test_lights_out(t)
	Engine.time_scale = 1.0


func _make(t, start: String) -> Job:
	var job: Job = t._make_job(start, "bottling")
	var ready := [false]
	job.level.navigation_ready.connect(func(): ready[0] = true)
	t.check(await t._until(func(): return ready[0], 30.0), "the bottling plant's navigation bakes")
	await t._physics(5)
	return job


## Keeps the player out of everyone's way: up on the roof.
func _park(job: Job) -> void:
	job.player.global_position = job.level.start_transform("skylight").origin
	job.player.velocity = Vector3.ZERO


func _test_machines(t) -> void:
	var job := await _make(t, "skylight")
	var lvl: BottlingLevel = job.level
	var line := lvl.bottling_line
	var p := job.player
	var pic := p.player_interaction_component
	var run := job.run
	for pair in [["desk", "capper"], ["loading", "tea_eddie"], ["panel", "fuse_box"], ["office_lever", "dock_crates"], ["packing", "office_window"]]:
		var path: PackedVector3Array = t._nav_path(job, pair[0], pair[1])
		var end_ok := not path.is_empty() and path[path.size() - 1].distance_to(lvl.points[pair[1]]) < 0.8
		t.check(end_ok, "people can walk from %s to %s" % pair)
	# The running line drowns out footsteps near it.
	t.check(line.running and lvl.masking_at(Vector3(4, 1, 0)) >= 0.7, "the line starts out running, and loud")
	var step := StealthNoise.make(lvl, Vector3(4, 0.1, 1.6), 4.5, "step")
	t.check(step.loudness_at(lvl, Vector3(4, 1.5, 3.6)) == 0.0, "footsteps by the running line can't be heard 2 m away")
	# The cog can be reached from the cross catwalk and from the capper's step.
	var space := lvl.get_world_3d().direct_space_state
	var cog_at := lvl.cog.global_position + Vector3(0, 0.22, 0)
	for eye in [Vector3(2.4, BottlingLevel.UP + 1.5, BottlingLevel.BELT_Z), Vector3(0.5, 2.7, -3.1)]:
		var q := PhysicsRayQueryParameters3D.create(eye, cog_at, 3)
		q.exclude = [p.get_rid()]
		var hit := space.intersect_ray(q)
		t.check(not hit.is_empty() and hit.collider == lvl.cog and eye.distance_to(hit.position) < 2.0, "the cog is in reach from %s" % eye)
	# It won't come off while the line runs.
	lvl.cog.action("interact").interact(pic)
	t.check(line.has_cog and not run.has("took_treasure"), "the cog won't come off while the line runs")
	# Riding the belt in from the dock, crouched under the flap.
	p.global_position = Vector3(17.5, BottlingLine.BELT_TOP + 0.85, BottlingLevel.BELT_Z)
	p.try_crouch = true
	await t._physics(4)
	var x0 := p.global_position.x
	t.check(await t._until(func(): return run.has("rode_in"), 12.0), "a crouching rider rides the belt in through the flap")
	t.check(run.has("rode_conveyor") and p.global_position.x < x0 - 3.5, "the belt carries the player (%.1f to %.1f)" % [x0, p.global_position.x])
	p.try_crouch = false
	_park(job)
	await t._physics(3)
	# The kettle brings Rosa and Eddie for tea.
	lvl.kettle.action("interact").interact(pic)
	t.check(await t._until(func(): return run.has("tea_lure"), BottlingLevel.KETTLE_TIME + 2.0), "the whistling kettle calls a tea break")
	t.check(lvl.rosa.errand == "tea" or lvl.eddie.errand == "tea", "and someone goes for a cup")
	lvl.kettle.action("interact").interact(pic)
	t.check(run.has("had_tea"), "the player can have a cup too")
	t.check(run.has("worker_bothered"), "sending Rosa or Eddie for tea takes them from their posts")
	# The emergency stop, from a distance: someone comes and restarts it.
	lvl.estop.action("interact").interact(pic)
	t.check(not line.running and line.stopped_by == "estop" and run.has("line_stopped:estop"), "the emergency stop stops the line")
	t.check(run.has("estop_darted"), "from across the room it counts as a dart")
	t.check(lvl.masking.is_empty() and lvl.masking_at(Vector3(4, 1, 0)) == 0.0, "a stopped line is quiet")
	t.check(await t._until(func(): return lvl._restarter != null, 30.0), "someone comes to restart the line")
	t.check(await t._until(func(): return line.running, 80.0), "and gets it going again")
	# Platt's own lever brings Platt; the cog comes off while he climbs up.
	lvl.office_lever.action("interact").interact(pic)
	t.check(not line.running and run.has("line_stopped:office"), "the foreman's lever stops the line")
	t.check(await t._until(func(): return lvl._restarter == lvl.platt, 30.0), "Platt comes to restart his own lever")
	lvl.cog.action("interact").interact(pic)
	t.check(p.has_item("cog") and run.has("took_treasure") and not line.has_cog, "with the line stopped, the cog comes off")
	p.add_item("bottle_cap")
	lvl.cog.action("interact").interact(pic)
	t.check(run.has("cap_on_drive") and lvl.cap_left, "a bottle cap goes where the cog was")
	t.check(await t._until(func(): return lvl.alarm_ringing, 80.0), "starting the line without its cog raises the alarm")
	t.check(run.has("cog_missed") and run.has("line_jammed") and not line.running, "the line jams without its cog")
	lvl.silence_alarm()
	p.take_item("cog")
	lvl.return_treasure()
	t.check(line.has_cog and not lvl.cap_left, "a caught burglar's cog goes back on the capper")
	t.check(await t._until(func(): return line.running, 80.0), "and the line runs again")
	# The crane: a crate set down by the catwalk is a way up.
	var crane := lvl.crane
	crane.lever_swing.action("interact").interact(pic)
	t.check(crane.is_moving(), "the crane swings")
	t.check(await t._until(func(): return crane.at == "b", 15.0), "the crane sets its crate down by the catwalk")
	t.check(run.has("crane_bridge"), "that's recorded")
	p.global_position = crane.crate.global_position + Vector3(0, BottlingCrane.CRATE_SIZE.y + 0.85, -0.3)
	p.body.global_rotation.y = 0.0
	await t._physics(8)
	t.check(p.feet_position().y > 1.2, "the player stands on the crate")
	t.check(p._try_mantle(), "and can climb from it onto the catwalk")
	await t._until(func(): return p.feet_position().y > BottlingLevel.UP - 0.1 and not p._mantle_tween.is_running(), 3.0)
	await t._physics(4)
	t.check(run.has("crane_climb"), "climbing to the catwalk from the crate counts (feet at %.2f)" % p.feet_position().y)
	# Swing it back and let go mid-air: a crash that brings people.
	_park(job)
	crane.lever_swing.action("interact").interact(pic)
	await t._until(func(): return crane.crate_y > 2.0, 5.0)
	crane.lever_drop.action("interact").interact(pic)
	t.check(await t._until(func(): return run.has("crate_dropped"), 5.0), "letting go mid-air drops the crate")
	t.check(run.knocked > 0 and crane.dropped, "a dropped crate counts as knocked over")
	var looking := 0
	for w in [lvl.platt, lvl.rosa, lvl.eddie]:
		if w.state == Person.State.INVESTIGATE:
			looking += 1
	t.check(looking > 0, "the crash brings people to look (%d)" % looking)
	t.check(not crane.swing(), "a dropped crate can't be swung again")
	# A ladder up to the north catwalk.
	var lad: BottlingLadder = lvl.ladders["north"]
	p.global_position = lad.bottom + Vector3(0, 0.9, 0)
	await t._physics(2)
	lad.foot.action("interact").interact(pic)
	t.check(await t._until(func(): return lad._climbing == null and p.feet_position().y > BottlingLevel.UP - 0.2, 6.0), "the ladder climbs to the catwalk (feet at %.2f)" % p.feet_position().y)
	await t._physics(6)
	t.check(p.feet_position().y > BottlingLevel.UP - 0.2, "and the player stays up there")
	# The skylight lets the rope down.
	t.check(not lvl.rope.usable, "the rope waits for the skylight")
	lvl.skylight.action("interact").interact(pic)
	t.check(lvl.rope.usable and run.has("opened_skylight"), "lifting the skylight lets the rope down")
	job.queue_free()
	await t._frames(2)


## The "Lights out" lead: the tag on the switch house, the breaker, the cog
## in the dark, and away. Also the hard hat, and touching the floor.
func _test_lights_out(t) -> void:
	var job := await _make(t, "gate")
	var lvl: BottlingLevel = job.level
	var p := job.player
	var pic := p.player_interaction_component
	var run := job.run
	var lead := run.job.lead("lights_out")
	await t._physics(4)
	t.check(run.has("touched_floor"), "starting at the gate touches the floor")
	# The hard hat: welcome on the floor, not in the office, not with the cog.
	p.set_disguise("worker")
	p.global_position = Vector3(4, 0.9, 3.6)
	await t._physics(2)
	t.check(lvl.expects(lvl.rosa, p) and run.has("worker_on_floor"), "Rosa thinks nothing of a worker on the floor")
	p.global_position = Vector3(-10, BottlingLevel.UP + 0.9, -9)
	t.check(not lvl.expects(lvl.platt, p), "but a worker doesn't belong in Platt's office")
	p.set_disguise("")
	_park(job)
	lvl.get_node("Note_switch_tag").action("interact").interact(pic)
	t.check(run.lead_steps.has("lights_out"), "the switch house's tag finds the lead")
	p.global_position = Vector3(-10.5, 0.9, -14.5)
	await t._physics(3)
	t.check(run.lead_text(lead) == lead.steps[1][0], "getting into the switch house moves the lead on")
	lvl.get_node("FuseBox").action("interact").interact(pic)
	t.check(lvl.power_off() and not lvl.bottling_line.running and lvl.bottling_line.stopped_by == "power", "the main breaker stops the line")
	t.check(lvl.platt.state == Person.State.FIX_FUSE, "Platt goes to fix the power")
	t.check(not lvl.lights_on("line"), "the floor goes dark")
	_park(job)
	await t._physics(2)
	lvl.cog.action("interact").interact(pic)
	t.check(p.has_item("cog") and run.lead_text(lead) == lead.steps[3][0], "the cog comes off in the dark")
	p.add_item("cog")
	t.check(not lvl.expects(lvl.rosa, p), "nobody expects anyone to carry the drive cog about")
	p.take_item("cog")
	var finished := [false]
	run.finished.connect(func(_r): finished[0] = true)
	p.global_position = lvl.way_outs["gate"] + Vector3(0, 0.9, 0)
	t.check(await t._until(func(): return finished[0], 3.0), "reaching the gate with the cog ends the night")
	t.check(run.has("escaped_with_treasure") and int(run.lead_steps["lights_out"]) == lead.steps.size(), "and finishes the lead")
	t.check(not "no_floor" in run.capers and not "skylight_out" in run.capers, "walking out the gate is neither the floor caper nor the skylight")
	t.check("lights_out" in run.capers, "cutting the power is a caper")
	job.queue_free()
	await t._frames(2)
