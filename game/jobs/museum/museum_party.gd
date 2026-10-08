class_name MuseumParty
extends Node
## The gala: who's there and what they do. Two pairs of guests mill between
## spots and gossip when the player is close, and their gossip holds the
## clues (the security code, the broken camera, the missing waiters...).
## Guests call a waiter with a tray over and thank them for a drink; the head
## waiter notices a waiter with nothing in their hands. At a set time (or
## when someone strikes the gong) Augustus Hoard gives a toast from the
## balcony: everyone, the guard included, gathers in the hall to face him,
## the chatter stops, and the photographer's flash goes off at the end.

const FIRST_TOAST := 150.0
const TOAST_EVERY := 240.0
## The gong only starts a toast this long after the last one.
const TOAST_GAP := 30.0
const SPEECH_GAP := 4.0
## How long Hoard takes to reach the balcony before he starts anyway.
const HOARD_WAIT := 45.0
const GOSSIP_RANGE := 5.0
const GOSSIP_REPLY := 3.2
const GOSSIP_PAUSE := 6.0
const CALL_RANGE := 2.6
const CALL_PAUSE := 18.0
const SCOLD_PAUSE := 8.0
## Where the photo sees: the balcony, beside Hoard.
const PHOTO_BOX := AABB(Vector3(-4.5, 2.0, 7.6), Vector3(9.0, 2.5, 3.0))

const SPEECH := [
	"Friends! Neighbours! People who owe me money!",
	"Welcome to the Hoard Museum of Local Heritage.",
	"Everything you see was given freely. More or less.",
	"And through that arch, the founder himself. Safe at last.",
	"To Kettleford! And to me!",
]
const TOAST_CALL := "Everyone! Into the hall! Toast time!"
const GONG_LINE := "The gong! That's my cue!"
const PHOTO_LINE := "Everybody look up at Mr Hoard!"

## topic -> [first speaker's line, second speaker's line]. Each pair talks
## through its own topics, one each time the player comes near.
const GOSSIP := {
	"guard_code": ["Did you see the guard tap in his door code? Oh nine one two.",
		"His birthday, he told me. Ninth of December. Bless him."],
	"short_waiters": ["I haven't seen a waiter in ages. I'm parched.",
		"The caterer's two short tonight. Anyone in a jacket with a tray would do."],
	"broken_camera": ["Hoard showed me the cameras. The pirate gallery one's been broken for weeks.",
		"And he won't pay to fix it. Typical."],
	"curator_bag": ["The curator left her handbag in the cloakroom. Keys and all!",
		"She'd lose her head if it wasn't on a plinth."],
	"skylight": ["They say the skylight over the statue doesn't even lock.",
		"Well, nobody comes in through the roof, do they?"],
	"toast": ["Hoard's toast is the big moment. Everyone has to be in the hall.",
		"Even the guard leaves his desk for it. Hoard wants him in the photo."],
}
const PAIR_TOPICS := [["guard_code", "short_waiters", "broken_camera"], ["curator_bag", "skylight", "toast"]]

const GUEST_LINES := {
	"seen": ["I'm sorry, have we met?", "Are you with the caterers?"],
	"spotted": ["A burglar! In a museum!", "Help! Thief!"],
	"curious": ["Did you hear that?", "What was that?"],
	"others": ["What's going on?"],
	"lost": ["Where did they go?"],
	"give_up": ["Probably a waiter.", "Must have been the Mayor."],
	"catch": ["Got you! Somebody fetch Ron!"],
	"wake": ["Oh! I must have nodded off. Lovely party."],
}
const LIGHTS_OUT_LINE := "Ooh! Is this part of the show?"
## What each guest says to wave a waiter over, and to thank them for a drink.
const CALLS := {
	"Fairweather": "Ooh, waiter! Over here!", "Ashby": "Is that champagne? Splendid.",
	"Crumb": "Waiter! Bring that tray here at once.", "Mayor": "A drink? Don't mind if I do.",
	"Snapper": "Over here, waiter!",
}
const THANKS := {
	"Fairweather": "Oh, lovely. Thank you!", "Ashby": "Much obliged.", "Crumb": "How kind. Thank you.",
	"Mayor": "Cheers! Don't tell Hoard I'm here.", "Snapper": "Ta very much.",
	"Hoard": "Champagne? Mine, I assume. Everything is.", "Finch": "Oh, thank you. I need this.",
}

