class_name MarketJob
extends RefCounted
## Job 2: Kettleford's corner market after closing, where Augustus Hoard's
## rent ledger sits on his rent collector's desk in the back office.

static func make() -> JobDef:
	var j := JobDef.new()
	j.id = "market"
	j.title = "The corner market"
	j.place = "after closing"
	j.treasure = "Hoard's rent ledger"
	j.treasure_item = "ledger"
	j.music = "night_market"
	j.blurb = "Augustus Hoard owns every shop on the high street, and squeezes them all. His rent ledger proves he's been overcharging, and tonight it's in the back office of the corner market, where his collector Mrs Pruitt counts the takings. Dev the night clerk is restocking the shelves, the cameras are watching, and the office has a keypad. Bring the ledger home."
	j.scene = "res://game/jobs/market/market_level.gd"
	j.par_time = 360.0
	j.start_points = [
		{"id": "street", "title": "The high street", "mastery": 0},
		{"id": "loading_bay", "title": "The loading bay", "mastery": 1},
		{"id": "roof", "title": "The roof", "mastery": 3},
	]
	j.gadgets = [
		{"id": "lockpicks", "title": "Lockpicks", "mastery": 0},
		{"id": "darts", "title": "Foam dart blaster", "mastery": 0},
		{"id": "noisemaker", "title": "Noisemaker", "mastery": 1},
		{"id": "snooze_darts", "title": "Snooze darts", "mastery": 2, "count": 1},
	]
	j.capers = [
		CaperDef.make("till_note", "Read the note under the till",
			"Staff write things down. The till's a good place to look.",
			"read:till_note"),
		CaperDef.make("by_code", "Open the office with its own code",
			"The keypad is on the office door in the stock room.",
			"keypad:office"),
		CaperDef.make("on_shift", "Be on shift",
			"Wear the spare apron and let Dev see you, standing up straight.",
			"on_shift"),
		CaperDef.make("new_starter", "Get let in as the new starter",
			"Wear the apron and ring the deliveries bell at the back door.",
			"let_in_as_staff"),
		CaperDef.make("dart_cameras", "Dart every camera",
			"Two on the shop floor, one in the stock room. A dart near the lens knocks one out.",
			"all_cameras_darted"),
		CaperDef.make("melon", "Put a melon on the till",
			"There's a watermelon on the fruit stand.",
			"melon_on_till"),
		CaperDef.make("carts", "Stack the carts",
			"Three carts have wandered off: one outside, one up the side passage, one in the stock room.",
			"carts_stacked"),
		CaperDef.make("money", "Leave the rent money alone",
			"It's on the desk next to the ledger. It isn't yours. Neither is the ledger, mind.",
			"escaped_with_treasure", [], ["took:rent_money"], true),
		CaperDef.make("cookbook", "Swap the ledger for a cookbook",
			"There's a cookbook by the shop door. Leave it on the desk where the ledger was.",
			"cookbook_on_desk", ["took_treasure"]),
		CaperDef.make("no_alarm", "Never set off the alarm",
			"Cameras ring it when they see you. Darts, the power or the monitor switch can stop them.",
			"escaped_with_treasure", [], ["alarm"], true),
		CaperDef.make("lights_out", "Cut the power",
			"The breaker is in the meter cupboard at the end of the alley.",
			"lights_out"),
		CaperDef.make("hatch", "Drop in through the roof hatch",
			"Climb the skip onto the roof and pick the padlock.",
			"entered_by:roof_hatch"),
		CaperDef.make("vent", "Crawl through the vent",
			"There's a vent from the stock room into the office, above a crate.",
			"crawled_vent"),
		CaperDef.make("freezer", "Hide in the walk-in freezer",
			"Behind the frozen peas, in the stock room's corner. Brr.",
			"hid_in:freezer"),
		CaperDef.make("recycling", "Get thanked for recycling",
			"Press the big green button on the bottle machine. Or dart it.",
			"bottle_machine"),
		CaperDef.make("ghost", "Finish without being seen",
			"Stay in the dark, out of sight of Dev, Mrs Pruitt and the cameras.",
			"ghost", [], [], true),
	]
	j.leads = [
		LeadDef.make("the_code", "The office code", "read:staff_notice", [
			["Get into the shop. The front door's lock can be picked, but its bell rings.", "entered_house"],
			["Read the sticky note under the till.", "read:till_note"],
			["Type the code into the office keypad in the stock room, while Mrs Pruitt is out on her rounds.", "keypad:office"],
			["Take the rent ledger from her desk.", "took_treasure"],
			["Get out with the ledger.", "escaped_with_treasure"],
		]),
		LeadDef.make("new_starter", "The new starter", "read:job_ad", [
			["Find the spare apron on the hook by the bins out back, and put it on.", "wore:staff"],
			["Ring the deliveries bell at the back door and wait on the step.", "let_in_as_staff"],
			["Staff belong in the stock room. Knock on the office door there, and stand up straight.", "pruitt_to_till"],
			["Mrs Pruitt's off to count the till. Slip into the office and take the ledger.", "took_treasure"],
			["Get out with the ledger.", "escaped_with_treasure"],
		]),
		LeadDef.make("power_cut", "Power cut", "read:electrician_note", [
			["Flip the main breaker in the meter cupboard.", "lights_out"],
			["Hide. Mrs Pruitt comes out the back to fix it. Slip in the back door behind her.", "entered_by:front_door"],
			["The office lock has let go. Get into the office before the power's back.", "entered_office"],
			["Take the rent ledger.", "took_treasure"],
			["Get out with the ledger.", "escaped_with_treasure"],
		]),
	]
	return j
