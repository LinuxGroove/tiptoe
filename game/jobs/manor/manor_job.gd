class_name ManorJob
extends RefCounted
## Job 7, the finale: Hoard Manor, where everything Augustus Hoard took from
## Kettleford waits in the vault under the house.

static func make() -> JobDef:
	var j := JobDef.new()
	j.id = "manor"
	j.title = "Hoard Manor"
	j.place = "the last job"
	j.treasure = "The vault"
	j.treasure_item = "vault"
	j.treasure_model = "res://assets/kenney/pirate-kit/chest.glb"
	j.music = "night_manor"
	j.blurb = "The last job. Augustus Hoard's manor on the hill, where everything he ever took from Kettleford waits in the vault under the cellar. Hoard dines, reads and gloats before bed; Pell the butler locks up; two guards and Duke the dog walk the grounds. Cameras, lasers, an alarm and a fuse box: every trick at once. Open the vault and bring the town's treasures home."
	j.scene = "res://game/jobs/manor/manor_level.gd"
	j.par_time = 600.0
	j.start_points = [
		{"id": "gates", "title": "The front gates", "mastery": 0},
		{"id": "garden_wall", "title": "The garden wall", "mastery": 1},
		{"id": "greenhouse", "title": "The greenhouse", "mastery": 2},
		{"id": "coal_chute", "title": "The coal chute", "mastery": 3},
	]
	j.gadgets = [
		{"id": "lockpicks", "title": "Lockpicks", "mastery": 0},
		{"id": "pry_bar", "title": "Pry bar", "mastery": 0},
		{"id": "treats", "title": "Dog treats", "mastery": 0},
		{"id": "darts", "title": "Foam dart blaster", "mastery": 0},
		{"id": "noisemaker", "title": "Noisemaker", "mastery": 1, "count": 1},
		{"id": "snooze_darts", "title": "Snooze darts", "mastery": 2, "count": 2},
	]
	j.capers = [
		CaperDef.make("bell_hide", "Ring the bell, then hide in the hall",
			"Pell answers the front door. The coat cupboard in the hall has room for one.",
			"hid:hall", ["doorbell_rung"]),
		CaperDef.make("three_pieces", "Find all three pieces of the code",
			"Hoard's diary in the study, a note in the butler's pantry, the safe behind his portrait.",
			"found_whole_code"),
		CaperDef.make("read_diary", "Read Hoard's diary",
			"It's on the desk in his study, through the library.",
			"read:hoard_diary"),
		CaperDef.make("secret_stair", "Take the secret stair",
			"Somewhere in the library, one book isn't a book.",
			"entered_secret_stair"),
		CaperDef.make("good_dog", "Give Duke a treat",
			"Duke sleeps by his kennel on the east lawn. There are biscuits in the guardhouse.",
			"fed_dog"),
		CaperDef.make("whos_there", "Get Hoard to say \"Who's there?\"",
			"Let him catch a glimpse, or make a noise near him. Then don't stay.",
			"hoard_whos_there"),
		CaperDef.make("key_thief", "Take Hoard's key",
			"He hangs it on his bedside table at bedtime. Or he could have a nap sooner.",
			"took:hoard_key"),
		CaperDef.make("let_in", "Get Pell to let the night guard in",
			"The spare uniform is in the guardhouse. Ring the front doorbell.",
			"let_in_as_guard"),
		CaperDef.make("butler_did_it", "Open the vault dressed as the butler",
			"Pell's spare tailcoat is in his room, up the servants' stair.",
			"vault_open_as_butler"),
		CaperDef.make("thank_you", "Leave a thank-you card in the empty vault",
			"Hoard keeps a box of thank-you cards on his study desk. He never sends any.",
			"left_card", ["took_treasure"]),
		CaperDef.make("coal_chute", "Leave by the coal chute",
			"Up the chute from the coal store, with the town's treasures.",
			"escaped_by:chute", ["escaped_with_treasure"], [], true),
		CaperDef.make("manor_dark", "Leave the whole manor dark",
			"Every light in the house off as you leave: switches, or the fuse box in the kitchen yard.",
			"manor_dark", ["escaped_with_treasure"], [], true),
		CaperDef.make("no_alarm", "Never set off the alarm",
			"Cameras, laser gates and a missing key all ring it. The switch is in the butler's pantry.",
			"escaped_with_treasure", [], ["alarm"], true),
		CaperDef.make("unseen_by_hoard", "Never be seen by Hoard",
			"He's the one in the suit. Keep out of his sight all night.",
			"escaped_with_treasure", [], ["spotted_by:Hoard"], true),
		CaperDef.make("ghost", "Finish without being seen",
			"Stay in the dark and keep out of everyone's sight, cameras too.",
			"ghost", [], [], true),
		CaperDef.make("lights_out", "Trip the fuse box",
			"It's on the kitchen wall in the kitchen yard. Everything goes off.",
			"lights_out"),
	]
	j.leads = [
		LeadDef.make("three_pieces", "The three pieces", "read:hoard_diary", [
			["Pell keeps the middle part of the code. Look in the butler's pantry, off the kitchen.", "read:pantry_note"],
			["The last part is in the safe behind Hoard's portrait, upstairs in his bedroom. The safe is his birthday: 0612.", "read:safe_note"],
			["The vault is in the cellar, past two laser gates (their switch is in the study). Type 731942 at the vault door.", "keypad:vault"],
			["Open the vault and take the town's treasures.", "took_treasure"],
			["Get out with them.", "escaped_with_treasure"],
		]),
		LeadDef.make("lights_out", "Lights out", "read:guard_rota", [
			["The fuse box is on the kitchen wall, in the kitchen yard on the west side. Flip it.", "lights_out"],
			["Pell comes out to fix it. Slip in by the kitchen door while he's busy.", "entered_by:kitchen_door"],
			["No lights, no cameras, no lasers, no alarm. The cellar door is in the back hall.", "entered_cellar"],
			["The vault needs the code or Hoard's key. Open it before the lights come back.", "vault_open"],
			["Take the town's treasures.", "took_treasure"],
			["Get out with them.", "escaped_with_treasure"],
		]),
		LeadDef.make("bedtime", "Bedtime", "heard:key_bedside", [
			["Get up to Hoard's bedroom: upstairs at the back, east side. The servants' stair from the kitchen is quietest.", "entered_bedroom"],
			["Wait for Hoard to go to bed, then take the key from his bedside table. Carpet is quiet; keep to the dark.", "took:hoard_key"],
			["Down to the cellar. Mind the camera on the cellar stair, or find the library's secret way.", "entered_cellar"],
			["Use Hoard's key on the vault door. The low laser blinks; crawl under the high ones when it's off.", "unlocked:vault_door"],
			["Take the town's treasures.", "took_treasure"],
			["Get out with them, before Hoard wakes up and misses his key.", "escaped_with_treasure"],
		]),
	]
	return j