## Voices for recording: voice -> {who, kokoro, speed}.
const VOICES := {
	"hoard": {"who": "Augustus Hoard: a pompous, oily rich man in his sixties, pleased with himself", "kokoro": "am_onyx", "speed": 0.95},
	"museum_head_waiter": {"who": "Mr Pring, the head waiter: prim, fussy and very proper", "kokoro": "bm_fable", "speed": 1.0},
	"museum_curator": {"who": "Miss Finch, the curator: clever, flustered and quietly ashamed of her boss", "kokoro": "bf_alice", "speed": 1.05},
	"museum_guard": {"who": "Ron, the museum guard: big, kind and fond of sausage rolls", "kokoro": "am_liam", "speed": 1.0},
	"museum_guest_a": {"who": "Mrs Fairweather, a guest: a bright, chatty gossip who knows everything", "kokoro": "af_bella", "speed": 1.05},
	"museum_guest_b": {"who": "Mr Ashby, a guest: a dry, amused old gentleman", "kokoro": "am_echo", "speed": 1.0},
	"museum_crumb": {"who": "Lady Crumb, a guest: grand, nosy and delighted by scandal", "kokoro": "af_heart", "speed": 1.0},
	"town_hall_mayor": {"who": "Mayor Prudence Plum: a brisk, decent, slightly frazzled woman in her fifties, chairing a rowdy meeting", "kokoro": "bf_isabella", "speed": 1.0},
	"museum_snapper": {"who": "Snapper, the photographer: upbeat and bossy with a camera", "kokoro": "am_puck", "speed": 1.1},
	"museum_violinist": {"who": "The violinist in the string quartet: polite and a bit bored", "kokoro": "af_sky", "speed": 1.0},
	"museum_cellist": {"who": "The cellist in the string quartet: cheerful, secretly loves sea shanties", "kokoro": "bm_lewis", "speed": 1.0},
	"museum_cook": {"who": "The cook: harassed, run off her feet, dreaming of a break", "kokoro": "af_nicole", "speed": 1.05},
}

var level: MuseumLevel
var run: JobRun
var hoard: Person
var pring: Person
var finch: Person
var ron: Person
var snapper: Person
var violinist: Person
var cellist: Person
var cook: Person
## The gossiping pairs: [[a, b], [a, b]].
var pairs: Array = []
## Everyone who calls the waiter over and can be offered a drink.
var guests: Array = []
## Everyone who comes to the hall for the toast -> where they stand.
var gathers := {}
var toasting := false
var next_toast := FIRST_TOAST
var heard := {}
var served := {}
var _last_toast_end := -999.0
var _toast_t := 0.0
var _speech_i := -1
var _speech_t := 0.0
var _hoard_ready := false
var _flashed := false
var _talking := [false, false]
var _next_talk := [0.0, 0.0]
var _tick := 0.0
var _called := {}
var _scold_t := 0.0
var _serve_spots: Array = []
var _player: Moth


