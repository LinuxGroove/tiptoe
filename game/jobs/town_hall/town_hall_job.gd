class_name TownHallJob
extends RefCounted
## Job 4: Kettleford town hall on council night. The council votes at ten on
## selling the town green to Augustus Hoard, and the town charter, which
## says the green belongs to the town for ever, waits in the mayor's
## strongbox upstairs until she fetches it for the vote.

static func make() -> JobDef:
	var j := JobDef.new()
	j.id = "town_hall"
	j.title = "Town hall"
	j.place = "on council night"
	j.treasure = "The town charter"
	j.treasure_item = "charter"
	j.treasure_model = "res://game/jobs/town_hall/charter.tscn"
	j.music = "night_town_hall"
	j.blurb = "Tonight the council votes on selling the town green to Augustus Hoard. The town charter says the green belongs to Kettleford for ever, and without it on the table there's no vote. It's locked in the mayor's strongbox upstairs, and at ten o'clock she fetches it. The chamber is packed, the clerk is fussing, the caretaker is doing his rounds. Take the charter before the vote."
	j.scene = "res://game/jobs/town_hall/town_hall_level.gd"
	j.par_time = 420.0
	j.start_points = [
		{"id": "front", "title": "The front steps", "mastery": 0},
		{"id": "car_park", "title": "The car park", "mastery": 1},
		{"id": "roof", "title": "The bell tower roof", "mastery": 3},
	]
	j.gadgets = [
		{"id": "lockpicks", "title": "Lockpicks", "mastery": 0},
		{"id": "darts", "title": "Foam dart blaster", "mastery": 0},
		{"id": "noisemaker", "title": "Noisemaker", "mastery": 1},
		{"id": "snooze_darts", "title": "Snooze darts", "mastery": 2, "count": 1},
	]
	j.capers = [
		CaperDef.make("before_vote", "Take the charter before the vote",
			"The mayor fetches it at ten. Be quicker.",
			"took_treasure", [], ["vote_started"]),
		CaperDef.make("sit_in", "Sit in on the meeting",
			"Borrow a coat from the cloakroom and take an empty seat at the back.",
			"sat_in_meeting"),
		CaperDef.make("ring_bell", "Ring the town hall bell",
			"The bell rope hangs in the little room at the top of the back stair.",
			"rang_bell"),
		CaperDef.make("read_speech", "Read Hoard's speech",
			"It's on the lectern, in front of everybody.",
			"read:hoard_speech"),
		CaperDef.make("recipe_swap", "Swap his speech for a recipe",
			"There's a sponge recipe on the fridge in the tea room. Swap it in at the lectern.",
			"speech_swapped"),
		CaperDef.make("vote_no", "Put a \"Vote no\" sign on the mayor's desk",
			"The protesters left their placards by the front doors.",
			"sign_on_desk"),
		CaperDef.make("mop", "Put the caretaker's mop in the chamber",
			"It lives in his cupboard. Prop it up by the dais.",
			"mop_in_chamber"),
		CaperDef.make("no_main_stairs", "Never use the main stairs",
			"The back stair goes up from the side door to the roof.",
			"escaped_with_treasure", [], ["entered_main_stairs"], true),
		CaperDef.make("lights_out", "Plunge the meeting into darkness",
			"The fuse box is in the caretaker's cupboard.",
			"lights_out"),
		CaperDef.make("both_looks", "Wear both disguises",
			"A coat from the cloakroom, and the spare clerk's lanyard from reception.",
			"wore:clerk", ["wore:townsfolk"]),
		CaperDef.make("codebreaker", "Open the strongbox by its combination",
			"Dobbs has half of it on a sticky note. The other half is a date in the archive.",
			"keypad:strongbox"),
		CaperDef.make("pickpocket", "Take the mayor's key from her coat",
			"Her red coat is in the cloakroom.",
			"took:mayor_key"),
		CaperDef.make("mayor_opens", "Let the mayor open the box for you",
			"Wait for her to fetch the charter, then get her away from it.",
			"took_treasure", ["strongbox_opened_by_mayor"]),
		CaperDef.make("roof_escape", "Leave over the roof",
			"Get back to the bell tower with the charter.",
			"escaped_with_treasure", ["way_out:roof"], [], true),
		CaperDef.make("front_in_coat", "Walk out the front in a borrowed coat",
			"Nobody looks twice at one of the townsfolk going home.",
			"escaped_with_treasure", ["left_as_townsfolk"], [], true),
		CaperDef.make("ghost", "Finish without being seen",
			"Keep to the dark, and to the back of the room.",
			"ghost", [], [], true),
	]
	j.leads = [
		LeadDef.make("coat_check", "Coat check", "heard:mayor_key", [
			["The cloakroom is off the lobby. Borrow a coat from the rail and you'll pass for one of the townsfolk.", "wore:townsfolk"],
			["Search the mayor's red coat for her key.", "took:mayor_key"],
			["A coat won't explain you upstairs. Get to the mayor's office unseen; her key opens the door.", "entered_mayor_office"],
			["Open the strongbox with her key and take the charter.", "took_treasure"],
			["Get out with the charter. In that coat, the front doors are fine.", "escaped_with_treasure"],
		]),
		LeadDef.make("clerks_numbers", "The clerk's numbers", "read:staff_notice", [
			["The spare lanyard and folder are behind the reception desk. Put them on.", "wore:clerk"],
			["Dobbs keeps half the strongbox code on a sticky note in his office. He knows you're not a real clerk, so go while he's out.", "read:sticky_note"],
			["The rest is a date: the photo of the green in the archive, down the stairs past his office.", "read:green_photo"],
			["Up to the mayor's office (lockpicks open her door) and dial the strongbox.", "keypad:strongbox"],
			["Take the charter.", "took_treasure"],
			["Get out with the charter.", "escaped_with_treasure"],
		]),
		LeadDef.make("over_the_roof", "Over the roof", "read:caretaker_note", [
			["Climb the bins by the clerk's window onto the annex roof, then the air vent onto the main roof.", "entered_roof"],
			["Drop onto the mayor's balcony and climb in through her open window.", "entered_mayor_office"],
			["Hide in her wardrobe. At ten she comes to open the strongbox herself.", "strongbox_opened_by_mayor"],
			["Get her away from it (a snooze dart, a noise outside) and take the charter.", "took_treasure"],
			["Back up onto the roof and away by the bell tower.", "escaped_with_treasure"],
		]),
	]
	return j
