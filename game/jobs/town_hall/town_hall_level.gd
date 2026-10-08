class_name TownHallLevel
extends JobLevel
## Kettleford town hall on council night: two storeys, a cellar archive and
## a roof with a bell tower, on a 2 m grid. X runs east, Z runs south
## towards the square, and each storey is 2.5 m.
##
## Ground floor: the lobby (reception, noticeboard, the main stairs), the
## cloakroom and the caretaker's cupboard (fuse box) to the west, the tea
## room and the staff hall (clerk's office, post room, the archive stair)
## to the east, and the council chamber at the back, two storeys high,
## packed with townsfolk on benches facing the dais. The back stair climbs
## from the side door to the roof house and its bell rope. Upstairs: the
## mayor's office with the strongbox and the balcony over the front doors,
## the committee room and the members' room. The single-storey annex over
## the clerk's office has a flat roof; so does the main building.
##
## Routes to the charter:
## - Coat check: borrow a coat in the cloakroom (townsfolk walk the lobby
##   and chamber unnoticed), take the key from the mayor's red coat, sneak
##   up the back stair, open her door and the strongbox with her key, and
##   walk out of the front doors with the crowd.
## - The clerk's numbers: the spare lanyard behind reception passes for a
##   clerk everywhere but in front of Dobbs himself. Read his sticky note
##   (71..), the date on the photo of the green in the archive (..24), walk
##   up the main stairs and dial 7124.
## - Over the roof: from the car park, the bins by the clerk's window, the
##   annex roof, the air vent and the main roof; drop onto the balcony and
##   in at the open window. Hide in the wardrobe until ten, when the mayor
##   opens the box herself; snooze or distract her and take it.
## - Lights out: the side door (picked, or when Stanley comes back in from
##   the car park), the caretaker's cupboard and the main breaker. The
##   whole building goes dark, Stanley heads for the fuses and the lobby,
##   the stairs and the corridor are pitch black.
## - The lectern: miss the deadline and the charter sits on the lectern in
##   front of everybody. Cut the power, or walk up to it as the clerk while
##   Dobbs is in his office, and take it off the dais.
## - The clerk's window: the open window in the clerk's office lets you into
##   the staff side from the back yard while Dobbs is in the chamber, then
##   down to the archive and up the staff hall.

const UP := JobLevel.STOREY
const ROOF := JobLevel.STOREY * 2.0
const BASE := -JobLevel.STOREY
const TOWER_TOP := ROOF + JobLevel.STOREY

const CHARTER := "res://game/jobs/town_hall/charter.tscn"
const CHEST := "res://assets/kenney/survival-kit/chest.glb"
const BUCKET := "res://assets/kenney/survival-kit/bucket.glb"
const CARS := "res://assets/kenney/car-kit/"
const MODULAR := "res://assets/kenney/modular-buildings/"
const LIGHTPOST := "res://assets/kenney/graveyard-kit/lightpost-single.glb"

## The strongbox's combination: Dobbs's half, then the day on the photo.
const CODE := "7124"
## Run time when the mayor goes to fetch the charter for the vote.
const VOTE_TIME := 300.0
## Run time when she warns everyone the vote is coming.
const WARN_TIME := 240.0

const MARBLE := Color(0.8, 0.78, 0.72)
const CARPET_RED := Color(0.5, 0.18, 0.18)
const CARPET_GREEN := Color(0.26, 0.38, 0.3)
const CARPET_BLUE := Color(0.3, 0.35, 0.5)
const WOOD := Color(0.55, 0.38, 0.24)
const WOOD_DARK := Color(0.36, 0.22, 0.14)
const CONCRETE := Color(0.5, 0.5, 0.49)
const PAVING := Color(0.56, 0.54, 0.5)
const ASPHALT := Color(0.22, 0.22, 0.24)
const GRASS := Color(0.24, 0.4, 0.2)
const HEDGE := Color(0.16, 0.3, 0.15)
const BRICK := Color(0.5, 0.3, 0.24)
const ROOF_FELT := Color(0.3, 0.3, 0.32)
const STONE := Color(0.75, 0.72, 0.64)
const BRASS := Color(0.72, 0.55, 0.2)

## Lights on when the night starts.
const LIGHTS_ON := ["lobby", "portico", "cloakroom", "passage_w", "west_hall", "chamber_front",
	"chamber", "clerk_office", "staff_hall", "tea_room", "corridor", "landing", "square", "car_park", "yard"]
## Lights that go off with the main breaker (all but the street lamps).
const BUILDING_CIRCUIT := ["lobby", "portico", "cloakroom", "passage_w", "passage_e", "west_hall",
	"cupboard", "chamber_front", "chamber", "chamber_back", "clerk_office", "staff_hall", "archive",
	"post_room", "tea_room", "corridor", "landing", "mayor_office", "committee", "members",
	"stair_up", "roof_house", "balcony"]

const S := Vector3(0, 0, 1)
const N := Vector3(0, 0, -1)
const E := Vector3(1, 0, 0)
const W := Vector3(-1, 0, 0)
## Where a seated person's rig sits relative to where they stand, facing
## south at the council table (they settle back onto the chair).
const SIT_TABLE := Vector3(0, 0.02, -0.32)
## A seated townsperson on a bench: their place is the bench itself.
const SIT_BENCH := Vector3(0, -0.08, 0)

const STAFF_NOTICE := """STAFF NOTICE

Will whoever keeps borrowing the SPARE CLERK'S LANYARD from the drawer behind reception please PUT IT BACK.

It has the staff key on it. It is not a toy.

- D. Dobbs, Clerk to the Council"""

const AGENDA := """KETTLEFORD TOWN COUNCIL
Council meeting, tonight, 8 o'clock

1. Apologies
2. The pothole on Mill Lane (again)
3. Mr A. Hoard: his offer for the town green
4. THE VOTE, at 10 o'clock sharp.
   The mayor will bring the town charter down from her office."""

const STICKY_NOTE := """Mayor's strongbox:
7 1 _ _

The last two are her idea. "Something to do with the green," she says. Very helpful.

- D."""

const GREEN_PHOTO := """(A faded photograph of townsfolk in top hats on the green, waving.)

KETTLEFORD GREEN
Given to the people of the town, for ever.
24th May, 1846"""

const MAYOR_DIARY := """Mayor P. Pell, her diary

Tuesday. Hoard sent flowers again. And a cheque "for the bandstand". Sent both back.

Wednesday. Changed the strongbox combination. Dobbs has the first half on one of his sticky notes (honestly). The rest is the day the green was given to the town. If I forget it all, the spare key is in my red coat.

Thursday. Council night. I have to fetch the charter at ten for the vote. I'd rather eat my hat."""

const HOARD_SPEECH := """MY SPEECH (A. Hoard)

Friends! Neighbours! Voters! (Smile here.)

Imagine a car park where that soggy old green is now. Forty spaces! (Pause for applause.)

All of them reserved. For me. (Don't say this bit.)

The charter says the green is the town's "for ever". But what is for ever, really? (Don't let them answer.)

Vote YES, and I'll throw in a bench. (Cheap one.)"""

const RECIPE := """MRS DUNN'S VICTORIA SPONGE

200g butter, 200g sugar, 4 eggs, 200g self-raising flour.
Beat, fold, two tins, 20 minutes until golden.
Jam in the middle. NOT cream, whatever Gwen says."""

const CARETAKER_NOTE := """TO THE BELL RINGERS
Practice is off tonight (council meeting).

And STOP climbing the bins by the clerk's window to get on the annex roof. I can see your footprints.

And Mayor Pell, PLEASE shut your balcony window. The pigeons are getting in.

- Stanley (Caretaker)"""

const HOARD_LETTER := """Dear Councillors,

Please find enclosed a small token of my esteem. One each. Do spend it wisely.

When the vote comes, remember who your friends are. The charter is only old paper, after all.

Yours in friendship,
Augustus Hoard"""

const HOARD_POCKET := """(A list in Hoard's coat pocket.)

1. Buy the green.
2. Pave the green.
3. Rename it Hoard Square.
4. Charge for parking."""

const MINUTES_1846 := """MINUTES OF THE TOWN MEETING, 1846

Resolved: that the green shall belong to the people of Kettleford for ever, to walk on, to play on and to hold the fair on.

Resolved: that the charter be kept safe by the mayor, and brought out only when the green is spoken of."""

const BELL_RULES := """BELL ROPE
Pull gently. ONE ring for council, three for the fair.

Mr Hoard says the bell is "too loud" and wants it taken down. Over my dead body. - S."""

const SPEECH_LINES := [
	"Friends! Neighbours! Imagine a car park where that soggy green is now!",
	"Forty spaces! Forty! All of them reserved. For me.",
	"The charter says for ever. But what is for ever, really?",
]
const RECIPE_LINES := [
	"Two hundred grams of butter, two hundred grams of sugar... what?",
	"Bake for twenty minutes until golden? Who gave me a recipe?",
	"Jam in the middle. Not cream. This isn't my speech!",
]

const CROWD_CHAT := [
	"Did you hear what he wants to do to the green?",
	"My nan got engaged on that green.",
	"A car park? Over my dead begonias.",
	"Is there tea after?",
	"He's not even from Kettleford.",
	"Shh, she's talking.",
	"Where will we hold the fair?",
	"Forty spaces. For him.",
	"I brought biscuits.",
	"Who's that at the back?",
	"I'm voting no. Can we vote?",
	"My feet have gone to sleep.",
]

var mayor: TownHallPerson
var clerk: TownHallPerson
var caretaker: TownHallPerson
var hoard: TownHallPerson
var crowd: Array = []
var strongbox_pad: Keypad
var box_open := false
## Where the charter is: "box", "mayor" (she's carrying it), "lectern",
## "floor" (she dropped it) or "player".
var charter_at := "box"
var vote_called := false
var speech_swapped := false
var sign_left := false
var mop_left := false
var lectern: UsableBody
var sign_spot: UsableBody
var mop_spot: UsableBody
var rope: UsableBody
var mayor_coat: UsableBody
var seats: Array = []
var _chest: Node3D
var _carried: Node3D
var _bell: Node3D
var _bell_t := 0.0
var _player: Moth
var _warned := false
var _stand_home := Vector3.ZERO
var _stand_place := "box"


func build() -> void:
	circuit = BUILDING_CIRCUIT
	alarm_time = 25.0
	_grounds()
	_ground_floor()
	_basement()
	_upstairs()
	_roof()
	_bell_tower()
	_chamber()
	_furnish()
	_lamps()
	_things()
	_marks()
	house_boxes.append(AABB(Vector3(-12, -0.5, 0), Vector3(24, 5.5, 8)))
	house_boxes.append(AABB(Vector3(-12, -0.5, -10), Vector3(20, 5.5, 10)))
	house_boxes.append(AABB(Vector3(8, -3.0, -10), Vector3(4, 5.4, 10)))
	house_boxes.append(AABB(Vector3(8, -3.0, 0), Vector3(4, 2.6, 4)))
	house_boxes.append(AABB(Vector3(-12, ROOF, -10), Vector3(4, 3.0, 8)))
	areas["mayor_office"] = AABB(Vector3(-4, UP + 0.1, 2), Vector3(6, 2.4, 6))
	areas["main_stairs"] = AABB(Vector3(2.6, 1.2, 3.0), Vector3(1.5, 2.6, 4.2))
	areas["roof"] = AABB(Vector3(-8, ROOF + 0.4, -10), Vector3(20, 3, 18))
	areas["chamber"] = AABB(Vector3(-8, -0.5, -10), Vector3(16, 3, 10))
	areas["archive"] = AABB(Vector3(8, -3, -10), Vector3(4, 2.4, 14))
	# Townsfolk belong in the lobby, cloakroom, tea room and on the benches;
	# a clerk belongs nearly everywhere; nobody belongs in Stanley's cupboard
	# or up by the bell.
	add_zone("staff", AABB(Vector3(8, -3, -10), Vector3(4, 5.4, 18)), ["clerk"])
	add_zone("upstairs", AABB(Vector3(-12, UP + 0.1, -10), Vector3(24, 2.4, 20.5)), ["clerk"])
	add_zone("back_stair", AABB(Vector3(-12, -0.5, -10), Vector3(4, 2.9, 14)), ["clerk"])
	add_zone("dais", AABB(Vector3(-8, -0.5, -10), Vector3(16, 3, 2.6)), ["clerk"])
	add_zone("cupboard", AABB(Vector3(-12, -0.5, 4), Vector3(4, 3, 4)), [])
	add_zone("roof_house", AABB(Vector3(-12, ROOF, -10), Vector3(4, 3, 8)), [])
	# The meeting's chatter drowns out footsteps at the back of the chamber.
	add_masking(AABB(Vector3(-8, -0.5, -5.4), Vector3(16, 5, 5.6)), 0.75)
	at_way_out.connect(_on_way_out)
	for room in lights:
		set_lights(room, room in LIGHTS_ON)