## Adds everyone to the level and returns them.
func setup(p_level: MuseumLevel, p_run: JobRun) -> Array:
	level = p_level
	run = p_run
	var all := []
	hoard = _person("Hoard", "male-c", "hoard", [
		{"at": "hall_c", "time": 22.0, "face": Vector3(0, 0, 1), "say": "Marvellous, isn't it? All mine."},
		{"at": "arch", "time": 9.0, "face": Vector3(0, 0, -1), "say": "And there he is. The founder. Much happier here."},
		{"at": "buffet", "time": 12.0, "face": Vector3(0, 0, -1), "say": "Do try the vol-au-vents. I paid for them. Eventually."},
		{"at": "pirates", "time": 14.0, "say": "That cannon was just lying on the beach. Finders keepers."},
		{"at": "hall_e", "time": 18.0, "clip": "emote-yes"},
		{"at": "castles", "time": 14.0, "say": "The castle's from the library. They had far too many books anyway."},
	], {
		"accepts": ["guest", "waiter"], "mumble": "low",
		"lines": {"seen": ["Who invited you?"], "curious": ["Hm? Who's that?"], "spotted": ["Security! Ron! A burglar!"],
			"others": ["What's all the fuss?"], "lost": ["Ron! Find them!"], "give_up": ["Probably the Mayor. She wanders."],
			"catch": ["Got you! Ron, show them out."], "wake": ["Wha...? Rich men need their rest."]},
		"extra_lines": SPEECH + [TOAST_CALL, GONG_LINE, "Cheese!", THANKS.Hoard, "Who turned the lights out? Ron!"],
	})
	pring = _person("Pring", "male-d", "museum_head_waiter", [
		{"at": "pass", "time": 12.0, "face": Vector3(0, 0, 1), "say": "Trays up, chins up."},
		{"at": "corridor_n", "time": 1.0},
		{"at": "castles_n", "time": 4.0, "say": "Mind the trebuchet with that tray."},
		{"at": "buffet", "time": 10.0, "face": Vector3(0, 0, -1), "clip": "interact-right", "say": "Who's been at the vol-au-vents?"},
		{"at": "hall_e", "time": 5.0},
		{"at": "corridor_s", "time": 1.0},
		{"at": "staff_room", "time": 6.0},
	], {
		"accepts": ["guest", "waiter"], "mumble": "low",
		"lines": {"seen": ["And who might you be?"], "curious": ["Was that a tray? Who dropped a tray?"],
			"spotted": ["You're not one of mine! Ron!"], "others": ["What's the commotion?"],
			"lost": ["Where's that scoundrel got to?"], "give_up": ["Back to work, everyone."],
			"catch": ["Out. Now. And give back the jacket."], "wake": ["I'm awake! The canapés are fine!"]},
		"extra_lines": ["You there! Where's your tray?", "Idle hands! Get a tray from the kitchen."],
	})
	finch = _person("Finch", "female-a", "museum_curator", [
		{"at": "castles", "time": 18.0, "say": "Please don't touch the trebuchet."},
		{"at": "arch", "time": 4.0, "face": Vector3(0, 0, -1)},
		{"at": "rotunda", "time": 10.0, "clip": "look-around", "room": "rotunda", "say": "The founder. On loan. Indefinitely."},
		{"at": "nature", "time": 14.0, "say": "The Stone Head. From the village green. Don't ask."},
		{"at": "office", "time": 22.0, "room": "office", "leave_dark": true, "say": "Now where did I put my keys?"},
		{"at": "balcony", "time": 6.0},
		{"at": "hall_w", "time": 12.0},
	], {
		"accepts": ["guest", "waiter"], "mumble": "high", "answers_alarm": true,
		"lines": {"seen": ["Excuse me, can I help you?"], "curious": ["Did something just fall over?"],
			"spotted": ["Thief! Someone call Ron!"], "lost": ["They went that way! I think."],
			"give_up": ["I need a sit down."], "catch": ["Caught you! Out you go."],
			"alarm": ["The alarm! My exhibits!"], "wake": ["Oh! Was I asleep? How embarrassing."]},
		"extra_lines": [THANKS.Finch],
	})
	ron = _person("Ron", MuseumLevel.ARENA + "character-soldier.glb", "museum_guard", [
		{"at": "desk", "time": 45.0, "face": Vector3(-1, 0, 0), "clip": "sit", "room": "security", "say": "Quiet night. Lovely."},
		{"at": "foyer", "time": 3.0},
		{"at": "pirates", "time": 5.0},
		{"at": "nature", "time": 5.0},
		{"at": "arch", "time": 7.0, "face": Vector3(0, 0, -1), "say": "Still there. Good."},
		{"at": "castles", "time": 5.0},
		{"at": "corridor_n", "time": 2.0},
		{"at": "kitchen", "time": 8.0, "say": "Any sausage rolls going spare?"},
		{"at": "corridor_s", "time": 2.0},
	], {
		"accepts": ["guest", "waiter"], "mumble": "low", "answers_alarm": true, "fixes_power": true, "torch": true,
		"lines": {"seen": ["Hello? Who's that?"], "curious": ["What was that?"], "spotted": ["Oi! Stop! Museum security!"],
			"lost": ["Come out, I know you're here."], "give_up": ["Must've been a guest. They all look the same in a bow tie."],
			"catch": ["Got you! Out you go, sunshine."], "alarm": ["The alarm! The statue!"],
			"power_out": ["Not the fuses again!"], "power_fixed": ["There. Lights!"], "wake": ["Wha...? I was just resting my eyes."]},
	})
	var fairweather := _person("Fairweather", "female-b", "museum_guest_a", _pair_routine(["p1_hall", "p1_pirates", "p1_buffet", "p1_castles"], "_a"), {
		"accepts": ["guest", "waiter"], "mumble": "high", "lines": GUEST_LINES,
		"extra_lines": _gossip_lines(0, 0) + [CALLS.Fairweather, THANKS.Fairweather, LIGHTS_OUT_LINE],
	})
	var ashby := _person("Ashby", "male-a", "museum_guest_b", _pair_routine(["p1_hall", "p1_pirates", "p1_buffet", "p1_castles"], "_b"), {
		"accepts": ["guest", "waiter"], "mumble": "low", "lines": GUEST_LINES,
		"extra_lines": _gossip_lines(0, 1) + [CALLS.Ashby, THANKS.Ashby, LIGHTS_OUT_LINE],
	})
	var crumb := _person("Crumb", "female-e", "museum_crumb", _pair_routine(["p2_castles", "p2_hall", "p2_nature", "p2_foyer", "p2_steps"], "_a"), {
		"accepts": ["guest", "waiter"], "mumble": "high", "lines": GUEST_LINES,
		"extra_lines": _gossip_lines(1, 0) + [CALLS.Crumb, THANKS.Crumb, LIGHTS_OUT_LINE],
	})
	var mayor := _person("Mayor", "female-c", "town_hall_mayor", _pair_routine(["p2_castles", "p2_hall", "p2_nature", "p2_foyer", "p2_steps"], "_b"), {
		"accepts": ["guest", "waiter"], "mumble": "high", "lines": GUEST_LINES,
		"extra_lines": _gossip_lines(1, 1) + [CALLS.Mayor, THANKS.Mayor, LIGHTS_OUT_LINE],
	})
	snapper = _person("Snapper", "male-b", "museum_snapper", [
		{"at": "hall_e", "time": 16.0, "say": "Smile, everyone!"},
		{"at": "castles_n", "time": 12.0, "say": "Lovely. One more."},
		{"at": "hall_w", "time": 14.0, "say": "Say cheese!"},
		{"at": "pirates", "time": 12.0},
	], {
		"accepts": ["guest", "waiter"], "mumble": "low", "lines": GUEST_LINES,
		"extra_lines": [PHOTO_LINE, CALLS.Snapper, THANKS.Snapper, LIGHTS_OUT_LINE],
	})
	violinist = _person("Violinist", "female-f", "museum_violinist", [
		{"at": "violin", "time": 999.0, "face": Vector3(1, 0, 0), "clip": "sit"},
	], {
		"accepts": ["guest", "waiter"], "mumble": "high", "sight": 9.0, "lines": GUEST_LINES,
		"extra_lines": ["A sea shanty? At a gala?"],
	})
	cellist = _person("Cellist", "female-d", "museum_cellist", [
		{"at": "cello", "time": 999.0, "face": Vector3(1, 0, 0), "clip": "sit"},
	], {
		"accepts": ["guest", "waiter"], "mumble": "high", "sight": 9.0, "lines": GUEST_LINES,
		"extra_lines": ["Ooh, I love this one!"],
	})
	cook = _person("Cook", "female-c", "museum_cook", [
		{"at": "stove", "time": 30.0, "face": Vector3(1, 0, 0), "clip": "interact-right", "say": "Who wants more vol-au-vents?"},
		{"at": "pass", "time": 6.0, "face": Vector3(0, 0, 1)},
		{"at": "yard", "time": 14.0, "room": "yard", "say": "Five minutes. Just five minutes."},
		{"at": "kitchen", "time": 10.0},
	], {
		"accepts": ["waiter"], "mumble": "high",
		"lines": {"seen": ["Oi! No guests in my kitchen!"], "spotted": ["Out of my kitchen! Thief!"],
			"curious": ["Who's banging about?"], "give_up": ["Back to the vol-au-vents."]},
	})
	pairs = [[fairweather, ashby], [crumb, mayor]]
	guests = [fairweather, ashby, crumb, mayor, snapper, hoard, finch]
	gathers = {
		hoard: "toast_hoard", finch: "toast_curator", ron: "toast_guard", pring: "toast_waiter",
		fairweather: "toast_1", ashby: "toast_2", crumb: "toast_3", mayor: "toast_4", snapper: "photo",
	}
	for p in [hoard, pring, finch, ron, fairweather, ashby, crumb, mayor, snapper, violinist, cellist, cook]:
		all.append(p)
	# Where everyone starts.
	_place(hoard, "hall_c")
	_place(pring, "pass")
	_place(finch, "castles")
	_place(ron, "desk")
	_place(fairweather, "p1_hall_a")
	_place(ashby, "p1_hall_b")
	_place(crumb, "p2_castles_a")
	_place(mayor, "p2_castles_b")
	_place(snapper, "hall_e")
	_place(violinist, "violin")
	_place(cellist, "cello")
	_place(cook, "stove")
	for g in guests:
		_add_serve(g)
	_player = get_tree().get_first_node_in_group("moth") as Moth
	if _player:
		_player.bag_changed.connect(_update_serve)
	_update_serve()
	run.event_recorded.connect(_on_event)
	return all


