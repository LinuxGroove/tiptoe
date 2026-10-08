extends RefCounted
## The corner market's own tests: paths for the people, the cameras and the
## apron, the alarm and the office door closers, the power cut and the office
## lock, knocking in the apron, the deliveries bell, the roof hatch and the
## vent, the small capers, and the office code lead from start to finish.

var t
var job: Job
var lvl: MarketLevel
var p: Moth
var jr: JobRun


func run(runner, _games: int) -> void:
	t = runner
	Engine.time_scale = 3.0
	job = t._make_job("street", "market")
	var ready := [false]
	job.level.navigation_ready.connect(func(): ready[0] = true)
	t.check(await t._until(func(): return ready[0], 30.0), "market: the navigation mesh bakes")
	await t._physics(5)
	lvl = job.level
	p = job.player
	jr = job.run
	_test_paths()
	await _test_routines()
	await _test_cameras_and_apron()
	await _test_power_cut()
	await _test_knock()
	await _test_deliveries_bell()
	await _test_hatch_and_vent()
	await _test_small_capers()
	await _test_code_lead()
	Engine.time_scale = 1.0
	job.queue_free()
	await t._frames(2)


func _use(node: UsableBody, input := "interact") -> void:
	node.action(input).interact(p.player_interaction_component)


func _put(at: Vector3) -> void:
	p.global_position = at + Vector3(0, 0.9, 0)
	p.velocity = Vector3.ZERO


## Stops (or starts) Dev and Mrs Pruitt, for tests that aren't about them.
func _freeze_people(frozen: bool) -> void:
	for person in [lvl.dev, lvl.pruitt]:
		person.process_mode = Node.PROCESS_MODE_DISABLED if frozen else Node.PROCESS_MODE_INHERIT


func _test_paths() -> void:
	for pair in [["aisle_a", "bins"], ["desk", "till"], ["desk", "fuse_box"], ["desk", "back_check"],
			["till", "stock_table"], ["front_door_in", "front_step"], ["office_door_in", "office_door_out"], ["aisle_c", "stock_shelf"]]:
		var path: PackedVector3Array = t._nav_path(job, pair[0], pair[1])
		var ok := not path.is_empty() and path[path.size() - 1].distance_to(lvl.points[pair[1]]) < 0.8
		t.check(ok, "market: people can walk from %s to %s" % pair)


func _test_routines() -> void:
	var pruitt: Person = lvl.pruitt
	t.check(await t._until(func(): return pruitt.rig.current_clip() == "sit" and pruitt.global_position.distance_to(lvl.points["desk"]) < 1.0, 20.0),
		"market: Mrs Pruitt sits down at her desk")
	t.check(await t._until(func(): return lvl.dev.global_position.distance_to(lvl.points["aisle_a"]) < 1.0, 10.0), "market: Dev restocks the first aisle")
	t.check(lvl.doors.office_door.locked and lvl.doors.office_front.locked and lvl.doors.shop_door.locked, "market: the office and shop doors start locked")


## The apron gets past the cameras on the shop floor; without it the camera
## rings the alarm, Mrs Pruitt runs out leaving the office doors to their
## closers, and they shut and lock again.
func _test_cameras_and_apron() -> void:
	lvl.dev.process_mode = Node.PROCESS_MODE_DISABLED
	var cam: SecurityCamera = lvl.cams["floor"]
	_put(Vector3(-4.75, 0, 1.2))
	_use(lvl.get_node("Pickup_apron"))
	t.check(p.disguise == "staff" and jr.has("wore:staff"), "market: the spare apron is a staff disguise")
	t.check(lvl.disguise_fits("staff", Vector3(-3, 0.9, -8)) and not lvl.disguise_fits("staff", Vector3(7, 0.9, -8)), "market: staff belong in the stock room but not the office")
	t.check(not await t._until(func(): return lvl.alarm_ringing or cam.meter > 0.0, 12.0), "market: the cameras think nothing of staff")
	p.set_disguise("")
	t.check(await t._until(func(): return lvl.alarm_ringing, 15.0), "market: the floor camera rings the alarm")
	t.check(jr.has("alarm:camera"), "market: the alarm says it was a camera")
	t.check(lvl.pruitt.state == Person.State.INVESTIGATE, "market: Mrs Pruitt answers the alarm")
	t.check(await t._until(func(): return lvl.doors.office_front.is_open or lvl.doors.office_door.is_open, 12.0), "market: she hurries out of the office")
	_put(lvl.way_outs["street"] + Vector3(-6, 0, 0))
	lvl.silence_alarm()
	t.check(await t._until(func(): return not lvl.doors.office_front.is_open and not lvl.doors.office_door.is_open, 45.0), "market: the office doors' closers shut them")
	t.check(lvl.doors.office_front.locked and lvl.doors.office_door.locked, "market: and lock them")
	lvl.dev.process_mode = Node.PROCESS_MODE_INHERIT