# --- Outside -------------------------------------------------------------------------

func _grounds() -> void:
	# Paving round the building, the square in front, the road and the green.
	Kit.block(self, Vector3(-2, -0.06, 11), Vector3(50, 0.1, 6), "concrete", Kit.flat(PAVING))
	Kit.block(self, Vector3(-2, -0.07, 16.5), Vector3(50, 0.1, 5), "concrete", Kit.flat(ASPHALT))
	Kit.block(self, Vector3(-2, -0.06, 20), Vector3(50, 0.1, 2), "concrete", Kit.flat(PAVING))
	Kit.block(self, Vector3(-2, -0.06, 28), Vector3(50, 0.1, 14), "grass", Kit.flat(GRASS))
	Kit.block(self, Vector3(-19, -0.07, -7), Vector3(14, 0.1, 30), "concrete", Kit.flat(ASPHALT))
	Kit.block(self, Vector3(5, -0.07, -16), Vector3(34, 0.1, 12), "concrete", Kit.flat(ASPHALT))
	Kit.block(self, Vector3(17, -0.06, -1), Vector3(10, 0.1, 18), "concrete", Kit.flat(PAVING))
	# Road markings and parking bays (no collision).
	for x in range(-24, 22, 4):
		_slab(Vector3(x, 0.0, 16.5), Vector3(1.8, 0.01, 0.15), Color(0.9, 0.88, 0.8))
	for z in [-18.0, -14.0, -10.0, -6.0, -2.0, 2.0]:
		_slab(Vector3(-22, 0.0, z), Vector3(5, 0.01, 0.12), Color(0.9, 0.88, 0.8))
	# Brick walls round the yard and car park, hedges round the green.
	var brick := Kit.flat(BRICK)
	Kit.block(self, Vector3(-26.5, 1.3, -7), Vector3(1, 2.6, 31), "", brick)
	Kit.block(self, Vector3(-2, 1.3, -22.5), Vector3(50, 2.6, 1), "", brick)
	Kit.block(self, Vector3(22.5, 1.3, -7), Vector3(1, 2.6, 31), "", brick)
	var hedge := Kit.flat(HEDGE)
	Kit.block(self, Vector3(-26.5, 1.3, 21.5), Vector3(1, 2.6, 27), "", hedge)
	Kit.block(self, Vector3(22.5, 1.3, 21.5), Vector3(1, 2.6, 27), "", hedge)
	Kit.block(self, Vector3(-2, 1.3, 35.5), Vector3(50, 2.6, 1), "", hedge)
	# The green: trees, benches and the bandstand.
	for t in [Vector3(-18, 0, 26), Vector3(-9, 0, 31), Vector3(10, 0, 30), Vector3(17, 0, 25), Vector3(2, 0, 32)]:
		var tree := Kit.boxed(self, Kit.SUBURBAN + "tree-large.glb", t, randf() * 360.0, 6.0)
		var cs: CollisionShape3D = tree.get_child(1)
		cs.shape.size = Vector3(0.4, 4.0, 0.4)
		cs.position = Vector3(0, 2.0, 0)
	for b in [[Vector3(-6, 0, 22.5), 0.0], [Vector3(6, 0, 22.5), 0.0], [Vector3(-14, 0, 23), 30.0]]:
		_centered(Kit.FURNITURE + "bench.glb", b[0], b[1], Vector3(3.5, 2, 2), true)
	var stand := Kit.block(self, Vector3(-1, 0.25, 27), Vector3(5, 0.5, 5), "wood", Kit.flat(Color(0.85, 0.85, 0.8)))
	stand.name = "Bandstand"
	for c in [Vector3(-3.2, 0, 24.8), Vector3(1.2, 0, 24.8), Vector3(-3.2, 0, 29.2), Vector3(1.2, 0, 29.2)]:
		Kit.block(self, c + Vector3(0, 1.75, 0), Vector3(0.18, 2.5, 0.18), "", Kit.flat(Color(0.95, 0.95, 0.9)))
	var cap := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.05
	cone.bottom_radius = 3.6
	cone.height = 1.4
	cone.radial_segments = 8
	cone.material = Kit.flat(Color(0.45, 0.6, 0.45))
	cap.mesh = cone
	cap.position = Vector3(-1, 3.7, 27)
	add_child(cap)
	_label("SAVE OUR GREEN", Vector3(-1, 1.2, 24.45), 180.0, 64, Color(0.95, 0.9, 0.5))
	# Neighbours round the square and behind the yard (out of reach).
	for b in [["building-sample-house-c", Vector3(-32, 0, 14), 90.0], ["building-sample-tower-a", Vector3(-32, 0, 4), 90.0],
			["building-sample-tower-c", Vector3(-32, 0, -6), 90.0], ["building-sample-house-b", Vector3(-32, 0, -16), 90.0],
			["building-sample-tower-b", Vector3(28, 0, 14), -90.0], ["building-sample-house-a", Vector3(28, 0, 5), -90.0],
			["building-sample-tower-d", Vector3(28, 0, -5), -90.0], ["building-sample-house-c", Vector3(28, 0, -15), -90.0],
			["building-sample-tower-a", Vector3(-16, 0, -28), 180.0], ["building-sample-tower-c", Vector3(-6, 0, -28), 180.0],
			["building-sample-house-b", Vector3(4, 0, -28), 180.0], ["building-sample-tower-b", Vector3(14, 0, -28), 180.0],
			["building-sample-tower-d", Vector3(-20, 0, 41), 0.0], ["building-sample-house-c", Vector3(-8, 0, 41), 0.0],
			["building-sample-tower-a", Vector3(4, 0, 41), 0.0], ["building-sample-house-a", Vector3(15, 0, 41), 0.0]]:
		Kit.model(self, MODULAR + b[0] + ".glb", b[1], b[2], 4.0)
	# Cars: Hoard's shiny one, Stanley's van, somebody's runabout.
	Kit.boxed(self, CARS + "sedan-sports.glb", Vector3(-22, 0, -4), 90.0, 1.4)
	Kit.boxed(self, CARS + "van.glb", Vector3(-22, 0, -16), 90.0, 1.4)
	Kit.boxed(self, CARS + "sedan.glb", Vector3(-22, 0, 4), 90.0, 1.4)
	Kit.boxed(self, CARS + "sedan.glb", Vector3(-3, 0, -18), 180.0, 1.4)
	_label("RESERVED: A. HOARD", Vector3(-25.9, 1.4, -4), 90.0, 40, Color(0.95, 0.9, 0.85))
	# The bins under the clerk's window, the climb onto the annex roof.
	for x in [9.6, 10.6]:
		Kit.block(self, Vector3(x, 0.55, -10.6), Vector3(0.8, 1.1, 0.9), "concrete", Kit.flat(Color(0.2, 0.36, 0.26)))
	# A skip by the yard wall, and crates by the goods door.
	Kit.block(self, Vector3(0, 0.6, -20.5), Vector3(3.6, 1.2, 1.8), "concrete", Kit.flat(Color(0.75, 0.55, 0.15)))
	Kit.boxed(self, Kit.FURNITURE + "cardboardBoxClosed.glb", Vector3(13, 0, -1.2), 20.0, 2.0)
	Kit.boxed(self, Kit.FURNITURE + "cardboardBoxClosed.glb", Vector3(13.2, 0, 0), 0.0, 2.0)


func _ground_floor() -> void:
	floor_rect(0, -4, 0, 4, 8, "tile", MARBLE, false)
	floor_rect(0, -8, 0, -4, 2, "wood", WOOD, false)
	floor_rect(0, -8, 2, -4, 8, "carpet", CARPET_GREEN, false)
	floor_rect(0, -12, -10, -8, 4, "wood", WOOD, false)
	floor_rect(0, -12, 4, -8, 8, "concrete", CONCRETE, false)
	floor_rect(0, -8, -10, 8, 0, "wood", WOOD, false)
	floor_rect(0, 4, 0, 8, 2, "wood", WOOD, false)
	floor_rect(0, 4, 2, 8, 8, "tile", Color(0.72, 0.76, 0.74), false)
	floor_rect(0, 8, 4, 12, 8, "wood", WOOD, false)
	# The staff side has the archive under it, so its floors have ceilings,
	# and a hole for the archive stair.
	floor_rect(0, 8, -10, 12, -4, "carpet", CARPET_BLUE)
	floor_rect(0, 8, -4, 10.7, 4, "wood", WOOD)
	floor_rect(0, 10.7, -4, 12, -2, "wood", WOOD)
	floor_rect(0, 10.7, 2, 12, 4, "wood", WOOD)
	# Outside walls.
	line(0, Vector2(-12, 8), Vector2(1, 0), "WWwwwDDwwwwW", [
		{"id": "front_left", "into": Vector2(-1, 6), "outside": true},
		{"id": "front_right", "into": Vector2(1, 6), "outside": true}])
	line(0, Vector2(-12, -10), Vector2(1, 0), "WWWwWWWWwWoW", ["clerk_window"])
	line(0, Vector2(-12, -10), Vector2(0, 1), "WwWWWDWwW", [
		{"id": "side_door", "into": Vector2(-10, 1), "locked": true, "key": "staff_key", "pick": 5.0, "outside": true}])
	line(0, Vector2(12, -10), Vector2(0, 1), "WwWDWWWwW", [
		{"id": "goods_door", "into": Vector2(10, -3), "locked": true, "key": "staff_key", "pick": 6.0, "outside": true}])
	# Inside walls.
	line(0, Vector2(-8, -10), Vector2(0, 1), "DWWWWdWWW", [{"id": "chamber_west", "into": Vector2(-6, -9)}])
	line(0, Vector2(-4, 0), Vector2(0, 1), "dWdW")
	line(0, Vector2(-8, 2), Vector2(1, 0), "WW")
	line(0, Vector2(-12, 4), Vector2(1, 0), "WD", [
		{"id": "cupboard_door", "into": Vector2(-9, 6), "locked": true, "key": "staff_key", "pick": 4.0}])
	line(0, Vector2(-8, 0), Vector2(1, 0), "WWdWWdWW")
	line(0, Vector2(4, 0), Vector2(0, 1), "dWWW")
	line(0, Vector2(4, 2), Vector2(1, 0), "DW", [{"id": "tea_door", "into": Vector2(5, 4)}])
	line(0, Vector2(8, -10), Vector2(0, 1), "WDWWWDWWW", [
		{"id": "chamber_east", "into": Vector2(10, -7)},
		{"id": "staff_door", "into": Vector2(10, 1), "locked": true, "key": "staff_key", "pick": 4.0}])
	line(0, Vector2(8, -4), Vector2(1, 0), "DW", [{"id": "clerk_door", "into": Vector2(9, -6)}])
	line(0, Vector2(8, 4), Vector2(1, 0), "DW", [{"id": "post_door", "into": Vector2(10, 6)}])
	# The main stairs climb north along the lobby's east wall.
	_stairs(Vector3(3.35, 0, 5), 7, 3, 2.7, 4.0, "wood")
	# The back stair: ground to first floor, then first floor to the roof house.
	_stairs(Vector3(-11.35, 0, -4), -2, -6, -12.0, -10.7, "wood")
	# Railings round the archive stair.
	var rail := Kit.flat(WOOD_DARK)
	Kit.block(self, Vector3(10.7, 0.5, 0), Vector3(0.08, 1.0, 4.0), "", rail)
	Kit.block(self, Vector3(11.35, 0.5, -2), Vector3(1.3, 1.0, 0.08), "", rail)


