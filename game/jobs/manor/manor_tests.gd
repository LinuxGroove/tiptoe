extends RefCounted
## Hoard Manor's own tests: the vault and its code in three pieces, Hoard's
## key (from the bedside table and from his chain), the secret bookcase, the
## coal chute, the fuse box, Pell's rounds, the disguises, and the "three
## pieces" lead from the diary to the escape, by records and state.

var t
var job: Job
var lvl: ManorLevel
var p: Moth
## The player's height upstairs.
const UP_FEET := 2.5 + 0.9


func run(p_t, _games: int) -> void:
	t = p_t
	job = t._make_job("gates", "manor")
	var ready := [false]
	job.level.navigation_ready.connect(func(): ready[0] = true)
	t.check(await t._until(func(): return ready[0], 40.0), "manor: the navigation bakes")
	await t._physics(3)
	lvl = job.level as ManorLevel
	p = job.player
	_test_layout()
	_test_navigation()
	await _test_people()
	await _test_disguises()
	await _test_secret_and_chute()
	await _test_power_and_alarm()
	await _test_key()
	await _test_three_pieces()
	job.queue_free()
	await t._frames(2)


func _use(body: UsableBody) -> void:
	body.action("interact").interact(p.player_interaction_component)


func _test_layout() -> void:
	t.check(lvl.starts.size() == 4, "manor: four start points")
	t.check(lvl.doors.vault_door.locked and not lvl.doors.vault_door.pickable and not lvl.doors.vault_door.people_open, "manor: the vault door is locked, can't be picked, and nobody walks through it")
	t.check(lvl.in_house(Vector3(10, -1.5, -2)) and lvl.in_house(Vector3(0, 3.5, 4)) and not lvl.in_house(Vector3(0, 1, 15)), "manor: the cellar and upstairs are in the house, the forecourt isn't")
	t.check(lvl.indoors(Vector3(6, 1, 27)) and not lvl.in_house(Vector3(6, 1, 27)), "manor: the guardhouse is indoors but not the house")
	t.check(lvl.masking_at(Vector3(-10, -2, -4)) > 0.5, "manor: the boiler drowns out steps in the coal store")
	t.check(p.has_item("darts") and p.has_item("pry_bar") and not p.has_item("snooze_darts"), "manor: the starting bag holds the mastery 0 gadgets")


func _path(a: Vector3, b: Vector3) -> PackedVector3Array:
	return NavigationServer3D.map_get_path(job.get_world_3d().navigation_map, a, b, true)


func _reaches(a: String, b: String) -> bool:
	var path := _path(lvl.points[a], lvl.points[b])
	return not path.is_empty() and path[path.size() - 1].distance_to(lvl.points[b]) < 0.8


func _test_navigation() -> void:
	for pair in [["dining_seat", "library_chair"], ["library_chair", "vault_gloat"], ["vault_gloat", "bed_side"],
			["bedroom_window", "dining_seat"], ["sideboard", "pantry"], ["pantry", "kitchen_door_in"],
			["front_door_in", "cellar_top"], ["cellar_top", "pell_room"], ["pell_room", "sideboard"],
			["gatehouse", "turning_circle"], ["turning_circle", "east_lawn"], ["east_lawn", "library_side"],
			["kitchen_yard", "west_garden"], ["west_garden", "terrace"], ["terrace", "greenhouse"],
			["greenhouse", "east_garden"], ["sideboard", "fuse_box"], ["gate_in", "drive_mid"]]:
		t.check(_reaches(pair[0], pair[1]), "manor: people can walk from %s to %s" % pair)
	# Nobody knows about the secret stair: the way to the vault goes round by
	# the cellar door.
	var path := _path(lvl.points["library_chair"], lvl.points["vault_gloat"])
	var secret := false
	for q in path:
		if q.x > 5.1 and q.x < 6.9 and q.z > -4.5 and q.z < -0.3 and q.y > -2.0:
			secret = true
	t.check(not path.is_empty() and not secret, "manor: people go down by the cellar stair, not the secret one")


