class_name LabsJob
extends RefCounted
## Job 6: Hoard Labs after hours, where the Kettleford school's model rocket
## stands on a launch stand in the test hangar, behind laser gates.

static func make() -> JobDef:
	var j := JobDef.new()
	j.id = "labs"
	j.title = "Hoard Labs"
	j.place = "after hours"
	j.treasure = "The school's model rocket"
	j.treasure_item = "rocket"
	j.treasure_model = "res://game/jobs/labs/rocket.tscn"
	j.music = "night_labs"
	j.blurb = "Hoard Labs \"invents\" things by taking other people's. Its latest idea is the Kettleford school's model rocket, which won the county science fair before Augustus Hoard confiscated it \"for safety\". It stands in the test hangar behind laser gates. Two guards walk their rounds, Officer Marsh watches the cameras from the security office, and Dr Fenwick is working late again. Bring the rocket home."
	j.scene = "res://game/jobs/labs/labs_level.gd"
	j.par_time = 360.0
	j.start_points = [
		{"id": "car_park", "title": "The car park", "mastery": 0},
		{"id": "loading_bay", "title": "The loading bay", "mastery": 1},
		{"id": "roof", "title": "The roof vent", "mastery": 2},
	]
	j.gadgets = [
		{"id": "lockpicks", "title": "Lockpicks", "mastery": 0},
		{"id": "darts", "title": "Foam dart blaster", "mastery": 0},
		{"id": "noisemaker", "title": "Noisemaker", "mastery": 1, "count": 1},
		{"id": "snooze_darts", "title": "Snooze darts", "mastery": 2, "count": 2},
	]
	j.capers = [
		CaperDef.make("tea_break", "Switch everything off while the officer's on break",
			"Officer Marsh takes her tea in the break room. Her switches are on the office wall.",
			"office_all_off"),
		CaperDef.make("vents", "Crawl through every vent",
			"Six vent covers: four labs, the hangar, and the hatch on the roof.",
			"all_vents"),
		CaperDef.make("coffee", "Make a coffee",
			"The machine's in the break room. Whoever finds the cup will stop for it.",
			"made_coffee"),
		CaperDef.make("journal", "Read Dr Fenwick's journal",
			"She leaves it in the break room with her coffee things.",
			"read:fenwick_journal"),
		CaperDef.make("hands_off", "Take the rocket without opening a sliding door",
			"Vents, windows, or follow someone through.",
			"took_treasure", [], ["opened:entrance", "opened:chem_door", "opened:clean_door",
				"opened:server_door", "opened:workshop_door", "opened:hangar_door", "opened:bay_hangar"]),
		CaperDef.make("tailgate", "Slip through a sliding door someone else opened",
			"Follow a guard close behind, before it shuts.",
			"tailgated"),
		CaperDef.make("slip_lasers", "Take the rocket without turning the lasers off",
			"The corridor lasers blink. The ones at the rocket are high: get low.",
			"took_treasure", [], ["lasers_off", "lights_out", "tripped_laser"]),
		CaperDef.make("bottle_swap", "Swap the rocket for a bottle rocket",
			"There's a crate of confiscated fireworks in goods in.",
			"bottle_on_stand", ["took_treasure"]),
		CaperDef.make("confetti", "Fire the confetti cannon",
			"Hoard's newest \"invention\" is in the workshop. It's loud.",
			"confetti"),
		CaperDef.make("nap_on_duty", "Send Officer Marsh to sleep at her desk",
			"A snooze dart while she watches the monitors.",
			"officer_snoozed"),
		CaperDef.make("borrow_card", "Borrow a keycard from a napping guard",
			"Guards carry hangar cards. Sleeping guards don't notice.",
			"borrowed_keycard"),
		CaperDef.make("no_card", "Take the rocket without a keycard",
			"Doors aren't the only way into the hangar.",
			"took_treasure", [], ["used_key"]),
		CaperDef.make("hoard_letter", "Read Hoard's letter to the school",
			"It's on the desk in his office, off the corridor.",
			"read:hoard_letter"),
		CaperDef.make("lights_out", "Trip the main breaker",
			"It's in goods in. Briggs will come to fix it.",
			"lights_out"),
		CaperDef.make("by_the_roof", "Get away over the roof",
			"Take the rocket out the way the pigeons come in.",
			"left_by:roof", ["escaped_with_treasure"], [], true),
		CaperDef.make("ghost", "Finish without being seen",
			"Cameras count too, watched or not.",
			"ghost", [], [], true),
	]
	j.leads = [
		LeadDef.make("tea_break", "Tea break", "read:night_rota", [
			["Wait somewhere dark near the security office for Officer Marsh's tea break.", "officer_on_break"],
			["Slip into the security office and switch off the lasers.", "lasers_off"],
			["Take the spare hangar card from the key cabinet.", "took:hangar_keycard"],
			["Swipe into the hangar at the end of the corridor.", "unlocked:hangar_door"],
			["The rocket is in the test cell. Take it.", "took_treasure"],
			["Get out with the rocket.", "escaped_with_treasure"],
		]),
		LeadDef.make("lab_coat", "Dr Fenwick's coat", "read:fenwick_journal", [
			["Find Dr Fenwick's spare lab coat in the break room and put it on.", "wore:labcoat"],
			["Her lab card is in the pocket. Swipe into the workshop.", "unlocked:workshop_door"],
			["Unscrew the loose vent cover in the workshop and crawl through to the hangar.", "vent:hangar"],
			["A camera watches the rocket. Knock it out with a foam dart.", "camera_darted"],
			["Crouch under the lasers and take the rocket.", "took_treasure"],
			["Get out with the rocket.", "escaped_with_treasure"],
		]),
		LeadDef.make("server_code", "Sputnik year", "heard:server_code", [
			["Open the server room door with the code Dr Fenwick muttered: 1957.", "keypad:server"],
			["Release the hangar door from the door controller in the server room.", "hangar_released"],
			["Time the blinking lasers in the corridor and slip into the hangar.", "entered_hangar"],
			["The rocket is in the test cell. Take it.", "took_treasure"],
			["Get out with the rocket.", "escaped_with_treasure"],
		]),
	]
	return j