func _basement() -> void:
	floor_rect(BASE, 8, -10, 12, 4, "concrete", Color(0.42, 0.42, 0.42), false)
	line(BASE, Vector2(8, -10), Vector2(1, 0), "WW")
	line(BASE, Vector2(8, 4), Vector2(1, 0), "WW")
	line(BASE, Vector2(8, -10), Vector2(0, 1), "WWWWWWW")
	line(BASE, Vector2(12, -10), Vector2(0, 1), "WWWWWWW")
	# Down from the staff hall, heading north.
	_stairs(Vector3(11.35, BASE, 0), -2, 2, 10.7, 12.0, "wood")


func _upstairs() -> void:
	floor_rect(UP, -12, 0, 12, 2, "carpet", CARPET_BLUE)
	floor_rect(UP, 2, 2, 4, 3, "carpet", CARPET_BLUE)
	floor_rect(UP, -4, 2, 2, 8, "carpet", CARPET_RED)
	floor_rect(UP, -12, 2, -4, 8, "wood", WOOD)
	floor_rect(UP, 4, 2, 12, 8, "carpet", CARPET_GREEN)
	floor_rect(UP, -12, -10, -8, -6, "wood", WOOD)
	floor_rect(UP, -10.7, -6, -8, -2, "wood", WOOD)
	floor_rect(UP, -12, -2, -8, 0, "wood", WOOD)
	# The balcony over the front doors.
	floor_rect(UP, -4, 8, 2, 10, "concrete", STONE)
	line(UP, Vector2(-4, 10), Vector2(1, 0), "---")
	line(UP, Vector2(-4, 8), Vector2(0, 1), "-")
	line(UP, Vector2(2, 8), Vector2(0, 1), "-")
	# Outside walls.
	line(UP, Vector2(-12, 8), Vector2(1, 0), "wwwwoDwwwwwW", ["balcony_window",
		{"id": "balcony_door", "into": Vector2(-1, 6), "locked": true, "key": "mayor_key", "pick": 6.0, "outside": true}])
	line(UP, Vector2(-12, -10), Vector2(1, 0), "WW")
	line(UP, Vector2(-12, -10), Vector2(0, 1), "WwWWWWwWw")
	line(UP, Vector2(12, 0), Vector2(0, 1), "WwWw")
	line(UP, Vector2(8, 0), Vector2(1, 0), "Wo", ["annex_window"])
	# The chamber's upper walls: windows over the annex roof and onto the
	# corridor (the public gallery), and one onto the back stair.
	line(UP, Vector2(-8, -10), Vector2(1, 0), "WwWwwWwW")
	line(UP, Vector2(8, -10), Vector2(0, 1), "wwwoW", ["chamber_high_window"])
	line(UP, Vector2(-8, -10), Vector2(0, 1), "WwWWW")
	line(UP, Vector2(-8, 0), Vector2(1, 0), "WWWwwWWW")
	# Rooms off the corridor.
	line(UP, Vector2(-12, 2), Vector2(1, 0), "WWWDWDW.DWWW", [
		{"id": "members_door", "into": Vector2(-5, 4)},
		{"id": "mayor_door", "into": Vector2(-1, 4), "locked": true, "key": "mayor_key", "pick": 8.0},
		{"id": "committee_door", "into": Vector2(5, 4)}])
	line(UP, Vector2(-4, 2), Vector2(0, 1), "WWW")
	line(UP, Vector2(2, 2), Vector2(0, 1), "WWW")
	line(UP, Vector2(4, 2), Vector2(0, 1), "WWW")
	_stairs(Vector3(-8.65, UP, -4), -2, -6, -9.3, -8.0, "wood")
	# A rail beside the back stair's well.
	Kit.block(self, Vector3(-10.7, UP + 0.5, -4), Vector3(0.08, 1.0, 4.0), "", Kit.flat(WOOD_DARK))


func _roof() -> void:
	floor_rect(ROOF, -8, -10, 8, 0, "concrete", ROOF_FELT)
	floor_rect(ROOF, -12, 0, 12, 8, "concrete", ROOF_FELT)
	floor_rect(ROOF, -12, -2, -8, 0, "concrete", ROOF_FELT)
	floor_rect(UP, 8, -10, 12, 0, "concrete", ROOF_FELT)
	# The roof house at the top of the back stair, with the bell rope.
	floor_rect(ROOF, -12, -10, -8, -6, "wood", WOOD)
	floor_rect(ROOF, -12, -6, -9.3, -2, "wood", WOOD)
	line(ROOF, Vector2(-12, -10), Vector2(1, 0), "WW")
	line(ROOF, Vector2(-12, -2), Vector2(1, 0), "WW")
	line(ROOF, Vector2(-12, -10), Vector2(0, 1), "WWwW")
	line(ROOF, Vector2(-8, -10), Vector2(0, 1), "DWwW", [
		{"id": "roof_door", "into": Vector2(-10, -9), "outside": true}])
	floor_rect(TOWER_TOP, -12, -10, -8, -2, "concrete", ROOF_FELT)
	# A stone cornice round the roof's edge (just for looks).
	_slab(Vector3(0, ROOF + 0.12, 8.05), Vector3(24.3, 0.3, 0.3), STONE)
	_slab(Vector3(-12.05, ROOF + 0.12, -1), Vector3(0.3, 0.3, 18.3), STONE)
	_slab(Vector3(12.05, ROOF + 0.12, 4), Vector3(0.3, 0.3, 8.3), STONE)
	_slab(Vector3(0, ROOF + 0.12, -10.05), Vector3(16.3, 0.3, 0.3), STONE)
	_slab(Vector3(10, UP + 0.12, -10.05), Vector3(4.3, 0.3, 0.3), STONE)
	_slab(Vector3(12.05, UP + 0.12, -5), Vector3(0.3, 0.3, 10.3), STONE)
	# The air vent on the annex roof: the climb up to the main roof.
	Kit.block(self, Vector3(8.75, UP + 0.36, -1.0), Vector3(1.3, 0.72, 1.3), "concrete", Kit.flat(Color(0.6, 0.62, 0.64)))
	Kit.boxed(self, MODULAR + "detail-ac-a.glb", Vector3(8.75, UP + 0.72, -1.0), 0.0, 5.0, "concrete")
	# A flower box on the balcony, to climb back up to the roof.
	Kit.block(self, Vector3(1.4, UP + 0.45, 8.5), Vector3(0.9, 0.9, 0.7), "wood", Kit.flat(WOOD_DARK))
	for x in [1.15, 1.45, 1.75]:
		var f := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.16
		sm.height = 0.3
		sm.material = Kit.flat(Color(0.85, 0.3, 0.4) if x != 1.45 else Color(0.95, 0.85, 0.3))
		f.mesh = sm
		f.position = Vector3(x, UP + 1.0, 8.5)
		add_child(f)
	# Chimney stacks and skylights for something to hide behind on the roof.
	Kit.block(self, Vector3(6, ROOF + 0.8, 5), Vector3(1.2, 1.6, 1.2), "concrete", Kit.flat(BRICK))
	Kit.block(self, Vector3(-6, ROOF + 0.8, 4), Vector3(1.2, 1.6, 1.2), "concrete", Kit.flat(BRICK))
	Kit.block(self, Vector3(0, ROOF + 0.3, -5), Vector3(3, 0.6, 2), "concrete", Kit.flat(Color(0.55, 0.65, 0.72)))


func _bell_tower() -> void:
	# Four columns on the roof house and a pointed cap, with the bell.
	for c in [Vector3(-11.7, 0, -9.7), Vector3(-8.3, 0, -9.7), Vector3(-11.7, 0, -6.3), Vector3(-8.3, 0, -6.3)]:
		Kit.model(self, Kit.BUILDING + "column.glb", c + Vector3(0, TOWER_TOP, 0), 0.0, 1.0)
	_slab(Vector3(-10, TOWER_TOP + 2.55, -8), Vector3(4.3, 0.3, 4.3), STONE)
	var spire := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.02
	cone.bottom_radius = 2.9
	cone.height = 2.6
	cone.radial_segments = 4
	cone.material = Kit.flat(Color(0.25, 0.32, 0.4))
	spire.mesh = cone
	spire.position = Vector3(-10, TOWER_TOP + 4.0, -8)
	spire.rotation.y = PI * 0.25
	add_child(spire)
	_bell = Node3D.new()
	_bell.name = "Bell"
	_bell.position = Vector3(-10, TOWER_TOP + 2.3, -8)
	add_child(_bell)
	var bell := MeshInstance3D.new()
	var bm := CylinderMesh.new()
	bm.top_radius = 0.32
	bm.bottom_radius = 0.6
	bm.height = 0.9
	bm.material = Kit.flat(BRASS, 0.4)
	bell.mesh = bm
	bell.position = Vector3(0, -0.6, 0)
	_bell.add_child(bell)
	_label("KETTLEFORD 1846", Vector3(-10, TOWER_TOP - 0.6, -1.92), 0.0, 48, Color(0.95, 0.9, 0.75))


func _chamber() -> void:
	# The dais at the north end, with the council table, the lectern and
	# the clerk's desk.
	Kit.block(self, Vector3(0, 0.1, -8.75), Vector3(12, 0.2, 2.5), "wood", Kit.flat(WOOD_DARK))
	_centered(Kit.FURNITURE + "tableCloth.glb", Vector3(-1.2, 0.2, -8.5), 0.0, Vector3(7.0, 2, 1.6), true)
	for x in [-3.3, -2.0, -0.6, 0.8]:
		_centered(Kit.FURNITURE + "chairCushion.glb", Vector3(x, 0.2, -9.6), 0.0, Vector3(2, 2, 2), false)
	Kit.block(self, Vector3(3.4, 0.75, -7.95), Vector3(0.7, 1.1, 0.5), "wood", Kit.flat(WOOD))
	_slab(Vector3(3.4, 1.33, -8.0), Vector3(0.8, 0.06, 0.62), WOOD_DARK)
	Kit.furniture(self, "sideTable", Vector3(5.1, 0.2, -8.6), 90)
	# A carpet runner up the middle and across the back: quiet to walk on.
	Kit.block(self, Vector3(0, 0.01, -3.7), Vector3(2.2, 0.02, 7.4), "carpet", Kit.flat(CARPET_RED))
	Kit.block(self, Vector3(0, 0.01, -1.0), Vector3(16, 0.02, 2.0), "carpet", Kit.flat(CARPET_RED))
	# The town's name over the dais.
	_label("KETTLEFORD TOWN COUNCIL", Vector3(0, 3.6, -9.9), 0.0, 120, Color(0.95, 0.85, 0.5))
	_slab(Vector3(0, 3.6, -9.95), Vector3(9.5, 0.9, 0.04), Color(0.2, 0.25, 0.4))
	# Benches in three rows, facing the dais.
	for z in [-6.2, -4.6, -3.0]:
		for side in [-1.0, 1.0]:
			var cx: float = side * 3.8
			Kit.block(self, Vector3(cx, 0.25, z), Vector3(5.2, 0.5, 0.42), "wood")
			for i in 4:
				_centered(Kit.FURNITURE + "bench.glb", Vector3(cx - 1.95 + i * 1.3, 0, z), 180.0, Vector3(3.2, 2, 2), false)
	# The public sits; the empty seats at the back are the ones to take.
	for s in [[Vector3(-5.75, 0, -3.0), "back_left"], [Vector3(-1.85, 0, -3.0), "back_middle"], [Vector3(3.15, 0, -3.0), "back_right"]]:
		var seat := TownHallSeat.make_seat(s[1], Vector3(0, 1.05, 0.05))
		seat.position = s[0]
		seat.rotation.y = PI
		add_child(seat)
		seats.append(seat)