func _person(p_name: String, look: String, voice: String, routine: Array, opts: Dictionary) -> Person:
	var p := Person.new()
	p.setup(p_name, look, level, run, routine, voice, opts)
	return p


func _place(p: Person, point: String) -> void:
	p.position = level.points[point]
	level.add_child(p)


## A pair's routine round its spots, on side `side` ("_a" or "_b"), facing
## the other one.
static func _pair_routine(spots: Array, side: String) -> Array:
	var out := []
	var face := Vector3(1, 0, 0) if side == "_a" else Vector3(-1, 0, 0)
	for s in spots:
		out.append({"at": s + side, "time": 34.0, "face": face, "clip": "idle"})
	return out


## The lines one speaker of a pair says in its gossip.
static func _gossip_lines(pair: int, speaker: int) -> Array:
	var out := []
	for topic in PAIR_TOPICS[pair]:
		out.append(GOSSIP[topic][speaker])
	return out


func _physics_process(delta: float) -> void:
	if run == null or not run.running:
		return
	if not toasting and run.time >= next_toast:
		start_toast(false)
	if toasting:
		_toast_tick(delta)
	_scold_t = maxf(0.0, _scold_t - delta)
	_tick -= delta
	if _tick > 0.0:
		return
	_tick = 0.25
	if _player == null:
		_player = get_tree().get_first_node_in_group("moth") as Moth
		if _player == null:
			return
	for i in pairs.size():
		_gossip(i)
	_waiter_calls()
	if not run.has("guard_left_desk") and ron.global_position.distance_to(level.points["desk"]) > 5.0:
		run.record("guard_left_desk")