func _test_people() -> void:
	var hoard := lvl.hoard
	var pell := lvl.pell
	t.check(hoard.voice == "hoard" and lvl.voice_info().hoard.kokoro == "am_onyx", "manor: Hoard has his own voice")
	t.check(hoard.has_key, "manor: Hoard wears his key")
	for n in ["Ogden", "Hattie"]:
		var g: Person = lvl.get_node(n)
		t.check(g.torch != null and g.answers_alarm, "manor: %s carries a torch and answers the alarm" % n)
	t.check(lvl.get_node("Duke") is Dog, "manor: Duke guards the grounds")
	t.check("Who's there?" in hoard.all_lines() and "My key! Where's my key? PELL!" in hoard.all_lines(), "manor: everything Hoard says can be recorded")
	t.check(await t._until(func(): return hoard.rig.current_clip() == "sit", 15.0), "manor: Hoard sits down to dinner")
	# Hoard's "Who's there?".
	hoard.say("Who's there?")
	t.check(job.run.has("hoard_whos_there"), "manor: Hoard asking who's there is a caper")
	# The doorbell brings Pell to the front door.
	StealthNoise.make(lvl, Vector3(1.0, 1.3, 8.1), 40.0, "bell", p)
	t.check(pell.state == Person.State.ANSWER_DOOR and hoard.state != Person.State.ANSWER_DOOR, "manor: Pell answers the bell, Hoard doesn't")
	# The night guard at the door gets let in.
	p.set_disguise("guard")
	t.check(lvl.at_front_door(pell, p) and job.run.has("let_in_as_guard"), "manor: Pell lets the night guard in")
	p.global_position = Vector3(-2, 0.9, 4)
	t.check(lvl.expects(pell, p), "manor: the night guard Pell let in is welcome in the hall")
	p.global_position = Vector3(10, 3.4, -4)
	t.check(not lvl.expects(pell, p), "manor: but not upstairs")
	p.set_disguise("")
	# Ogden's gossip is a lead, but only if you're near enough to hear.
	var ogden: Person = lvl.get_node("Ogden")
	p.global_position = Vector3(-25, 0.9, 20)
	lvl.on_step(ogden, "overheard_key")
	t.check(not job.run.has("heard:key_bedside"), "manor: Ogden's gossip can't be heard from far off")
	p.global_position = ogden.global_position + Vector3(4, 0.9, 0)
	lvl.on_step(ogden, "overheard_key")
	t.check(job.run.lead_steps.has("bedtime"), "manor: overhearing Ogden finds the bedtime lead")
	pell._resume_routine()


func _test_disguises() -> void:
	var hoard := lvl.hoard
	var pell := lvl.pell
	var ogden: Person = lvl.get_node("Ogden")
	p.set_disguise("butler")
	p.global_position = Vector3(-2, 0.9, 4)
	await t._physics(2)
	t.check(lvl.expects(hoard, p) and lvl.expects(ogden, p), "manor: Hoard and the guards think nothing of a butler in the house")
	t.check(not lvl.expects(pell, p), "manor: Pell knows there's only one butler")
	p.global_position = Vector3(10, -1.6, -6)
	t.check(not lvl.expects(hoard, p), "manor: nobody belongs by the vault")
	p.global_position = Vector3(0, 0.9, 18)
	t.check(not lvl.expects(ogden, p), "manor: a butler on the lawn looks odd")
	p.set_disguise("guard")
	t.check(lvl.expects(ogden, p), "manor: a guard on the lawn doesn't")
	var cam: SecurityCamera = lvl.get_node("Camera_drive")
	t.check("guard" in cam.accepts and lvl.disguise_fits("guard", p.global_position), "manor: the cameras on the grounds ignore the guard's look")
	p.set_disguise("")


func _test_secret_and_chute() -> void:
	# The red book slides the bookcase aside, opening the way for the player.
	var book: UsableBody = lvl.get_node("RedBook")
	var block: CollisionShape3D = lvl._secret_block.get_child(0)
	t.check(not block.disabled, "manor: the secret doorway is shut")
	_use(book)
	await t._physics(3)
	t.check(lvl.bookcase.is_open and block.disabled and job.run.has("opened:secret_bookcase"), "manor: pulling the red book opens the secret bookcase")
	_use(lvl.get_node("SecretLever"))
	await t._physics(3)
	t.check(not lvl.bookcase.is_open and not block.disabled, "manor: the lever behind it closes it again")
	# The coal chute: pry the hatch, slide down into the coal store, climb out.
	p.global_position = lvl.way_outs["coal_chute"] + Vector3(0, 0.9, 0)
	await t._physics(3)
	var hatch: UsableBody = lvl.get_node("CoalHatch")
	_use(hatch)
	t.check(job.run.has("pried:coal_hatch") and not job.run.has("coal_chute_down"), "manor: the pry bar opens the coal hatch")
	_use(hatch)
	await t._physics(4)
	t.check(job.run.has("coal_chute_down") and job.run.has("entered_cellar"), "manor: down the coal chute into the cellar")
	t.check(job.run.has("entered_by:coal_chute"), "manor: getting in by the chute counts as the chute")
	_use(lvl.get_node("ChuteMouth"))
	await t._physics(4)
	t.check(not lvl.in_house(p.global_position) and p.global_position.distance_to(lvl.way_outs["coal_chute"]) < 2.5, "manor: and back up it to the kitchen yard")