func _furnish() -> void:
	# Lobby: reception between the chamber doors, the noticeboard, plants.
	for x in [-1.3, -0.44, 0.42, 1.28]:
		Kit.furniture(self, "kitchenBar", Vector3(x, 0, 1.8), 180)
	Kit.furniture(self, "sideTableDrawers", Vector3(-0.8, 0, 0.35), 0)
	_centered(Kit.FURNITURE + "chairDesk.glb", Vector3(0.6, 0, 0.9), 180.0, Vector3(2, 2, 2), false)
	_slab(Vector3(-3.95, 1.55, 7.0), Vector3(0.05, 1.1, 1.6), Color(0.6, 0.45, 0.3))
	Kit.furniture(self, "pottedPlant", Vector3(-3.5, 0, 3.0), 0)
	_centered(Kit.FURNITURE + "rugRectangle.glb", Vector3(-0.5, 0, 5.2), 90.0, Vector3(2, 2, 2), false)
	_label("COUNCIL CHAMBER", Vector3(0, 2.2, 0.07), 0.0, 56, Color(0.95, 0.85, 0.5))
	# Cloakroom: coat rails along the west wall.
	for z in [3.2, 4.8, 6.4]:
		Kit.furniture(self, "coatRackStanding", Vector3(-7.5, 0, z), 0)
	for c in [[Vector3(-7.35, 0.9, 3.0), Color(0.3, 0.32, 0.45)], [Vector3(-7.35, 0.9, 3.5), Color(0.45, 0.35, 0.25)],
			[Vector3(-7.35, 0.9, 5.0), Color(0.25, 0.4, 0.3)], [Vector3(-7.35, 0.9, 6.7), Color(0.4, 0.4, 0.4)]]:
		_coat(c[0], c[1])
	Kit.furniture(self, "bench", Vector3(-5, 0, 7.6), 180)
	# The caretaker's cupboard: shelves, a chair, his kettle.
	Kit.furniture(self, "bookcaseOpen", Vector3(-9.5, 0, 7.6), 180)
	Kit.furniture(self, "chair", Vector3(-10.5, 0, 5.2), 30)
	Kit.furniture(self, "sideTable", Vector3(-11.6, 0, 7.4), 90)
	Kit.model(self, Kit.FURNITURE + "kitchenCoffeeMachine.glb", Vector3(-11.75, 0.77, 7.6), 90, Kit.FURNITURE_SCALE)
	Kit.boxed(self, BUCKET, Vector3(-8.7, 0, 6.6), 0.0, 2.5)
	# West hall: a bench and a plant by the side door.
	Kit.furniture(self, "bench", Vector3(-8.5, 0, 2.6), -90)
	Kit.furniture(self, "pottedPlant", Vector3(-11.5, 0, 3.5), 0)
	# Tea room: counters, the fridge, a table.
	for z in [3.0, 3.86, 4.72]:
		Kit.furniture(self, "kitchenCabinet", Vector3(7.5, 0, z), -90)
	Kit.furniture(self, "kitchenFridge", Vector3(7.45, 0, 6.0), -90)
	Kit.model(self, Kit.FURNITURE + "kitchenCoffeeMachine.glb", Vector3(7.7, 0.9, 3.9), -90, Kit.FURNITURE_SCALE)
	Kit.furniture(self, "tableRound", Vector3(5.4, 0, 5.4), 0)
	for c in [[Vector3(4.6, 0, 5.4), 90.0], [Vector3(6.2, 0, 5.4), -90.0]]:
		Kit.furniture(self, "chair", c[0], c[1])
	# Clerk's office: the desk, files, his chair.
	Kit.furniture(self, "desk", Vector3(10.2, 0, -9.4), 0)
	Kit.model(self, Kit.FURNITURE + "computerScreen.glb", Vector3(9.9, 0.77, -9.6), 0, Kit.FURNITURE_SCALE)
	_centered(Kit.FURNITURE + "chairDesk.glb", Vector3(10.2, 0, -8.5), 180.0, Vector3(2, 2, 2), false)
	for z in [-7.5, -6.7]:
		Kit.furniture(self, "bookcaseClosed", Vector3(11.6, 0, z), -90)
	Kit.furniture(self, "pottedPlant", Vector3(8.5, 0, -4.5), 0)
	# Staff hall: pigeonholes.
	Kit.furniture(self, "bookcaseOpen", Vector3(8.4, 0, -2.6), 90)
	# Post room: shelves and parcels.
	Kit.furniture(self, "bookcaseOpen", Vector3(11.6, 0, 5.0), -90)
	Kit.furniture(self, "bookcaseOpen", Vector3(11.6, 0, 6.0), -90)
	Kit.furniture(self, "table", Vector3(9.5, 0, 7.2), 0)
	for b in [Vector3(8.5, 0, 6.0), Vector3(9.2, 0, 6.1), Vector3(8.5, 0.56, 6.0)]:
		Kit.furniture(self, "cardboardBoxClosed", b, randf() * 30.0, b.y == 0.0)
	# Archive: rows of shelves and a reading table.
	for z in [-9.2, -7.6, -6.0, -4.4]:
		Kit.furniture(self, "bookcaseClosedWide", Vector3(8.35, BASE, z), 90)
	for z in [-9.2, -7.6, -6.0]:
		Kit.furniture(self, "bookcaseClosedWide", Vector3(11.65, BASE, z), -90)
	Kit.furniture(self, "table", Vector3(9.8, BASE, 2.8), 0)
	Kit.furniture(self, "chair", Vector3(9.8, BASE, 2.0), 180)
	for b in [Vector3(9.0, BASE, -1.0), Vector3(9.3, BASE, -0.3)]:
		Kit.furniture(self, "cardboardBoxOpen", b, randf() * 40.0)
	# Mayor's office: desk, bookcase, the strongbox on its sideboard.
	Kit.furniture(self, "desk", Vector3(-2.7, UP, 4.6), 90)
	_centered(Kit.FURNITURE + "chairDesk.glb", Vector3(-3.5, UP, 4.6), 90.0, Vector3(2, 2, 2), false)
	Kit.furniture(self, "bookcaseClosedWide", Vector3(-3.7, UP, 6.9), 90)
	_centered(Kit.FURNITURE + "rugRounded.glb", Vector3(-0.8, UP, 5.2), 0.0, Vector3(2, 2, 2), false)
	Kit.furniture(self, "pottedPlant", Vector3(-3.5, UP, 2.5), 0)
	Kit.furniture(self, "loungeChair", Vector3(0.6, UP, 2.7), 200)
	Kit.furniture(self, "sideTableDrawers", Vector3(1.72, UP, 4.4), -90)
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(1.72, UP, 6.9), -90)
	_slab(Vector3(-3.95, UP + 1.6, 3.4), Vector3(0.04, 0.9, 0.7), Color(0.55, 0.42, 0.2))
	_slab(Vector3(-3.92, UP + 1.6, 3.4), Vector3(0.02, 0.75, 0.55), Color(0.4, 0.5, 0.65))
	# Committee room: the long table.
	_centered(Kit.FURNITURE + "table.glb", Vector3(8, UP, 5), 0.0, Vector3(6.0, 2, 2.4), true)
	for x in [5.8, 7.2, 8.6, 10.0]:
		Kit.furniture(self, "chair", Vector3(x, UP, 3.7), 0)
		Kit.furniture(self, "chair", Vector3(x, UP, 6.3), 180)
	Kit.furniture(self, "pottedPlant", Vector3(11.4, UP, 2.6), 0)
	# Members' room: armchairs, a sideboard, the founders' portrait.
	Kit.furniture(self, "loungeSofa", Vector3(-8, UP, 7.4), 180)
	Kit.furniture(self, "loungeChair", Vector3(-10.6, UP, 4.6), 90)
	Kit.furniture(self, "loungeChair", Vector3(-5.4, UP, 4.6), -90)
	Kit.furniture(self, "tableCoffee", Vector3(-8, UP, 5.2), 0)
	Kit.furniture(self, "bookcaseClosedWide", Vector3(-11.6, UP, 2.8), 90)
	_slab(Vector3(-8, UP + 1.6, 2.06), Vector3(1.4, 1.0, 0.04), Color(0.55, 0.42, 0.2))
	_slab(Vector3(-8, UP + 1.6, 2.09), Vector3(1.2, 0.8, 0.02), Color(0.35, 0.45, 0.35))
	# Upstairs corridor: benches and plants.
	Kit.furniture(self, "pottedPlant", Vector3(-11.5, UP, 1.4), 0)
	Kit.furniture(self, "pottedPlant", Vector3(11.5, UP, 1.5), 0)
	# Back stair landing: old chairs stacked up.
	Kit.furniture(self, "chair", Vector3(-11.5, UP, -9.4), 20)
	Kit.furniture(self, "cardboardBoxClosed", Vector3(-11.4, UP, -8.4), 10)
	# Portico: columns either side of the front doors, and a pediment.
	for x in [-4.6, 2.6]:
		Kit.block(self, Vector3(x, 1.25, 8.5), Vector3(0.5, 2.5, 0.5), "", Kit.flat(STONE))
	_label("TOWN HALL", Vector3(-1, ROOF - 0.3, 8.08), 0.0, 96, Color(0.95, 0.9, 0.75))


func _lamps() -> void:
	lamp("lobby", Vector3(0, UP, 2.5), true, 1.2, 6.0)
	lamp("lobby", Vector3(-1.5, UP, 6), true, 1.0, 5.0)
	lamp("landing", Vector3(3, ROOF, 5), true, 0.8, 5.0)
	lamp("cloakroom", Vector3(-6, UP, 5), true, 0.9, 5.0)
	lamp("passage_w", Vector3(-6, UP, 1), true, 0.7, 4.0)
	lamp("west_hall", Vector3(-10, UP, 1), true, 0.7, 5.0)
	lamp("west_hall", Vector3(-9.3, UP, -8), true, 0.6, 4.5)
	lamp("cupboard", Vector3(-10, UP, 6), false, 0.9, 4.0, Color(0.9, 0.95, 1.0))
	lamp("chamber_front", Vector3(-3, ROOF, -8.6), true, 1.4, 7.0)
	lamp("chamber_front", Vector3(3, ROOF, -8.6), true, 1.4, 7.0)
	lamp("chamber", Vector3(-4, ROOF, -5.5), true, 1.0, 6.0)
	lamp("chamber", Vector3(4, ROOF, -5.5), true, 1.0, 6.0)
	lamp("chamber_back", Vector3(-4, ROOF, -1.5), false, 1.0, 6.0)
	lamp("chamber_back", Vector3(4, ROOF, -1.5), false, 1.0, 6.0)
	lamp("passage_e", Vector3(6, UP, 1), false, 0.7, 4.0)
	lamp("tea_room", Vector3(6, UP, 5), true, 0.9, 5.0)
	lamp("staff_hall", Vector3(9.4, UP, 1), true, 0.8, 5.0)
	lamp("clerk_office", Vector3(10, UP, -7), true, 1.0, 5.0)
	lamp("post_room", Vector3(10, UP, 6), false, 0.9, 4.5)
	lamp("archive", Vector3(10, 0, -7), false, 0.9, 5.0)
	lamp("archive", Vector3(10, 0, 1), false, 0.7, 4.0)
	lamp("corridor", Vector3(-8, ROOF, 1), true, 0.7, 5.0)
	lamp("corridor", Vector3(7, ROOF, 1), true, 0.7, 5.0)
	lamp("mayor_office", Vector3(-1, ROOF, 5), false, 1.0, 5.5)
	lamp("committee", Vector3(8, ROOF, 5), false, 1.0, 6.0)
	lamp("members", Vector3(-8, ROOF, 5), false, 1.0, 6.0)
	lamp("stair_up", Vector3(-10, ROOF, -8), false, 0.8, 5.0)
	lamp("roof_house", Vector3(-10, TOWER_TOP, -8), false, 0.8, 4.0)
	# The portico lamp over the front doors, and the balcony lamp.
	_wall_lamp("portico", Vector3(-1, 2.3, 8.15), 0.0, true, 1.2, 6.0)
	_wall_lamp("balcony", Vector3(-1, UP + 2.2, 8.15), 0.0, false, 0.8, 4.0)
	# Street lamps on the square, in the car park and the yard.
	_street_lamp("square", Vector3(-9, 0, 13.2))
	_street_lamp("square", Vector3(8, 0, 13.2))
	_street_lamp("car_park", Vector3(-17, 0, -10))
	_street_lamp("yard", Vector3(15, 0, -6))
	# Switches, just inside the doors.
	light_switch(["lobby"], Vector3(-2.2, 1.3, 7.92), Vector3(0, 0, -1))
	light_switch(["portico"], Vector3(2.2, 1.3, 7.92), Vector3(0, 0, -1))
	light_switch(["cloakroom"], Vector3(-4.1, 1.3, 3.8), Vector3(-1, 0, 0))
	light_switch(["passage_w", "west_hall"], Vector3(-8.1, 1.3, 2.3), Vector3(-1, 0, 0))
	light_switch(["cupboard"], Vector3(-8.2, 1.3, 4.1), Vector3(0, 0, 1))
	light_switch(["chamber_back"], Vector3(-4.2, 1.3, -0.1), Vector3(0, 0, -1))
	light_switch(["chamber", "chamber_front"], Vector3(4.2, 1.3, -0.1), Vector3(0, 0, -1))
	light_switch(["passage_e"], Vector3(4.1, 1.3, 1.7), Vector3(1, 0, 0))
	light_switch(["tea_room"], Vector3(6.2, 1.3, 2.1), Vector3(0, 0, 1))
	light_switch(["staff_hall"], Vector3(8.1, 1.3, 2.3), Vector3(1, 0, 0))
	light_switch(["clerk_office"], Vector3(10.4, 1.3, -4.1), Vector3(0, 0, -1))
	light_switch(["post_room"], Vector3(10.3, 1.3, 4.1), Vector3(0, 0, 1))
	light_switch(["archive"], Vector3(8.1, BASE + 1.3, -3.0), Vector3(1, 0, 0))
	light_switch(["corridor", "landing"], Vector3(3.5, UP + 1.3, 0.1), Vector3(0, 0, 1))
	light_switch(["mayor_office"], Vector3(0.2, UP + 1.3, 2.1), Vector3(0, 0, 1))
	light_switch(["committee"], Vector3(6.2, UP + 1.3, 2.1), Vector3(0, 0, 1))
	light_switch(["members"], Vector3(-6.2, UP + 1.3, 2.1), Vector3(0, 0, 1))
	light_switch(["stair_up"], Vector3(-8.1, UP + 1.3, -0.8), Vector3(-1, 0, 0))
	light_switch(["roof_house"], Vector3(-8.1, ROOF + 1.3, -7.4), Vector3(-1, 0, 0))
	light_switch(["balcony"], Vector3(0.3, UP + 1.3, 7.92), Vector3(0, 0, -1))