# --- Gossip ----------------------------------------------------------------------

## Is this person free to chat (going about their evening, not alarmed)?
static func _free(p: Person) -> bool:
	return p.state == Person.State.ROUTINE and p._arrived


func _near(p: Person, reach: float) -> bool:
	return _player != null and _player.global_position.distance_to(p.global_position) < reach


func _gossip(i: int) -> void:
	if _talking[i] or run.time < _next_talk[i]:
		return
	var a: Person = pairs[i][0]
	var b: Person = pairs[i][1]
	if not (_free(a) and _free(b)) or a.global_position.distance_to(b.global_position) > 3.5:
		return
	if not (_near(a, GOSSIP_RANGE) or _near(b, GOSSIP_RANGE)):
		return
	for topic in PAIR_TOPICS[i]:
		if not heard.has(topic):
			_talk(i, topic)
			return


func _talk(i: int, topic: String) -> void:
	var a: Person = pairs[i][0]
	var b: Person = pairs[i][1]
	_talking[i] = true
	a.say(GOSSIP[topic][0])
	await get_tree().create_timer(GOSSIP_REPLY, false).timeout
	if not is_inside_tree():
		return
	_talking[i] = false
	_next_talk[i] = run.time + GOSSIP_PAUSE
	if not _free(b) or not run.running:
		return
	b.say(GOSSIP[topic][1])
	if _near(a, GOSSIP_RANGE + 1.5) or _near(b, GOSSIP_RANGE + 1.5):
		hear(topic)