func _test_power_and_alarm() -> void:
	var pell := lvl.pell
	var hattie: Person = lvl.get_node("Hattie")
	p.global_position = Vector3(-25, 0.9, 20)
	for who in [pell, hattie]:
		who.suspicion = 0.0
		who._resume_routine()
	await t._physics(2)
	lvl.set_power(false)
	t.check(not lvl.lights_on("hall") and not lvl.lights_on("drive") and not lvl.lights_on("anteroom"), "manor: the fuse box puts out the house and the grounds")
	t.check(not lvl.gate_a.is_on() and not lvl.gate_b_high.is_on(), "manor: and the laser gates")
	t.check(not lvl.get_node("Camera_cellar").is_working(), "manor: and the cameras")
	t.check(pell.state == Person.State.FIX_FUSE and hattie.state == Person.State.FIX_FUSE, "manor: Pell and Hattie go to fix it")
	lvl.set_power(true)
	t.check(lvl.lights_on("hall") and lvl.gate_b_high.is_on(), "manor: the power comes back")
	pell._resume_routine()
	hattie._resume_routine()
	# The laser switch in the study turns both gates off.
	var panel: UsableBody = lvl.get_node("Switch_lasers")
	_use(panel)
	t.check(not lvl.gate_b_high.is_on() and not lvl.gate_b_low.is_on() and job.run.has("lasers_off"), "manor: the study's panel switches the lasers off")
	_use(panel)
	t.check(lvl.gate_b_high.is_on(), "manor: and on again")
	# The alarm switch in the pantry, and Pell turning it back on.
	_use(lvl.alarm_panel)
	t.check(not lvl.alarm_armed and job.run.has("alarm_off"), "manor: the pantry switch turns the alarm off")
	lvl.on_step(pell, "check_alarm")
	t.check(lvl.alarm_armed, "manor: Pell turns it back on when he checks")
	# Pell's rounds lock the doors behind him.
	lvl.doors.kitchen_door.locked = false
	lvl.on_step(pell, "lock_kitchen")
	lvl.on_step(pell, "lock_cellar")
	t.check(lvl.doors.kitchen_door.locked and lvl.doors.cellar_door.locked, "manor: Pell locks the back door and the cellar")


func _test_key() -> void:
	var hoard := lvl.hoard
	# Bedtime: the key goes on the bedside table, and he snores.
	p.global_position = Vector3(8.6, UP_FEET, -3)
	await t._physics(2)
	lvl.on_step(hoard, "key_off")
	await t._physics(1)
	var key := lvl.get_node_or_null("Pickup_hoard_key") as UsableBody
	t.check(key != null and not hoard.has_key, "manor: Hoard leaves his key on the bedside table at bedtime")
	if key:
		_use(key)
	t.check(p.has_item("hoard_key") and job.run.has("took:hoard_key"), "manor: the key can be taken")
	t.check(int(job.run.lead_steps.get("bedtime", 0)) >= 2, "manor: the bedtime lead moves on past the key")
	# Morning: he misses it and the alarm goes.
	lvl.on_step(hoard, "key_on")
	t.check(job.run.has("hoard_missed_key") and lvl.alarm_ringing, "manor: Hoard misses his key and the alarm rings")
	lvl.silence_alarm()
	# The key opens the vault door.
	p.take_item("hoard_key")
	p.add_item("hoard_key")
	var door: HouseDoor = lvl.doors.vault_door
	door.action("interact").interact(p.player_interaction_component)
	t.check(not door.locked and door.is_open and job.run.has("unlocked:vault_door") and job.run.has("vault_open"), "manor: Hoard's key opens the vault")
	door.person_close(null)
	door.locked = true
	p.take_item("hoard_key")
	# A snooze dart, and the key comes off his chain.
	hoard.has_key = true
	hoard.snooze()
	await t._physics(2)
	var pocket: UsableBody = hoard.get_node("Pocket")
	t.check(not pocket.action("interact").is_disabled, "manor: a sleeping Hoard's key can be lifted")
	_use(pocket)
	t.check(p.has_item("hoard_key") and not hoard.has_key and job.run.has("lifted_key"), "manor: lifting the key off his chain")
	await t._physics(2)
	t.check(pocket.action("interact").is_disabled, "manor: and there's nothing more to lift")
	p.take_item("hoard_key")
	hoard._wake()