func _things() -> void:
	# The crowd's murmur, from the middle of the benches.
	var hum := Node3D.new()
	hum.name = "CrowdMurmur"
	hum.position = Vector3(0, 1.4, -4.5)
	add_child(hum)
	var murmur := Sfx.on(hum, "crowd_murmur_loop", -4.0)
	murmur.max_distance = 24.0
	# Reading matter.
	note("staff_notice", "A notice on the noticeboard", STAFF_NOTICE, Vector3(-3.91, 1.75, 6.55), 90)
	note("agenda", "Tonight's agenda", AGENDA, Vector3(-3.91, 1.45, 7.35), 90)
	note("sticky_note", "A sticky note on Dobbs's screen", STICKY_NOTE, Vector3(10.55, 1.2, -9.58), 0, Vector3(0.1, 0.1, 0.01))
	_slab(Vector3(9.2, BASE + 1.7, -9.93), Vector3(0.7, 0.55, 0.04), Color(0.45, 0.32, 0.18))
	note("green_photo", "A framed photograph", GREEN_PHOTO, Vector3(9.2, BASE + 1.7, -9.9), 0, Vector3(0.56, 0.42, 0.01))
	note("minutes_1846", "The minutes, 1846", MINUTES_1846, Vector3(9.8, BASE + 0.67, 2.8), 0, Vector3(0.3, 0.04, 0.22))
	note("mayor_diary", "The mayor's diary", MAYOR_DIARY, Vector3(7.0, UP + 0.68, 5.0), 20, Vector3(0.22, 0.04, 0.3))
	note("hoard_letter", "A letter in the post tray", HOARD_LETTER, Vector3(9.5, 0.68, 7.2), 10, Vector3(0.22, 0.02, 0.3))
	note("caretaker_note", "A note taped to the bins", CARETAKER_NOTE, Vector3(9.6, 1.11, -10.6), 0, Vector3(0.22, 0.02, 0.3))
	note("bell_rules", "A card by the bell rope", BELL_RULES, Vector3(-11.92, ROOF + 1.5, -8.6), 90)
	# The cloakroom: a coat to borrow, the mayor's red coat, Hoard's fur.
	var coats := UsableBody.new()
	coats.name = "CoatRail"
	coats.position = Vector3(-7.3, 1.1, 4.0)
	coats.add_box(Vector3.ZERO, Vector3(0.5, 1.0, 1.6))
	coats.collision_layer = Kit.LAYER_INTERACT
	coats.add_action("interact", "Borrow a coat", _borrow_coat)
	add_child(coats)
	mayor_coat = UsableBody.new()
	mayor_coat.name = "MayorCoat"
	mayor_coat.position = Vector3(-7.35, 0.9, 6.2)
	mayor_coat.add_child(_coat_mesh(Color(0.75, 0.12, 0.12)))
	mayor_coat.add_box(Vector3(0, 0.45, 0), Vector3(0.4, 0.9, 0.5))
	mayor_coat.collision_layer = Kit.LAYER_INTERACT
	mayor_coat.add_action("interact", "Search the red coat", _search_mayor_coat)
	add_child(mayor_coat)
	var fur := UsableBody.new()
	fur.name = "HoardCoat"
	fur.position = Vector3(-5.4, 0.9, 7.55)
	fur.add_child(_coat_mesh(Color(0.4, 0.3, 0.2)))
	fur.add_box(Vector3(0, 0.45, 0), Vector3(0.5, 0.9, 0.4))
	fur.collision_layer = Kit.LAYER_INTERACT
	fur.add_action("interact", "Search the fur coat", _read.bind("hoard_pocket", "Hoard's coat pocket", HOARD_POCKET))
	add_child(fur)
	Kit.block(self, Vector3(-5.4, 0.95, 7.85), Vector3(0.9, 0.05, 0.05), "", Kit.flat(BRASS), false)
	# The spare clerk's lanyard and folder, in the drawer behind reception.
	var lanyard := UsableBody.new()
	lanyard.name = "Lanyard"
	lanyard.position = Vector3(-0.8, 0.8, 0.35)
	var folder := MeshInstance3D.new()
	var fm := BoxMesh.new()
	fm.size = Vector3(0.24, 0.03, 0.32)
	fm.material = Kit.flat(Color(0.2, 0.35, 0.6))
	folder.mesh = fm
	folder.position = Vector3(0, 0.02, 0)
	lanyard.add_child(folder)
	var card := MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(0.07, 0.01, 0.1)
	cm.material = Kit.flat(Color(0.95, 0.95, 0.9))
	card.mesh = cm
	card.position = Vector3(0.18, 0.01, 0.05)
	lanyard.add_child(card)
	lanyard.add_box(Vector3(0, 0.05, 0), Vector3(0.5, 0.15, 0.4))
	lanyard.collision_layer = Kit.LAYER_INTERACT
	lanyard.add_action("interact", "Put on the spare lanyard", _wear_lanyard)
	add_child(lanyard)
	# Placards left by the front doors.
	for p in [[Vector3(-3.3, 0, 7.6), "SAVE OUR GREEN", 10.0], [Vector3(-2.8, 0, 7.7), "HANDS OFF", -8.0]]:
		_placard_model(self, p[0], p[2], p[1])
	var sign := UsableBody.new()
	sign.name = "VoteNoSign"
	sign.position = Vector3(-2.4, 0, 7.6)
	_placard_model(sign, Vector3.ZERO, 4.0, "VOTE NO")
	sign.add_box(Vector3(0, 0.9, 0), Vector3(0.6, 1.0, 0.2))
	sign.collision_layer = Kit.LAYER_INTERACT
	sign.add_action("interact", "Take a \"Vote no\" sign", _take.bind("vote_no_sign", "", sign))
	add_child(sign)
	# The recipe on the tea room fridge.
	var recipe := note("recipe_card", "A recipe on the fridge", RECIPE, Vector3(7.13, 1.4, 6.0), -90)
	_prompt(recipe, "interact", "Take the recipe")
	recipe.action("interact").on_use = _take_recipe.bind(recipe)
	Kit.model(self, Kit.FOOD + "cake.glb", Vector3(5.4, 0.76, 5.4), 0.0, 0.8)
	# Stanley's mop.
	var mop := UsableBody.new()
	mop.name = "Mop"
	mop.position = Vector3(-8.75, 0, 7.4)
	mop.add_child(_mop_mesh())
	mop.add_box(Vector3(0, 0.7, 0), Vector3(0.3, 1.4, 0.3))
	mop.collision_layer = Kit.LAYER_INTERACT
	mop.add_action("interact", "Take the mop", _take.bind("mop", "", mop))
	add_child(mop)
	# Somewhere to put things down: the mayor's desk, a spot by the dais.
	sign_spot = UsableBody.new()
	sign_spot.name = "SignSpot"
	sign_spot.position = Vector3(-2.7, UP + 0.85, 4.6)
	sign_spot.add_box(Vector3.ZERO, Vector3(0.7, 0.2, 1.3))
	sign_spot.collision_layer = Kit.LAYER_INTERACT
	sign_spot.add_action("interact", "", _leave_sign)
	add_child(sign_spot)
	mop_spot = UsableBody.new()
	mop_spot.name = "MopSpot"
	mop_spot.position = Vector3(7.2, 0, -9.4)
	mop_spot.add_box(Vector3(0, 0.6, 0), Vector3(0.6, 1.2, 0.6))
	mop_spot.collision_layer = Kit.LAYER_INTERACT
	mop_spot.add_action("interact", "", _leave_mop)
	add_child(mop_spot)
	# The lectern, with Hoard's speech on it.
	lectern = UsableBody.new()
	lectern.name = "Lectern"
	lectern.position = Vector3(3.4, 1.36, -8.0)
	var speech := MeshInstance3D.new()
	var sm := BoxMesh.new()
	sm.size = Vector3(0.3, 0.02, 0.22)
	sm.material = Kit.flat(Color(0.97, 0.95, 0.85))
	speech.mesh = sm
	lectern.add_child(speech)
	lectern.add_box(Vector3(0, 0.05, 0), Vector3(0.8, 0.12, 0.6))
	lectern.collision_layer = Kit.LAYER_INTERACT
	lectern.add_action("interact", "Read Hoard's speech", _read_speech)
	lectern.add_action("interact2", "", _swap_speech)
	add_child(lectern)
	# The bell rope in the roof house.
	rope = UsableBody.new()
	rope.name = "BellRope"
	rope.position = Vector3(-10, ROOF, -8.6)
	var cord := MeshInstance3D.new()
	var rm := CylinderMesh.new()
	rm.top_radius = 0.025
	rm.bottom_radius = 0.025
	rm.height = 2.5
	rm.material = Kit.flat(Color(0.75, 0.65, 0.45))
	cord.mesh = rm
	cord.position = Vector3(0, 1.25 + 0.6, 0)
	rope.add_child(cord)
	var grip := MeshInstance3D.new()
	var gm := CylinderMesh.new()
	gm.top_radius = 0.05
	gm.bottom_radius = 0.05
	gm.height = 0.4
	gm.material = Kit.flat(Color(0.7, 0.15, 0.15))
	grip.mesh = gm
	grip.position = Vector3(0, 1.0, 0)
	rope.add_child(grip)
	rope.add_box(Vector3(0, 1.4, 0), Vector3(0.3, 1.4, 0.3))
	rope.collision_layer = Kit.LAYER_INTERACT
	rope.add_action("interact", "Pull the bell rope", _ring_bell)
	add_child(rope)
	# The strongbox, its dial, and the charter inside.
	_chest = Kit.model(self, CHEST, Vector3(1.7, UP + 0.77, 4.4), -90, 2.0)
	_stand_home = Vector3(1.7, UP + 0.77, 4.4)
	treasure("charter", "Take the charter", CHARTER, _stand_home, 1.0, -90.0, Vector3(0.6, 0.55, 0.6))
	_treasure_model.position = Vector3(0, 0.2, 0)
	treasure_stand.action("interact").on_use = _use_strongbox
	_prompt(treasure_stand, "interact", "Open the strongbox")
	strongbox_pad = keypad("strongbox", CODE, Vector3(1.47, UP + 0.5, 4.75), -90)
	strongbox_pad.on_open = _open_box.bind("code")
	_prompt(strongbox_pad, "interact", "Turn the dial")
	# Hiding places.
	hide_spot("mayor_wardrobe", "Hide in the wardrobe", Vector3(1.72, UP, 6.9), -90, Vector3(0, 1.4, 0), Vector3(0.86, 1.85, 0.62))
	hide_spot("coats", "Hide among the coats", Vector3(-6, 0, 2.5), 0, Vector3(0, 1.3, 0), Vector3(1.6, 1.8, 0.6))
	Kit.furniture(self, "coatRackStanding", Vector3(-6.6, 0, 2.4), 0)
	Kit.furniture(self, "coatRackStanding", Vector3(-5.4, 0, 2.4), 0)
	_coat(Vector3(-6.4, 0.9, 2.45), Color(0.35, 0.3, 0.5))
	_coat(Vector3(-5.6, 0.9, 2.45), Color(0.5, 0.45, 0.3))
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(11.6, 0, 7.4), -90)
	hide_spot("post_cupboard", "Hide in the stationery cupboard", Vector3(11.6, 0, 7.4), -90, Vector3(0, 1.4, 0), Vector3(0.86, 1.85, 0.62))
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(11.65, BASE, -4.3), -90)
	hide_spot("archive_cupboard", "Hide in the archive cupboard", Vector3(11.65, BASE, -4.3), -90, Vector3(0, 1.4, 0), Vector3(0.86, 1.85, 0.62))
	# The fuse box in Stanley's cupboard.
	fuse_box(Vector3(-11.92, 1.2, 6.2), 90)
	# The real staff relock what they unlock.
	for id in ["side_door", "goods_door", "staff_door", "cupboard_door", "mayor_door"]:
		doors[id].closed.connect(_relock.bind(doors[id]))