## The breaker: the cameras die, the office keypad's lock lets go, and Mrs
## Pruitt walks out the back to fix it, leaving the back door open.
func _test_power_cut() -> void:
	var pruitt: Person = lvl.pruitt
	# Dev stays out of her way (two people can block a doorway).
	lvl.dev.process_mode = Node.PROCESS_MODE_DISABLED
	await t._until(func(): return pruitt.state == Person.State.ROUTINE, 60.0)
	lvl.set_power(false)
	var dark := true
	for id in lvl.cams:
		dark = dark and not lvl.cams[id].is_working()
	t.check(dark and not lvl.lights_on("front") and jr.has("lights_out"), "market: the breaker kills the lights and the cameras")
	t.check(not lvl.doors.office_door.locked, "market: the office keypad's lock lets go with the power off")
	t.check(pruitt.state == Person.State.FIX_FUSE, "market: Mrs Pruitt goes to fix the power")
	var out: bool = await t._until(func(): return lvl.doors.front_door.is_open, 30.0)
	t.check(out, "market: she goes out the back door")
	if not out:
		printerr("  Pruitt state %d at %s target %s arrived %s power_off %s" % [pruitt.state, pruitt.global_position, pruitt._target, pruitt._arrived, lvl.power_off()])
	t.check(await t._until(func(): return not lvl.power_off(), 60.0), "market: she turns the power back on")
	t.check(lvl.cams["floor"].is_working() and lvl.lights_on("front"), "market: the lights and cameras come back")
	t.check(lvl.doors.front_door.is_open, "market: and the back door's left open")
	t.check(await t._until(func(): return lvl.doors.office_door.locked and not lvl.doors.office_door.is_open, 45.0), "market: the office door locks again once it's shut")
	lvl.dev.process_mode = Node.PROCESS_MODE_INHERIT
	# Her rounds lock the back door again.
	await t._until(func(): return pruitt.global_position.distance_to(lvl.points["front_door_in"]) > 2.0, 20.0)
	lvl.person_did(pruitt, "lock_back_door")
	t.check(not lvl.doors.front_door.is_open and lvl.doors.front_door.locked, "market: her rounds shut and lock the back door")


## Knocking on the office door in the apron sends Mrs Pruitt off to the till,
## with the door left open.
func _test_knock() -> void:
	var pruitt = lvl.pruitt
	var at_desk: bool = await t._until(func(): return pruitt.state == Person.State.ROUTINE and pruitt.current_step().at == "desk" and pruitt.global_position.distance_to(lvl.points["desk"]) < 1.0, 90.0)
	t.check(at_desk, "market: Mrs Pruitt is back at her desk")
	if not at_desk:
		printerr("  Pruitt state %d step %s at %s target %s" % [pruitt.state, pruitt.current_step(), pruitt.global_position, pruitt._target])
	p.set_disguise("staff")
	_put(lvl.points["office_door_out"] + Vector3(-0.6, 0, 0.4))
	_use(lvl.office_pad, "interact2")
	t.check(jr.has("knocked_office") and pruitt.state == Person.State.WAIT, "market: a knock brings her to the door")
	t.check(await t._until(func(): return jr.has("pruitt_to_till"), 25.0), "market: staff at the door send her to count the till")
	t.check(lvl.doors.office_door.is_open, "market: she leaves the office door open")
	t.check(await t._until(func(): return pruitt.global_position.distance_to(lvl.points["till"]) < 1.5, 30.0), "market: she goes to the till")


## Dev answers the deliveries bell and lets the new starter in.
func _test_deliveries_bell() -> void:
	var dev: Person = lvl.dev
	await t._until(func(): return dev.state == Person.State.ROUTINE, 30.0)
	p.set_disguise("staff")
	_put(lvl.points["front_step"])
	await t._physics(2)
	_use(lvl.get_node("Doorbell"))
	t.check(jr.has("doorbell_rung") and dev.state == Person.State.ANSWER_DOOR, "market: Dev answers the deliveries bell")
	t.check(await t._until(func(): return jr.has("let_in_as_staff"), 40.0), "market: he lets the new starter in")
	t.check(lvl.doors.front_door.is_open, "market: and leaves the back door open")
	t.check(jr.is_caper_done("new_starter"), "market: being let in is a caper")
	t.check(await t._until(func(): return jr.is_caper_done("on_shift"), 5.0), "market: Dev greets a colleague on shift")
	if not jr.has("on_shift"):
		printerr("  Dev state %d at %s rig yaw %.2f, player at %s vis %.2f" % [dev.state, dev.global_position, dev.rig.rotation.y, p.global_position, p.visibility])
	var lead: LeadDef = job.job.lead("new_starter")
	jr.record("read:job_ad")
	t.check(jr.lead_text(lead) == lead.steps[3][0], "market: the new starter lead skips the steps already done")


