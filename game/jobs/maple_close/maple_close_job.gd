class_name MapleCloseJob
extends RefCounted
## Job 1: the Pembertons' house on Maple Close, where the bakery's prize
## trophy sits in the upstairs study.

static func make() -> JobDef:
	var j := JobDef.new()
	j.id = "maple_close"
	j.title = "Maple Close"
	j.place = "a family home"
	j.treasure = "The bakery's prize trophy"
	j.treasure_item = "trophy"
	j.treasure_model = "res://assets/kenney/mini-arena/trophy.glb"
	j.blurb = "Augustus Hoard \"lent\" the bakery's prize trophy to his cousins, the Pembertons. It sits in their upstairs study. Ted Pemberton watches TV until late, Maggie potters about, and Biscuit the dog sleeps by the back door. Bring the trophy home."
	j.scene = "res://game/jobs/maple_close/maple_close_level.gd"
	j.par_time = 300.0
	j.start_points = [
		{"id": "street", "title": "The street", "mastery": 0},
		{"id": "garden", "title": "The back garden", "mastery": 1},
		{"id": "alley", "title": "The side alley", "mastery": 3},
	]
	j.gadgets = [
		{"id": "lockpicks", "title": "Lockpicks", "mastery": 0},
		{"id": "pry_bar", "title": "Pry bar", "mastery": 0},
		{"id": "treats", "title": "Dog treats", "mastery": 0},
		{"id": "darts", "title": "Foam dart blaster", "mastery": 1},
		{"id": "noisemaker", "title": "Noisemaker", "mastery": 2, "count": 1},
	]
	j.capers = [
		CaperDef.make("no_key", "Get in without a key",
			"Every house has another way in: a window, a door nobody's watching.",
			"entered_house", [], ["used_key"]),
		CaperDef.make("porch_light", "Turn off the porch light",
			"Its switch is just inside the front door. Or cut the power.",
			"porch_light_off"),
		CaperDef.make("bell_then_back", "Ring the bell, then sneak in the back",
			"Ted answers the front door. The back door is round the side.",
			"entered_by:back_door", ["doorbell_rung"]),
		CaperDef.make("shopping_list", "Read the shopping list",
			"It's stuck to the fridge.",
			"read:shopping_list"),
		CaperDef.make("dog_asleep", "Leave the dog asleep",
			"Biscuit wakes up to noise. Carpet is quiet; the kitchen tiles aren't.",
			"escaped_with_treasure", [], ["dog_woke"], true),
		CaperDef.make("no_door", "Leave without using a door",
			"Windows count. So does the trellis.",
			"escaped_not_door", ["escaped_with_treasure"], [], true),
		CaperDef.make("cupcake_swap", "Swap the trophy for a cupcake",
			"There's a cupcake in the kitchen. Put it where the trophy was.",
			"cupcake_on_stand", ["took_treasure"]),
		CaperDef.make("ghost", "Finish without being seen",
			"Stay in the dark and keep out of their sight.",
			"ghost", [], [], true),
		CaperDef.make("lights_out", "Trip the fuse box",
			"It's in the garage. Everyone will come to see what happened.",
			"lights_out"),
		CaperDef.make("good_dog", "Give Biscuit a treat",
			"Drop a dog treat where Biscuit can smell it.",
			"fed_dog"),
		CaperDef.make("tidy", "Leave everything as you found it",
			"Don't knock anything over.",
			"tidy", [], [], true),
		CaperDef.make("pizza", "Get let in as the pizza delivery",
			"Wear the delivery cap, carry a pizza and ring the bell.",
			"let_in_as_pizza"),
	]
	j.leads = [
		LeadDef.make("pizza_night", "Pizza night", "read:pizza_flyer", [
			["Grab a pizza box and the delivery cap from the scooter by the curb.", "got_pizza_cap"],
			["Put the cap on: open your backpack and use it.", "wore_pizza_cap"],
			["Carry a pizza box to the front door and ring the bell.", "let_in_as_pizza"],
			["You're in. The trophy is upstairs in the study.", "took_treasure"],
			["Get out with the trophy.", "escaped_with_treasure"],
		]),
		LeadDef.make("fuse_trouble", "Fuse trouble", "read:neighbor_note", [
			["The garage side door is down the side alley. Get into the garage.", "entered_garage"],
			["Flip the big switch on the fuse box.", "lights_out"],
			["Everyone heads for the garage in the dark. Slip upstairs to the study.", "took_treasure"],
			["Get out with the trophy.", "escaped_with_treasure"],
		]),
	]
	return j