func _marks() -> void:
	add_start("front", Vector3(-1, 0, 13), 0)
	add_start("car_park", Vector3(-19, 0, -6), -90)
	add_start("roof", Vector3(-6.5, ROOF, -8.6), 160)
	points = {
		# The dais and the chamber.
		"mayor_chair": Vector3(-0.6, 0.2, -9.3), "hoard_chair": Vector3(-3.3, 0.2, -9.3),
		"dais_front": Vector3(-0.6, 0.2, -7.75), "lectern": Vector3(3.4, 0.2, -8.75),
		"lectern_side": Vector3(2.4, 0.2, -8.0), "minutes_desk": Vector3(5.8, 0.2, -8.6),
		"chamber_back": Vector3(0, 0, -1.0),
		# The ground floor.
		"lobby": Vector3(0, 0, 5), "lobby_mid": Vector3(-1.2, 0, 3.4), "reception": Vector3(0, 0, 1.0),
		"cloak_mayor": Vector3(-6.6, 0, 6.2), "cloakroom": Vector3(-6, 0, 4.5),
		"west_hall": Vector3(-10, 0, 1), "cupboard": Vector3(-10, 0, 6.4), "fuse_box": Vector3(-11.2, 0, 6.2),
		"car_park": Vector3(-16, 0, 1), "staff_hall": Vector3(9.2, 0, -1),
		"clerk_desk": Vector3(10.2, 0, -8.6), "tea_room": Vector3(5.6, 0, 3.6),
		"archive_shelf": Vector3(9.9, BASE, -7.4),
		# Upstairs and up top.
		"corridor_w": Vector3(-7, UP, 1), "corridor_e": Vector3(10, UP, 1), "landing": Vector3(3, UP, 1.6),
		"mayor_box": Vector3(0.8, UP, 4.4), "back_landing": Vector3(-10, UP, -8),
		"roof_house": Vector3(-10.6, ROOF, -8.4),
	}
	# Where each of the seated sit: the benches and the council table.
	for z in [-6.2, -4.6, -3.0]:
		for side in [-1.0, 1.0]:
			for i in 4:
				points["seat_%d_%d_%d" % [roundi(-z * 10), int(side), i]] = Vector3(side * 3.8 - 1.95 + i * 1.3, 0, z)
	points["cllr_moss"] = Vector3(-2.0, 0.2, -9.3)
	points["cllr_bramble"] = Vector3(0.8, 0.2, -9.3)


# --- People ---------------------------------------------------------------------------

func voice_info() -> Dictionary:
	return {
		"town_hall_mayor": {"who": "Mayor Prudence Pell: a brisk, decent, slightly frazzled woman in her fifties, chairing a rowdy meeting", "kokoro": "bf_isabella", "speed": 1.0},
		"town_hall_clerk": {"who": "Dennis Dobbs, clerk to the council: a fussy, forgetful, very proper young man", "kokoro": "bm_daniel", "speed": 1.05},
		"town_hall_caretaker": {"who": "Stanley, the town hall caretaker: a slow, gruff, kindly old man who has seen it all", "kokoro": "am_adam", "speed": 0.95},
		"hoard": {"who": "Augustus Hoard: a pompous, oily rich man in his sixties, pleased with himself", "kokoro": "am_onyx", "speed": 0.95},
		"town_hall_townsfolk": {"who": "The townsfolk in the council chamber: they only mumble, with no recorded lines", "kokoro": "", "speed": 1.0},
	}


func add_people(p_run: JobRun) -> Array:
	var out := []
	mayor = TownHallPerson.new()
	mayor.setup("Mayor Pell", "female-c", self, p_run, _mayor_meeting(), "town_hall_mayor", {
		"mumble": "high", "accepts": ["townsfolk", "clerk"], "answers_alarm": true, "sight": 13.0,
		"lines": {
			"curious": ["Hm? Who's that?", "Is somebody there?"],
			"seen": ["Excuse me? Can I help you?"],
			"spotted": ["You! Stop right there!", "Stop! Thief!"],
			"others": ["What's all the fuss?"],
			"lost": ["Where did they go?"],
			"give_up": ["Back to the meeting, then.", "I'm seeing burglars everywhere tonight."],
			"catch": ["Got you. Out you go, and don't come back."],
			"alarm": ["What on earth is that?"],
			"wake": ["Goodness. Did I nod off?"],
			"bark": [],
		},
		"extra_lines": [
			"Ten o'clock. I'll fetch the charter for the vote.",
			"Now then. The charter.",
			"Here it is: the town charter. Let's vote.",
			"The charter! It's gone! Somebody's taken the charter!",
			"The vote's off, everyone. Somebody's pinched the charter.",
			"One minute to the vote, everyone.",
			"Nobody panic! Stanley, the fuses!",
			"Who's ringing the bell? Stanley, go and look!",
			"Vote no? Hm. Maybe I will.",
			"Is that a mop? In my chamber?",
			"Point of order! Can we please just vote?",
		],
	})
	mayor.position = points["mayor_chair"]
	add_child(mayor)
	mayor.step_arrived.connect(_on_step_arrived)
	mayor.step_done.connect(_on_step_done)
	mayor.dozed.connect(_on_mayor_dozed)
	out.append(mayor)
	clerk = TownHallPerson.new()
	clerk.setup("Dobbs", "male-b", self, p_run, [
		{"at": "minutes_desk", "face": W, "time": 40.0, "say": "Minute forty-three: Mr Hoard is still talking."},
		{"at": "clerk_desk", "face": N, "time": 22.0, "room": "clerk_office", "say": "Now, where did I put the stapler?"},
		{"at": "archive_shelf", "face": W, "time": 18.0, "room": "archive", "leave_dark": true, "say": "Minutes from 1846... they're in here somewhere."},
		{"at": "staff_hall", "time": 2.0},
		{"at": "reception", "face": S, "time": 10.0, "say": "Who keeps borrowing the spare lanyard?"},
	], "town_hall_clerk", {
		"mumble": "low", "accepts": ["townsfolk"], "answers_alarm": true,
		"lines": {
			"curious": ["Hello?", "Is that you, Stanley?"],
			"seen": ["Sorry, are you meant to be back here?", "Hang on. I'm the only clerk here."],
			"spotted": ["Oi! That's council property!", "Stop! Burglar!"],
			"others": ["What's going on?"],
			"lost": ["Where did they go? I'll make a note."],
			"give_up": ["Must have been a draught.", "I'll put it in the minutes."],
			"catch": ["Right. Out. And I'm writing this down."],
			"alarm": ["The charter! Somebody check the charter!"],
			"wake": ["Wha...? I was resting my eyes."],
			"bark": [],
		},
	})
	clerk.position = points["minutes_desk"]
	add_child(clerk)
	out.append(clerk)
	caretaker = TownHallPerson.new()
	caretaker.setup("Stanley", "male-e", self, p_run, [
		{"at": "cupboard", "face": W, "time": 15.0, "room": "cupboard", "say": "Right. Rounds."},
		{"at": "west_hall", "time": 1.0},
		{"at": "car_park", "face": W, "time": 8.0, "say": "Who parks like that? Oh. Mr Hoard."},
		{"at": "west_hall", "time": 1.0},
		{"at": "roof_house", "face": N, "time": 8.0, "room": "roof_house", "leave_dark": true, "say": "Nobody's touched the bell rope. Good."},
		{"at": "corridor_w", "time": 2.0},
		{"at": "corridor_e", "face": E, "time": 5.0},
		{"at": "landing", "time": 2.0},
		{"at": "lobby", "face": S, "time": 6.0, "say": "Mind the floor, it's just been mopped."},
		{"at": "cloakroom", "time": 5.0, "say": "Somebody's left the lights on again."},
		{"at": "chamber_back", "face": N, "time": 14.0},
	], "town_hall_caretaker", {
		"mumble": "low", "accepts": ["townsfolk", "clerk"], "fixes_power": true, "answers_alarm": true, "torch": true,
		"lines": {
			"curious": ["Who's that?", "Hello? Somebody there?"],
			"seen": ["Oi. Who's that skulking about?"],
			"spotted": ["Got a burglar! Stop!", "Oi! You!"],
			"others": ["What's all the shouting?"],
			"lost": ["Slippery one."],
			"give_up": ["Pigeons again.", "Just the pipes."],
			"catch": ["Gotcha. Out the front, sunshine."],
			"power_out": ["Not the fuses again!"],
			"power_fixed": ["There. Let there be light."],
			"alarm": ["What's all that racket?"],
			"wake": ["Eh? Must've dropped off."],
			"bark": [],
		},
		"extra_lines": ["Who's that at my bell?", "Where's my mop got to?"],
	})
	caretaker.position = points["cupboard"]
	add_child(caretaker)
	caretaker.step_arrived.connect(_on_step_arrived)
	out.append(caretaker)
	hoard = TownHallPerson.new()
	hoard.setup("Hoard", "male-d", self, p_run, [
		{"at": "hoard_chair", "face": S, "clip": "sit", "time": 25.0, "sit": SIT_TABLE, "say": "Do get on with it, Prudence."},
		{"at": "lectern", "face": S, "time": 14.0, "say": SPEECH_LINES[0], "speech": 0},
		{"at": "hoard_chair", "face": S, "clip": "sit", "time": 35.0, "sit": SIT_TABLE},
		{"at": "lectern", "face": S, "time": 14.0, "say": SPEECH_LINES[1], "speech": 1},
		{"at": "hoard_chair", "face": S, "clip": "sit", "time": 30.0, "sit": SIT_TABLE},
		{"at": "lectern", "face": S, "time": 14.0, "say": SPEECH_LINES[2], "speech": 2},
	], "hoard", {
		"mumble": "low", "accepts": ["townsfolk", "clerk"], "sight": 11.0,
		"lines": {
			"curious": ["Hm? Who's skulking there?"],
			"seen": ["You there! Do I know you?"],
			"spotted": ["A thief! Somebody grab them!"],
			"others": ["What's all this?"],
			"lost": ["Slippery little..."],
			"give_up": ["Nobody. Excellent. Where was I?"],
			"catch": ["Got you! Out, out!"],
			"wake": ["Who dares... oh. I dozed."],
			"bark": [],
		},
		"extra_lines": RECIPE_LINES + [
			"At last. Let's get this over with.",
			"Is this a joke? Who turned out the lights?",
			"A bell? At this hour?",
		],
	})
	hoard.position = points["hoard_chair"]
	add_child(hoard)
	out.append(hoard)
	# The council's two other members, at the table, and the townsfolk.
	var who := [
		["Cllr Moss", "female-a", "cllr_moss", S], ["Cllr Bramble", "male-c", "cllr_bramble", S],
		["Mrs Dunn", "female-b", "seat_62_-1_0", N], ["Old Bert", "male-a", "seat_62_-1_2", N],
		["Priya", "female-d", "seat_62_-1_3", N], ["Mr Okafor", "male-f", "seat_62_1_1", N],
		["Gwen", "female-e", "seat_62_1_2", N], ["Mr Fenwick", "male-a", "seat_46_-1_0", N],
		["Nell", "female-f", "seat_46_-1_1", N], ["Mr Pike", "male-c", "seat_46_-1_3", N],
		["Ada", "female-b", "seat_46_1_1", N], ["Tom", "male-f", "seat_46_1_2", N],
		["Mrs Lark", "female-d", "seat_30_-1_1", N], ["Mr Saxby", "male-a", "seat_30_1_2", N],
	]
	for i in who.size():
		var w: Array = who[i]
		var at: String = w[2]
		var at_table := at.begins_with("cllr")
		var face: Vector3 = w[3]
		var turn := Vector3(1 if i % 2 == 0 else -1, 0, face.z * 0.6).normalized()
		var sit: Vector3 = SIT_TABLE if at_table else SIT_BENCH
		var t := TownHallCrowd.new()
		t.setup(w[0], w[1], self, p_run, [
			{"at": at, "face": face, "clip": "sit-watch" if i % 3 != 1 else "sit", "time": 16.0 + float((i * 7) % 23), "sit": sit},
			{"at": at, "face": turn, "clip": "sit", "time": 5.0, "sit": sit, "say": CROWD_CHAT[i % CROWD_CHAT.size()]},
		], "town_hall_townsfolk", {
			"mumble": "high" if w[1].begins_with("female") else "low", "accepts": ["townsfolk", "clerk"], "sight": 8.0,
			"lines": {
				"curious": ["Hm?", "What was that?"],
				"seen": ["Who's that?"],
				"spotted": ["There's somebody sneaking about!", "Mayor! Someone's up to no good!"],
				"wake": ["Is it over?"],
				"bark": [],
			},
		})
		t.position = points[at]
		add_child(t)
		crowd.append(t)
		out.append(t)
	return out