## The "three pieces" lead from the diary to the escape: notes, the safe,
## the keypad, the vault, the card and the way out.
func _test_three_pieces() -> void:
	var lead := job.job.lead("three_pieces")
	_use(lvl.get_node("Note_hoard_diary"))
	t.check(job.run.lead_steps.has("three_pieces") and job.run.is_caper_done("read_diary"), "manor: the diary finds the three pieces lead")
	_use(lvl.get_node("Note_pantry_note"))
	t.check(job.run.lead_text(lead) == lead.steps[1][0], "manor: Pell's note moves the lead on to the safe")
	_use(lvl.get_node("Portrait"))
	t.check(job.run.has("found_safe"), "manor: there's a safe behind the portrait")
	t.check(not lvl.safe_keypad.enter("1234") and lvl.safe_keypad.enter("0612"), "manor: the safe opens on Hoard's birthday")
	await t._physics(1)
	var safe_note := lvl.get_node_or_null("Note_safe_note") as UsableBody
	t.check(safe_note != null, "manor: the last piece is in the safe")
	if safe_note:
		_use(safe_note)
	t.check(job.run.has("found_whole_code") and job.run.is_caper_done("three_pieces"), "manor: all three pieces found")
	t.check(job.run.lead_text(lead) == lead.steps[2][0], "manor: the lead moves on to the vault")
	# The keypad opens the vault.
	t.check(not lvl.vault_keypad.enter("731924") and lvl.doors.vault_door.locked, "manor: a wrong code keeps the vault shut")
	t.check(lvl.vault_keypad.enter("731942") and not lvl.doors.vault_door.locked, "manor: 731942 unlocks the vault")
	p.set_disguise("butler")
	p.global_position = Vector3(10, -1.6, -4.6)
	lvl.doors.vault_door.action("interact").interact(p.player_interaction_component)
	t.check(job.run.is_caper_done("butler_did_it"), "manor: the butler opened the vault")
	p.set_disguise("")
	# Take the treasures, leave a card.
	_use(lvl.get_node("Pickup_thank_you_card"))
	_use(lvl.treasure_stand)
	t.check(p.has_item("vault") and job.run.has("took_treasure"), "manor: the town's treasures are in the bag")
	t.check(lvl.treasure_stand.action("interact").interaction_text == "Leave the thank-you card", "manor: the empty table offers to take the card")
	_use(lvl.treasure_stand)
	t.check(job.run.is_caper_done("thank_you") and not p.has_item("thank_you_card"), "manor: a thank-you card left in the vault")
	# Caught on the way out: the treasures go back on the table.
	job._on_caught(lvl.pell)
	await t._until(func(): return not p.is_movement_paused, 5.0)
	t.check(not p.has_item("vault") and lvl.treasure_stand.action("interact").interaction_text == "Take the town's treasures", "manor: caught, the treasures go back")
	_use(lvl.treasure_stand)
	# Every light off, and out by the gates.
	lvl.set_power(false)
	var finished := [false]
	job.run.finished.connect(func(_r): finished[0] = true)
	p.global_position = lvl.way_outs["gates"] + Vector3(0, 0.9, 0)
	t.check(await t._until(func(): return finished[0], 3.0), "manor: out of the gates with the treasures ends the night")
	var res := job.run.result()
	t.check(res.get("treasure", false), "manor: the result has the treasures")
	t.check("manor_dark" in res.capers, "manor: leaving the manor dark is a caper")
	t.check(job.run.lead_text(lead) == "", "manor: the three pieces lead is finished")
