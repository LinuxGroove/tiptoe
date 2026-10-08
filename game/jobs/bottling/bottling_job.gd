class_name BottlingJob
extends RefCounted
## Job 3: Hoard's lemonade bottling plant on the night shift, where the
## clock tower's last cog drives the bottling line.

static func make() -> JobDef:
	var j := JobDef.new()
	j.id = "bottling"
	j.title = "The bottling plant"
	j.place = "on the night shift"
	j.treasure = "The clock tower's last cog"
	j.treasure_item = "cog"
	j.treasure_model = "res://assets/kenney/factory-kit/cog-a.glb"
	j.music = "night_bottling"
	j.blurb = "Augustus Hoard took the clock tower's last cog \"for polishing\" and bolted it into his lemonade bottling line as a drive wheel. Kettleford's clock hasn't ticked since. Mr Platt the foreman watches from his office, and Rosa and Eddie mind the line. The cog only comes off with the line stopped. Bring it home."
	j.scene = "res://game/jobs/bottling/bottling_level.gd"
	j.par_time = 360.0
	j.start_points = [
		{"id": "gate", "title": "The yard gate", "mastery": 0},
		{"id": "dock", "title": "The loading dock", "mastery": 1},
		{"id": "skylight", "title": "The roof skylight", "mastery": 2},
	]
	j.gadgets = [
		{"id": "lockpicks", "title": "Lockpicks", "mastery": 0},
		{"id": "darts", "title": "Foam dart blaster", "mastery": 0},
		{"id": "noisemaker", "title": "Noisemaker", "mastery": 1, "count": 1},
		{"id": "snooze_darts", "title": "Snooze darts", "mastery": 2, "count": 1},
	]
	j.capers = [
		CaperDef.make("ride_belt", "Ride the conveyor",
			"Climb on the belt in the dock while the line's running. Crouch to fit through the flap.",
			"rode_conveyor"),
		CaperDef.make("foremans_lever", "Stop the line from the foreman's own lever",
			"It's in his office up on the mezzanine. He won't like it.",
			"line_stopped:office"),
		CaperDef.make("estop_dart", "Hit the emergency stop with a dart",
			"The red button on the capper. You don't have to be close.",
			"estop_darted"),
		CaperDef.make("crate_drop", "Drop a crate with the crane",
			"Swing the crane, then pull the other lever while the crate's in the air.",
			"crate_dropped"),
		CaperDef.make("crane_climb", "Climb to the catwalk on a crane crate",
			"Swing the crane to set its crate down by the dock catwalk, then climb.",
			"crane_climb"),
		CaperDef.make("shift_rota", "Read the shift rota",
			"It's pinned up in the break room.",
			"read:shift_rota"),
		CaperDef.make("cap_swap", "Swap the cog for a bottle cap",
			"There's a hopper of caps by the capper. Leave one where the cog was.",
			"cap_on_drive", ["took_treasure"]),
		CaperDef.make("tea_break", "Take a tea break in the break room",
			"Put the kettle on and have a cup. Mind who else turns up for one.",
			"had_tea"),
		CaperDef.make("tea_lure", "Call a tea break",
			"Rosa and Eddie never miss a whistling kettle.",
			"tea_lure"),
		CaperDef.make("hard_hat", "Walk the factory floor in a hard hat",
			"Hard hats and vests live in the locker room.",
			"worker_on_floor"),
		CaperDef.make("lights_out", "Cut the power at the switch house",
			"The main breaker's in the little brick hut in the north yard.",
			"lights_out"),
		CaperDef.make("nap", "Send the foreman for a nap",
			"A snooze dart will do it.",
			"snoozed:platt"),
		CaperDef.make("at_posts", "Leave Rosa and Eddie at their posts",
			"Don't make them come and look, don't send them for tea, and don't stop the line where they'll see to it.",
			"escaped_with_treasure", [], ["worker_bothered"], true),
		CaperDef.make("no_floor", "Never touch the floor",
			"Catwalks, crates and machines only. The roof's a good place to start.",
			"escaped_with_treasure", [], ["touched_floor"], true),
		CaperDef.make("skylight_out", "Leave through the skylight with the cog",
			"Climb the rope back up to the roof.",
			"escaped_with_treasure", ["left_by:skylight"], [], true),
		CaperDef.make("ghost", "Finish without being seen",
			"Stay in the dark and out of their sight. The machines hide your footsteps.",
			"ghost", [], [], true),
	]
	j.leads = [
		LeadDef.make("night_shift", "Night shift", "read:rosa_note", [
			["The staff door is on the south side of the hall. Its code is 1904.", "keypad:staff"],
			["Find a hard hat and vest in the locker room and put them on.", "wore:worker"],
			["Walk out onto the factory floor like you belong. Stand up straight.", "worker_on_floor"],
			["Pull the lever by the control panel at the west end to stop the line.", "line_stopped:lever"],
			["While they fuss at the panel, climb the capper's step and unbolt the cog.", "took_treasure"],
			["Keep out of sight with it, and get out the way you came.", "escaped_with_treasure"],
		]),
		LeadDef.make("lights_out", "Lights out", "read:switch_tag", [
			["Get into the switch house in the north yard. The lock's sticky: pick it.", "entered_switch_house"],
			["Pull the main breaker. The line stops, and Platt has to come out here.", "lights_out"],
			["Pick the fire door in the north wall and take the cog off the capper in the dark.", "took_treasure"],
			["Get out before the power comes back.", "escaped_with_treasure"],
		]),
		LeadDef.make("up_and_over", "Up and over", "read:crane_docket", [
			["Pull the crane's left lever to swing its crate over by the dock catwalk.", "crane_bridge"],
			["Climb the crate up onto the catwalk.", "crane_climb"],
			["Follow the catwalk into the hall to Platt's office. The side door's locked; pick it.", "entered_office"],
			["Pull Platt's own lever to stop the line.", "line_stopped:office"],
			["He'll come up to restart it. Step from the cross catwalk onto the capper and take the cog.", "took_treasure"],
			["Get out with the cog.", "escaped_with_treasure"],
		]),
	]
	return j