func _mayor_meeting() -> Array:
	return [
		{"at": "mayor_chair", "face": S, "clip": "sit", "time": 50.0, "sit": SIT_TABLE, "say": "Order, order! Let's hear Mr Hoard out."},
		{"at": "dais_front", "face": S, "time": 10.0, "say": "The vote is at ten o'clock. I'll fetch the charter myself."},
		{"at": "mayor_chair", "face": S, "clip": "sit", "time": 45.0, "sit": SIT_TABLE, "say": "Dobbs, remind me. My strongbox key's in my red coat, isn't it?", "overhear": "mayor_key"},
		{"at": "cloak_mayor", "face": W, "time": 7.0, "room": "cloakroom", "say": "Glasses, glasses... and there's my key, still in the pocket.", "overhear": "mayor_key"},
		{"at": "lobby_mid", "time": 2.0},
		{"at": "mayor_chair", "face": S, "clip": "sit", "time": 40.0, "sit": SIT_TABLE, "say": "Mrs Dunn, please sit down."},
	]


## Her trip for the vote: up to her office, the strongbox, and down to the
## lectern.
func _mayor_fetch() -> Array:
	return [
		{"at": "dais_front", "face": S, "time": 4.0, "say": "Ten o'clock. I'll fetch the charter for the vote."},
		{"at": "mayor_box", "face": E, "time": 6.0, "room": "mayor_office", "say": "Now then. The charter.", "do": "open_box"},
		{"at": "lectern_side", "face": S, "time": 6.0, "do": "place_charter"},
	]


func _mayor_after() -> Array:
	return [
		{"at": "mayor_chair", "face": S, "clip": "sit", "time": 60.0, "sit": SIT_TABLE},
		{"at": "dais_front", "face": S, "time": 8.0, "say": "Point of order! Can we please just vote?"},
	]


## Ten o'clock: the mayor sets off for the charter.
func call_vote() -> void:
	if vote_called or mayor == null:
		return
	vote_called = true
	_record("vote_called")
	_toast("The mayor has gone to fetch the charter!")
	mayor.switch_routine(_mayor_fetch())


func _physics_process(delta: float) -> void:
	super(delta)
	if _player == null:
		_player = get_tree().get_first_node_in_group("moth") as Moth
		if _player:
			_player.bag_changed.connect(_update_spots)
			_update_spots()
	_bell_t -= delta
	var run := JobRun.current
	if run == null or not run.running or mayor == null:
		return
	if not _warned and run.time >= WARN_TIME:
		_warned = true
		if not mayor.is_asleep():
			mayor.say("One minute to the vote, everyone.")
		_toast("One minute to the vote.")
	if not vote_called and run.time >= VOTE_TIME:
		call_vote()


func _on_step_arrived(person: TownHallPerson, step: Dictionary) -> void:
	if person == caretaker:
		if step.get("at", "") == "cupboard" and not has_node("Mop") and not has_meta("mop_missed"):
			set_meta("mop_missed", true)
			caretaker.say("Where's my mop got to?")
		return
	if person != mayor:
		return
	match step.get("do", ""):
		"open_box":
			if sign_left:
				mayor.say("Vote no? Hm. Maybe I will.")
			if not box_open:
				_open_box("mayor")
		"place_charter":
			if charter_at == "mayor":
				_place_on_lectern()
				mayor.say("Here it is: the town charter. Let's vote.")
				_record("vote_started")
				if not hoard.is_asleep():
					hoard.say("At last. Let's get this over with.")
			else:
				mayor.say("The vote's off, everyone. Somebody's pinched the charter.")
				_record("vote_off")
	if step.get("at", "") == "mayor_chair" and mop_left and not has_meta("mop_seen"):
		set_meta("mop_seen", true)
		mayor.say("Is that a mop? In my chamber?")


func _on_step_done(person: TownHallPerson, step: Dictionary) -> void:
	if person != mayor:
		return
	match step.get("do", ""):
		"open_box":
			if charter_at == "box" and _treasure_model != null:
				_mayor_takes_charter()
			else:
				mayor.say("The charter! It's gone! Somebody's taken the charter!")
				_record("charter_gone")
				raise_alarm(_stand_home, "charter_gone")
		"place_charter":
			mayor.switch_routine(_mayor_after())


func _mayor_takes_charter() -> void:
	charter_at = "mayor"
	_treasure_model.queue_free()
	_treasure_model = null
	treasure_stand.set_action_text("interact", "")
	_carried = Kit.scene(CHARTER).instantiate()
	_carried.position = Vector3(0.28, 0.95, 0.2)
	mayor.rig.add_child(_carried)


## Snoozed with the charter in her arms: it falls at her feet.
func _on_mayor_dozed(_p: TownHallPerson) -> void:
	if charter_at != "mayor":
		return
	if is_instance_valid(_carried):
		_carried.queue_free()
	_carried = null
	var at := mayor.global_position + mayor._facing() * 0.6
	_move_stand(at, "floor")
	_record("charter_dropped")


func _place_on_lectern() -> void:
	if is_instance_valid(_carried):
		_carried.queue_free()
	_carried = null
	_move_stand(Vector3(3.4, 1.42, -8.0), "lectern")


func _move_stand(at: Vector3, place: String) -> void:
	charter_at = place
	_stand_place = place
	treasure_stand.global_position = at
	if _treasure_model == null:
		_place_treasure_model()
	_treasure_model.position = Vector3.ZERO
	treasure_stand.set_action_text("interact", "Take the charter")


# --- The strongbox and the charter --------------------------------------------------

