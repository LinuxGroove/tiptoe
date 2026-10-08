class_name MuseumJob
extends RefCounted
## Job 5: the Hoard Museum's opening gala, where the founder's statue from
## Kettleford's square stands in the rotunda behind lasers and a camera.

static func make() -> JobDef:
	var j := JobDef.new()
	j.id = "museum"
	j.title = "The Hoard Museum"
	j.place = "at the gala"
	j.treasure = "The founder's statue"
	j.treasure_item = "statue"
	j.music = "night_museum"
	j.blurb = "Augustus Hoard is opening his Museum of Local Heritage with a gala, and most of the heritage is Kettleford's, borrowed without asking. The centrepiece is the founder's statue from the town square, on a plinth in the rotunda behind lasers and a camera. The hall is full of guests, waiters and gossip, and when Hoard gives his toast everyone turns to look at him. Bring the founder home."
	j.scene = "res://game/jobs/museum/museum_level.gd"
	j.par_time = 420.0
	j.start_points = [
		{"id": "steps", "title": "The front steps", "mastery": 0},
		{"id": "yard", "title": "The kitchen yard", "mastery": 1},
		{"id": "garden", "title": "The sculpture garden", "mastery": 2},
		{"id": "roof", "title": "The roof", "mastery": 3},
	]
	j.gadgets = [
		{"id": "lockpicks", "title": "Lockpicks", "mastery": 0},
		{"id": "darts", "title": "Foam dart blaster", "mastery": 0},
		{"id": "noisemaker", "title": "Noisemaker", "mastery": 1, "count": 1},
		{"id": "snooze_darts", "title": "Snooze darts", "mastery": 2, "count": 2},
	]
	j.capers = [
		CaperDef.make("serve_hoard", "Serve Hoard a drink",
			"Dress as a waiter, take a tray from the kitchen pass and offer him one.",
			"served:hoard"),
		CaperDef.make("buffet", "Eat from the buffet",
			"The vol-au-vents are at the back of the hall. Nobody's counting.",
			"ate_buffet"),
		CaperDef.make("pirate_flag", "Fly the pirate flag over the castle",
			"Take the flag off the pirate ship and put it on the model castle across the hall.",
			"flag_on_castle"),
		CaperDef.make("gossip", "Hear all the gossip",
			"Two pairs of guests are talking about everything. Stand near them and listen.",
			"heard_all_gossip"),
		CaperDef.make("desk_lasers", "Turn off the lasers from the security desk",
			"The panel is in the security office off the foyer. The guests know the door code.",
			"lasers_off"),
		CaperDef.make("photo", "Be in the photo at the toast",
			"Stand on the balcony beside Hoard when the flash goes off.",
			"in_photo"),
		CaperDef.make("guard_asleep", "Leave the guard asleep",
			"A snooze dart, then get out with the statue before he wakes up.",
			"escaped_with_treasure", ["left_guard_asleep"], [], true),
		CaperDef.make("toadstool", "Swap the statue for a toadstool",
			"There are toadstools in the sculpture garden. Put one on the plinth.",
			"toadstool_on_plinth", ["took_treasure"]),
		CaperDef.make("gong", "Ring the gong for an early toast",
			"Hoard can't resist the gong by the string quartet.",
			"early_toast"),
		CaperDef.make("shanty", "Get the quartet to play a sea shanty",
			"There's sheet music in the pirate gallery's sea chest. Swap it onto their stand.",
			"shanty"),
		CaperDef.make("three_served", "Serve drinks to three guests",
			"A tray of drinks makes you the most popular waiter in the hall.",
			"served_three"),
		CaperDef.make("skylight", "Drop in through the skylight",
			"The skylight over the statue doesn't lock. Mind the lasers on the way down.",
			"dropped_through_skylight"),
		CaperDef.make("no_alarm", "Never set off the alarm",
			"Cameras and lasers ring it. Keep clear of both, or switch them off.",
			"escaped_with_treasure", [], ["alarm"], true),
		CaperDef.make("roof_exit", "Leave over the roof",
			"Get back up to the roof with the statue and go.",
			"escaped_with_treasure", ["escaped_from:roof"], [], true),
		CaperDef.make("ghost", "Finish without being seen",
			"Disguises help. So does the dark.",
			"ghost", [], [], true),
	]
	j.leads = [
		LeadDef.make("short_staffed", "Short-staffed", "read:staff_notice", [
			["Spare jackets are in the staff room lockers, next to the kitchen. Put one on.", "wore:waiter"],
			["Take a tray of drinks from the kitchen pass. A waiter with a tray is a waiter at work.", "took:drinks"],
			["The service key hangs by the kitchen's back door. Take it.", "took:service_key"],
			["The service door is in the store room by the kitchen. Let yourself into the rotunda.", "entered_rotunda"],
			["Knock out the camera with a dart, then step through the far lasers when they blink off.", "took_treasure"],
			["Get out with the statue.", "escaped_with_treasure"],
		]),
		LeadDef.make("guards_birthday", "The guard's birthday", "heard:guard_code", [
			["The security office is off the foyer. Wait for the guard to go on his rounds.", "guard_left_desk"],
			["Key in 0912 on the keypad by the security office door.", "keypad:security"],
			["Switch off the lasers at the panel behind the desk.", "lasers_off"],
			["Switch off the cameras too.", "cameras_off"],
			["The rotunda is through the arch at the back of the hall. Take the statue.", "took_treasure"],
			["Get out with the statue.", "escaped_with_treasure"],
		]),
		LeadDef.make("lights_out", "Lights out", "read:electrician_note", [
			["The plant room is the shed in the sculpture garden. Get in.", "entered_plant_room"],
			["Flip the main breaker.", "lights_out"],
			["Lights, lasers and cameras are off, and the guard's on his way. Into the rotunda and take the statue!", "took_treasure"],
			["Get out with the statue.", "escaped_with_treasure"],
		]),
	]
	return j