## The player heard a piece of gossip.
func hear(topic: String) -> void:
	heard[topic] = true
	run.record("heard:" + topic)
	if heard.size() >= GOSSIP.size():
		run.record("heard_all_gossip")


# --- Waiting on the guests ---------------------------------------------------------

## A body on each guest the player can offer a drink to.
func _add_serve(p: Person) -> void:
	var s := UsableBody.new()
	s.name = "Serve"
	s.collision_layer = Kit.LAYER_INTERACT
	s.add_box(Vector3(0, 1.0, 0), Vector3(0.7, 1.9, 0.7))
	s.add_action("interact", "", _serve.bind(p))
	p.add_child(s)
	_serve_spots.append(s)


func _update_serve() -> void:
	var has := _player != null and _player.has_item("drinks")
	for s in _serve_spots:
		s.set_action_text("interact", "Offer a drink" if has else "")


func _serve(pic: PlayerInteractionComponent, p: Person) -> void:
	var player: Moth = pic.get_parent()
	if p.is_asleep() or p.is_alert() or not player.take_item("drinks"):
		return
	Sfx.at(level, "glass_clink", p.global_position + Vector3(0, 1.2, 0), -6.0)
	p.say(THANKS.get(String(p.name), "Thank you."))
	p.rig.play_once("emote-yes")
	served[p.name] = true
	run.record("served:" + String(p.name).to_lower())
	if served.size() >= 3:
		run.record("served_three")


## Guests wave a waiter with a tray over.
func _waiter_calls() -> void:
	if _player.disguise != "waiter" or not _player.has_item("drinks"):
		return
	for g in guests:
		if not CALLS.has(String(g.name)) or not _free(g) or not _near(g, CALL_RANGE):
			continue
		if run.time < float(_called.get(g, -999.0)) + CALL_PAUSE:
			continue
		_called[g] = run.time
		g.say(CALLS[String(g.name)])
		return


## The head waiter sees a waiter with empty hands.
func idle_waiter() -> void:
	if _scold_t > 0.0 or pring.is_alert() or pring.is_asleep():
		return
	_scold_t = SCOLD_PAUSE
	pring.say(Person._pick(["You there! Where's your tray?", "Idle hands! Get a tray from the kitchen."]))


# --- The toast ---------------------------------------------------------------------