func _use_strongbox(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if charter_at != "box" and _stand_place != "box":
		_take_charter(pic)
		return
	if not box_open:
		if player.has_item("mayor_key"):
			_record("used_key")
			_open_box("key")
			UsableBody.hint(pic, "The mayor's key turns. Click.")
		else:
			Sfx.at(self, "kenney:beltHandle2", treasure_stand.global_position, -8.0)
			StealthNoise.make(self, treasure_stand.global_position, 2.0, "rattle", player)
			UsableBody.hint(pic, "Locked. A four-number dial, and a keyhole.")
		return
	_take_charter(pic)


func _take_charter(pic: PlayerInteractionComponent) -> void:
	if _treasure_model == null:
		UsableBody.hint(pic, "Empty.")
		return
	_take_treasure(pic)
	charter_at = "player"


## Opens the strongbox: by its dial ("code"), the mayor's key ("key"), or
## the mayor herself ("mayor").
func _open_box(how: String) -> void:
	if box_open:
		return
	box_open = true
	var anim := _chest.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if anim and anim.has_animation("open"):
		anim.play("open")
	Sfx.at(self, "safe_open", _stand_home, -6.0)
	_record("strongbox_opened")
	if how == "mayor":
		if _treasure_model != null:
			_record("strongbox_opened_by_mayor")
	elif how == "key":
		_record("unlocked:strongbox")
	if not strongbox_pad.solved:
		strongbox_pad.solved = true
		strongbox_pad.set_action_text("interact", "")
	if _stand_place == "box":
		treasure_stand.set_action_text("interact", "Take the charter" if _treasure_model != null else "")


## Caught with the charter: it goes back where it was taken from.
func return_treasure() -> void:
	if _treasure_model != null:
		return
	_place_treasure_model()
	charter_at = _stand_place
	if _stand_place == "box":
		_treasure_model.position = Vector3(0, 0.2, 0)
		treasure_stand.set_action_text("interact", "Take the charter" if box_open else "Open the strongbox")
	else:
		treasure_stand.set_action_text("interact", "Take the charter")


## The mayor knows her own charter, whatever you're wearing.
func expects(person: Person, p: Moth) -> bool:
	if person == mayor and p.has_item("charter"):
		return false
	return super(person, p)


# --- Things to do ----------------------------------------------------------------------

func _borrow_coat(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if player.disguise == "townsfolk":
		UsableBody.hint(pic, "You're already wearing one.")
		return
	player.set_disguise("townsfolk")
	Sfx.at(self, "kenney:cloth2", player.global_position, -8.0)
	UsableBody.hint(pic, "In a coat, you're one of the townsfolk.")
	_record("wore:townsfolk")


func _wear_lanyard(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if player.disguise == "clerk":
		UsableBody.hint(pic, "You're already the clerk.")
		return
	player.set_disguise("clerk")
	if not player.has_item("staff_key"):
		player.add_item("staff_key")
	Sfx.at(self, "kenney:cloth2", player.global_position, -8.0)
	UsableBody.hint(pic, "Lanyard, folder, staff key. You look like you work here.")
	_record("wore:clerk")


func _search_mayor_coat(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if player.has_item("mayor_key") or mayor_coat.has_meta("searched"):
		UsableBody.hint(pic, "Just a hanky and some mints.")
		return
	mayor_coat.set_meta("searched", true)
	player.add_item("mayor_key")
	Sfx.at(self, "kenney:metalClick", mayor_coat.global_position, -10.0, 1.3)
	UsableBody.hint(pic, "The mayor's keys: her office and the strongbox.")
	_record("took:mayor_key")
	mayor_coat.set_action_text("interact", "Search the red coat again")


func _take_recipe(pic: PlayerInteractionComponent, card: UsableBody) -> void:
	_read(pic, "recipe_card", "A recipe on the fridge", RECIPE)
	pic.get_parent().add_item("recipe")
	Sfx.at(self, "kenney:cloth2", card.global_position, -10.0)
	_record("took:recipe")
	card.queue_free()


func _read_speech(pic: PlayerInteractionComponent) -> void:
	if speech_swapped:
		_read(pic, "recipe_on_lectern", "On the lectern", RECIPE)
	else:
		_read(pic, "hoard_speech", "Hoard's speech", HOARD_SPEECH)


func _swap_speech(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if speech_swapped or not player.take_item("recipe"):
		return
	speech_swapped = true
	player.add_item("hoard_speech")
	Sfx.at(self, "kenney:bookFlip1", lectern.global_position, -10.0)
	UsableBody.hint(pic, "Swapped. Mrs Dunn's sponge it is.")
	for s in hoard.routine:
		if s.has("speech"):
			s.say = RECIPE_LINES[int(s.speech)]
	_record("speech_swapped")
	_update_spots()


func _leave_sign(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if sign_left or not player.take_item("vote_no_sign"):
		return
	sign_left = true
	_placard_model(self, Vector3(-2.7, UP + 0.77, 4.6), 90.0, "VOTE NO", 0.6)
	Sfx.at(self, "kenney:cloth2", sign_spot.global_position, -10.0)
	_record("sign_on_desk")
	_update_spots()


func _leave_mop(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if mop_left or not player.take_item("mop"):
		return
	mop_left = true
	var m := _mop_mesh()
	m.position = mop_spot.position
	m.rotation.z = deg_to_rad(12)
	add_child(m)
	Sfx.at(self, "kenney:cloth2", mop_spot.global_position, -10.0)
	_record("mop_in_chamber")
	_update_spots()


## What the drop-off spots offer depends on what's in the bag.
func _update_spots() -> void:
	var p := _player
	sign_spot.set_action_text("interact", "Leave the sign on her desk" if p and not sign_left and p.has_item("vote_no_sign") else "")
	mop_spot.set_action_text("interact", "Prop the mop up here" if p and not mop_left and p.has_item("mop") else "")
	lectern.set_action_text("interact2", "Swap in the recipe" if p and not speech_swapped and p.has_item("recipe") else "")


func _ring_bell(pic: PlayerInteractionComponent) -> void:
	if _bell_t > 0.0:
		return
	_bell_t = 6.0
	Sfx.at(self, "town_hall_bell", _bell.global_position, 4.0)
	Sfx.at(self, "town_hall_bell", rope.global_position + Vector3(0, 1.5, 0), -4.0)
	var t := _bell.create_tween()
	t.tween_property(_bell, "rotation:x", 0.5, 0.35).set_trans(Tween.TRANS_SINE)
	t.tween_property(_bell, "rotation:x", -0.4, 0.6).set_trans(Tween.TRANS_SINE)
	t.tween_property(_bell, "rotation:x", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	StealthNoise.make(self, rope.global_position + Vector3(0, 1, 0), 8.0, "knock", pic.get_parent())
	_record("rang_bell")
	if mayor and not mayor.is_asleep() and not mayor.is_alert():
		mayor.say("Who's ringing the bell? Stanley, go and look!")
	if hoard and not hoard.is_asleep():
		hoard.say("A bell? At this hour?")
	if caretaker and not caretaker.is_asleep() and caretaker.state != Person.State.CHASE:
		caretaker._curious(points["roof_house"], 1.0, "Who's that at my bell?")
	for c in crowd:
		if randf() < 0.5:
			c._curious(c.global_position, 0.0, "")


## The main breaker: the meeting goes dark.
func set_power(on: bool) -> void:
	var was_off := power_off()
	super(on)
	if not on and not was_off:
		if mayor and not mayor.is_asleep():
			mayor.say("Nobody panic! Stanley, the fuses!")
		if hoard and not hoard.is_asleep():
			hoard.say("Is this a joke? Who turned out the lights?")
		for c in crowd:
			c._curious(c.global_position, 0.0, "")


func _relock(_by: Node, door: HouseDoor) -> void:
	if _by is Person:
		door.locked = true
		door._update_text()


func _on_way_out(id: String) -> void:
	_record("way_out:" + id)
	if id == "front" and _player and _player.disguise == "townsfolk":
		_record("left_as_townsfolk")


func _toast(text: String) -> void:
	var job := get_parent() as Job
	if job and job.hud:
		job.hud.toast(text, Color("ffd54a"))


# --- Building bits ----------------------------------------------------------------------

## A straight flight of stairs `STOREY` high from `z_low` (bottom) to
## `z_high` (top), between x0 and x1, on the storey at `base.y`. The model
## is centred on `base`.
func _stairs(base: Vector3, z_low: float, z_high: float, x0: float, x1: float, surface: String) -> void:
	var up_north := z_high < z_low
	Kit.model(self, Kit.BUILDING + "stairs-closed.glb", base, 180.0 if up_north else 0.0)
	var body := StaticBody3D.new()
	body.collision_layer = Kit.LAYER_WORLD
	body.collision_mask = 0
	var cs := CollisionShape3D.new()
	var wedge := ConvexPolygonShape3D.new()
	var pts := PackedVector3Array()
	var back := 0.5 if up_north else -0.5
	var y := base.y
	for x in [x0, x1]:
		pts.append_array([Vector3(x, y, z_low), Vector3(x, y, z_high), Vector3(x, y + UP, z_high),
			Vector3(x, y + UP, z_high + back), Vector3(x, y + 0.15, z_low)])
	wedge.points = pts
	cs.shape = wedge
	body.add_child(cs)
	add_child(body)
	Kit.add_surface(body, surface)
	body.add_to_group(Kit.NAV_GROUP)


## A model scaled by `scale` (per axis), centred on `pos` and standing on
## it, with a box to bump into if `solid`.
func _centered(path: String, pos: Vector3, yaw: float, scale: Vector3, solid: bool) -> Node3D:
	var root: Node3D
	if solid:
		var body := StaticBody3D.new()
		body.collision_layer = Kit.LAYER_WORLD
		body.collision_mask = 0
		body.add_to_group(Kit.NAV_GROUP)
		root = body
	else:
		root = Node3D.new()
	root.position = pos
	root.rotation.y = deg_to_rad(yaw)
	add_child(root)
	var n: Node3D = Kit.scene(path).instantiate()
	n.scale = scale
	root.add_child(n)
	var box := Kit.aabb_of(n)
	var c := box.get_center()
	n.position = Vector3(-c.x, 0, -c.z)
	if solid:
		var cs := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = box.size.max(Vector3(0.05, 0.05, 0.05))
		cs.shape = shape
		cs.position = Vector3(0, box.get_center().y, 0)
		root.add_child(cs)
		Kit.add_surface(root, "wood")
	return root


## Sets an action's prompt while building (before the level is in the tree).
func _prompt(body: UsableBody, input: String, text: String) -> void:
	var a := body.action(input)
	a.interaction_text = text
	a.is_disabled = text == ""


## A plain box with no collision: trims, frames, signs.
func _slab(center: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	bm.material = Kit.flat(color)
	mi.mesh = bm
	mi.position = center
	add_child(mi)
	return mi


func _label(text: String, pos: Vector3, yaw: float, font_size: int, color: Color) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.position = pos
	l.rotation.y = deg_to_rad(yaw)
	l.font_size = font_size
	l.pixel_size = 0.005
	l.modulate = color
	l.outline_size = 8
	l.outline_modulate = Color(0, 0, 0, 0.6)
	add_child(l)
	return l


func _wall_lamp(room: String, pos: Vector3, yaw: float, on: bool, energy: float, reach: float) -> void:
	Kit.model(self, Kit.FURNITURE + "lampWall.glb", pos - Vector3(0, 0, 0.1), yaw, Kit.FURNITURE_SCALE)
	var l := OmniLight3D.new()
	l.position = pos + Basis(Vector3.UP, deg_to_rad(yaw)) * Vector3(0, 0, 0.35)
	l.light_color = Color(1.0, 0.85, 0.6)
	l.omni_range = reach
	l.light_energy = energy
	l.shadow_enabled = true
	l.visible = on
	l.add_to_group("stealth_lights")
	add_child(l)
	if not lights.has(room):
		lights[room] = []
	lights[room].append(l)


func _street_lamp(room: String, pos: Vector3) -> void:
	Kit.model(self, LIGHTPOST, pos, 0.0, 3.0)
	Kit.block(self, pos + Vector3(0, 1.9, 0), Vector3(0.3, 3.8, 0.3), "", null, false)
	var l := SpotLight3D.new()
	l.position = pos + Vector3(0, 3.5, 0.95)
	l.rotation.x = -PI * 0.5
	l.light_color = Color(1.0, 0.8, 0.5)
	l.spot_range = 9.0
	l.spot_angle = 60.0
	l.light_energy = 2.0
	l.shadow_enabled = true
	l.add_to_group("stealth_lights")
	add_child(l)
	if not lights.has(room):
		lights[room] = []
	lights[room].append(l)


func _coat_mesh(color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.18
	cm.height = 0.95
	cm.material = Kit.flat(color)
	mi.mesh = cm
	mi.position = Vector3(0, 0.45, 0)
	mi.scale = Vector3(1.0, 1.0, 0.55)
	return mi


func _coat(pos: Vector3, color: Color) -> void:
	var c := _coat_mesh(color)
	c.position += pos
	add_child(c)


func _mop_mesh() -> Node3D:
	var root := Node3D.new()
	var handle := MeshInstance3D.new()
	var hm := CylinderMesh.new()
	hm.top_radius = 0.02
	hm.bottom_radius = 0.02
	hm.height = 1.35
	hm.material = Kit.flat(Color(0.65, 0.5, 0.3))
	handle.mesh = hm
	handle.position = Vector3(0, 0.75, 0)
	root.add_child(handle)
	var head := MeshInstance3D.new()
	var mh := CylinderMesh.new()
	mh.top_radius = 0.06
	mh.bottom_radius = 0.16
	mh.height = 0.18
	mh.material = Kit.flat(Color(0.85, 0.85, 0.78))
	head.mesh = mh
	head.position = Vector3(0, 0.09, 0)
	root.add_child(head)
	return root


## A protest placard on a stick, with `text` on it.
func _placard_model(parent: Node, pos: Vector3, yaw: float, text: String, scale := 1.0) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = deg_to_rad(yaw)
	root.scale = Vector3.ONE * scale
	parent.add_child(root)
	var stick := MeshInstance3D.new()
	var sm := BoxMesh.new()
	sm.size = Vector3(0.05, 1.0, 0.05)
	sm.material = Kit.flat(Color(0.6, 0.45, 0.3))
	stick.mesh = sm
	stick.position = Vector3(0, 0.5, -0.04)
	root.add_child(stick)
	var board := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.6, 0.4, 0.02)
	bm.material = Kit.flat(Color(0.95, 0.93, 0.85))
	board.mesh = bm
	board.position = Vector3(0, 1.0, 0)
	root.add_child(board)
	var l := Label3D.new()
	l.text = text
	l.font_size = 40
	l.pixel_size = 0.0035
	l.modulate = Color(0.75, 0.1, 0.1)
	l.position = Vector3(0, 1.0, 0.012)
	l.width = 160.0
	l.autowrap_mode = TextServer.AUTOWRAP_WORD
	root.add_child(l)


func screenshot_views() -> Dictionary:
	return {
		"square": [Vector3(-1, 0, 18), 0.0, 8.0],
		"front": [Vector3(-1, 0, 10.5), 0.0, 12.0],
		"lobby": [Vector3(-1, 0, 7), 0.0, -2.0],
		"reception": [Vector3(2, 0, 4.5), 30.0, -8.0],
		"cloakroom": [Vector3(-4.6, 0, 5), 80.0, -10.0],
		"chamber_back": [Vector3(0, 0, -0.6), 0.0, -4.0],
		"chamber_side": [Vector3(7.2, 0, -1), 30.0, -6.0],
		"dais": [Vector3(-5.2, 0.2, -8.2), -150.0, -10.0],
		"crowd": [Vector3(-7.2, 0.0, -7.3), -120.0, -12.0],
		"cupboard": [Vector3(-8.7, 0, 7.3), 70.0, -10.0],
		"back_stair": [Vector3(-9.5, 0, 2), 10.0, 10.0],
		"clerk_office": [Vector3(9, 0, -5), 20.0, -10.0],
		"archive": [Vector3(9.4, BASE, 3.5), 0.0, -5.0],
		"tea_room": [Vector3(4.8, 0, 2.8), -150.0, -10.0],
		"corridor": [Vector3(-11, UP, 1), -90.0, -3.0],
		"mayor_office": [Vector3(-3.2, UP, 2.8), -130.0, -12.0],
		"strongbox": [Vector3(0.4, UP, 4.4), -90.0, -25.0],
		"balcony": [Vector3(-3.4, UP, 9.4), -120.0, -5.0],
		"roof": [Vector3(-6, ROOF, -6), 150.0, -8.0],
		"roof_house": [Vector3(-9, ROOF, -6.5), 30.0, 15.0],
		"annex_roof": [Vector3(10.5, UP, -9.2), 180.0, 5.0],
		"car_park": [Vector3(-24, 0, 9), -50.0, 5.0],
		"yard": [Vector3(4, 0, -20), -150.0, 8.0],
	}