func _test_hatch_and_vent() -> void:
	_freeze_people(true)
	p.set_disguise("")
	var hatch = lvl.hatch
	_put(hatch.above)
	await t._physics(3)
	_use(hatch)
	t.check(hatch.locked and not hatch.is_open, "market: the hatch is padlocked")
	hatch.unlock()
	_use(hatch)
	t.check(hatch.is_open, "market: then it opens")
	_use(hatch)
	await t._physics(3)
	t.check(p.global_position.y < 1.5 and lvl.in_house(p.global_position), "market: climbing down lands in the stock room")
	t.check(jr.has("entered_by:roof_hatch") and jr.is_caper_done("hatch"), "market: in through the roof hatch")
	_use(lvl.get_node("Ladder"))
	await t._physics(2)
	t.check(p.global_position.y > JobLevel.STOREY, "market: the ladder climbs back onto the roof")
	_put(Vector3(3.4, 0.9, -10))
	var vent: UsableBody = lvl.get_node("VentStock")
	_use(lvl.get_node("VentOffice"))
	t.check(not jr.has("crawled_vent") and p.global_position.x < 4.0, "market: the office side of the vent won't open first")
	_use(vent)
	t.check(jr.has("vent_open"), "market: the vent cover unscrews")
	_use(vent)
	await t._physics(2)
	t.check(lvl.areas["office"].has_point(p.global_position) and jr.is_caper_done("vent"), "market: crawling through the vent comes out in the office")
	_use(lvl.get_node("VentOffice"))
	t.check(p.global_position.x < 4.0, "market: and back")
	_freeze_people(false)


func _test_small_capers() -> void:
	_freeze_people(true)
	for c in lvl.carts:
		_use(c)
	t.check(jr.has("carts_stacked") and jr.is_caper_done("carts"), "market: stacking the carts")
	_use(lvl.get_node("Pickup_melon"))
	t.check(p.has_item("melon") and not lvl.till.action("interact2").is_disabled, "market: carrying the melon offers it to the till")
	_use(lvl.till, "interact2")
	t.check(jr.is_caper_done("melon") and not p.has_item("melon"), "market: a melon on the till")
	_use(lvl.bottle_machine)
	t.check(jr.is_caper_done("recycling"), "market: thanked for recycling")
	var peas: HideSpot = lvl.get_node("Hide_freezer")
	_use(peas)
	t.check(p.hiding == peas and jr.is_caper_done("freezer"), "market: hiding behind the frozen peas")
	p.leave_hiding()
	_use(lvl.camera_switch)
	t.check(jr.has("cameras_off") and not lvl.cams["till"].switched_on, "market: the monitor switches the cameras off")
	lvl.person_did(lvl.pruitt, "check_cameras")
	t.check(lvl.cams["till"].switched_on and lvl.camera_switch.get_meta("on"), "market: Mrs Pruitt notices at her monitor and switches them back on")
	for id in lvl.cams:
		lvl.cams[id].stun()
	await t._physics(2)
	t.check(jr.has("camera_darted:stock") and jr.is_caper_done("dart_cameras"), "market: darting every camera")
	_freeze_people(false)


## The office code lead: the notice by the back door, the note under the
## till, the keypad, the ledger (swapped for the cookbook), and away.
func _test_code_lead() -> void:
	_freeze_people(true)
	_cameras_off()
	var lead: LeadDef = job.job.lead("the_code")
	_use(lvl.get_node("Note_staff_notice"))
	t.check(jr.lead_steps.has("the_code"), "market: the staff notice finds the office code lead")
	_use(lvl.get_node("Note_till_note"))
	t.check(jr.is_caper_done("till_note") and jr.lead_text(lead) == lead.steps[2][0], "market: the note under the till moves the lead on")
	t.check(not lvl.office_pad.enter("1234") and lvl.doors.office_door.locked, "market: a wrong code keeps the office shut")
	t.check(lvl.office_pad.enter(MarketLevel.OFFICE_CODE) and not lvl.doors.office_door.locked, "market: the code from the note opens it")
	t.check(jr.is_caper_done("by_code") and jr.lead_text(lead) == lead.steps[3][0], "market: the code is a caper and a lead step")
	_put(Vector3(6, 0, -9))
	await t._physics(3)
	t.check(jr.has("entered_office"), "market: in the office")
	_use(lvl.treasure_stand)
	t.check(p.has_item("ledger") and jr.has("took_treasure"), "market: the ledger is in the bag")
	_use(lvl.get_node("Pickup_cookbook"))
	t.check(lvl.treasure_stand.action("interact").interaction_text == "Leave the cookbook", "market: the empty desk offers to take the cookbook")
	_use(lvl.treasure_stand)
	t.check(jr.is_caper_done("cookbook"), "market: the ledger swapped for a cookbook")
	var finished := [false]
	jr.finished.connect(func(_r): finished[0] = true)
	_put(lvl.way_outs["street"])
	t.check(await t._until(func(): return finished[0], 3.0), "market: getting back to the street with the ledger ends the night")
	t.check(jr.result().get("treasure", false) and jr.lead_steps["the_code"] == lead.steps.size(), "market: the lead is done and the ledger is home")
	t.check(jr.is_caper_done("money"), "market: the rent money was left alone")


func _cameras_off() -> void:
	lvl.get_tree().call_group("cameras", "set_switched_on", false)
	lvl.silence_alarm()