## Starts Hoard's toast; `early` when the gong called it. False if he can't.
func start_toast(early: bool) -> bool:
	if toasting or hoard.is_asleep() or hoard.state == Person.State.CHASE:
		if not early:
			next_toast = run.time + 20.0
		return false
	if early and run.time - _last_toast_end < TOAST_GAP:
		return false
	toasting = true
	_toast_t = 0.0
	_speech_i = -1
	_speech_t = 0.0
	_hoard_ready = false
	_flashed = false
	run.record("toast")
	if early:
		run.record("early_toast")
	hoard.say(GONG_LINE if early else TOAST_CALL)
	for p in gathers:
		if p.state in [Person.State.ROUTINE, Person.State.WAIT]:
			p.wait_at(gathers[p], 999.0)
	level.set_chatter(false)
	return true


## Someone struck the gong.
func gong(_by: Node) -> void:
	start_toast(true)


func _toast_tick(delta: float) -> void:
	_toast_t += delta
	if hoard.is_asleep() or hoard.state == Person.State.CHASE:
		end_toast()
		return
	# The crowd turns to face Hoard.
	var at: Vector3 = hoard.global_position
	for p in gathers:
		if p != hoard and p.state == Person.State.WAIT and p._arrived:
			var to: Vector3 = at - p.global_position
			p.rig.rotation.y = lerp_angle(p.rig.rotation.y, atan2(to.x, to.z), 0.2)
	if not _hoard_ready:
		var there: bool = hoard.state == Person.State.WAIT and hoard._arrived
		if there:
			hoard.rig.rotation.y = PI
		if there or _toast_t > HOARD_WAIT:
			_hoard_ready = true
		return
	_speech_t += delta
	var i := int(_speech_t / SPEECH_GAP)
	if i < SPEECH.size():
		if i != _speech_i:
			_speech_i = i
			hoard.say(SPEECH[i])
			hoard.rig.play_once("emote-yes" if i == SPEECH.size() - 1 else "interact-right")
	elif not _flashed:
		_flashed = true
		_photo()
	elif _speech_t > (SPEECH.size() + 1.5) * SPEECH_GAP:
		end_toast()


func _photo() -> void:
	snapper.say(PHOTO_LINE)
	await get_tree().create_timer(1.6, false).timeout
	if not is_inside_tree():
		return
	hoard.say("Cheese!")
	var flash := OmniLight3D.new()
	flash.light_color = Color(1, 1, 1)
	flash.light_energy = 8.0
	flash.omni_range = 14.0
	level.add_child(flash)
	flash.global_position = snapper.global_position + Vector3(0, 1.8, 0)
	Sfx.at(level, "photo_flash", flash.global_position, -4.0)
	get_tree().create_timer(0.15, false).timeout.connect(flash.queue_free)
	if _player and PHOTO_BOX.has_point(_player.global_position) and _player.hiding == null:
		run.record("in_photo")


func end_toast() -> void:
	if not toasting:
		return
	toasting = false
	_last_toast_end = run.time
	next_toast = run.time + TOAST_EVERY
	for p in gathers:
		if p.state == Person.State.WAIT:
			p._resume_routine()
	level.set_chatter(true)


# --- Other moments -----------------------------------------------------------------

## The power went off at the plant room.
func lights_went_out() -> void:
	if not hoard.is_asleep() and not hoard.is_alert():
		hoard.say("Who turned the lights out? Ron!")
	for g in [pairs[0][0], pairs[1][1]]:
		if _free(g):
			g.say(LIGHTS_OUT_LINE)


func play_shanty() -> void:
	violinist.say("A sea shanty? At a gala?")
	await get_tree().create_timer(2.6, false).timeout
	if is_inside_tree():
		cellist.say("Ooh, I love this one!")


func _on_event(event: String) -> void:
	if event != "escaped":
		return
	if ron.is_asleep():
		run.record("left_guard_asleep")
	if level.way_out_here() == "roof":
		run.record("escaped_from:roof")
