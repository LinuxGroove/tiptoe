class_name MarketLevel
extends JobLevel
## Kettleford's corner market after closing: one storey on a 2 m grid, with
## the high street to the south, a dark side passage to the east, and the
## loading bay and back alley to the north. X runs east, Z runs south towards
## the street. The flat roof is 2.5 m up.
##
## The shop floor (south) has three aisles of shelves, the freezers along the
## west wall, the till by the east wall and the bottle machine by the door.
## Behind it are the stock room (west, with the walk-in freezer in its corner)
## and the back office (east), where Mrs Pruitt counts Hoard's rent and the
## rent ledger sits on her desk. The office has two doors: a keypad door from
## the stock room and a locked door behind the till, and both have closers
## that shut and lock them a little while after anyone goes through.
##
## Routes to the ledger:
## - The till note: pick the shop door (its bell rings), read the sticky
##   note under the till and type its code into the office keypad in the
##   stock room while Mrs Pruitt is out on her rounds.
## - On shift: put on the spare apron by the bins, ring the deliveries bell
##   at the back and Dev lets the "new starter" in. Cameras and Dev ignore
##   staff; knock on the office door and Mrs Pruitt marches off to recount
##   the till, leaving the door open behind her.
## - The power cut: flip the breaker in the meter cupboard at the end of the
##   alley. The cameras die, the office keypad lets go, and Mrs Pruitt walks
##   out the back to fix it, leaving the back door open.
## - The roof: climb the skip onto the flat roof (or start there), pick the
##   hatch's padlock and climb down into the stock room's blind corner.
## - The vent: from a crate in the stock room, unscrew the vent and crawl
##   through into the office, quietly, while Mrs Pruitt is away from her desk.
## - The bins break: Dev takes the bins out and leaves the back door open
##   until Mrs Pruitt does her rounds and locks it again.
## - Lures: the bottle machine's button (or a dart at it) and the noisemaker
##   pull Dev to the front; a rattle at the office door brings Mrs Pruitt out
##   to look, and so does the alarm (let a camera see you, then hide). She
##   leaves the office doors to their closers, so they stand open behind her.
## - The office door behind the till can be picked, under the till camera.
## - Snooze darts (mastery 2) and darted cameras clear the way anywhere.

const MARKET := "res://assets/kenney/mini-market/"
const CITY := "res://assets/kenney/city-commercial/"
const CARS := "res://assets/kenney/car-kit/"
const MarketPerson := preload("res://game/jobs/market/market_person.gd")
const Hatch := preload("res://game/jobs/market/market_hatch.gd")

const UP := JobLevel.STOREY
const OFFICE_CODE := "0412"
## Seconds an office door stands open before its closer shuts (and locks) it.
const CLOSER_TIME := 12.0
const MINI_SCALE := 2.0

const TILE := Color(0.82, 0.84, 0.8)
const CONCRETE := Color(0.46, 0.46, 0.45)
const STOCK_FLOOR := Color(0.55, 0.53, 0.5)
const CARPET := Color(0.32, 0.36, 0.42)
const ROAD := Color(0.18, 0.18, 0.2)
const PAVEMENT := Color(0.52, 0.52, 0.5)
const BRICK := Color(0.45, 0.27, 0.22)
const BRICK_DARK := Color(0.32, 0.22, 0.2)
const ROOF := Color(0.3, 0.3, 0.32)
const SHOP_GREEN := Color(0.15, 0.45, 0.3)
const APRON := Color(0.2, 0.55, 0.35)

## Lights on when the night starts.
const LIGHTS_ON := ["front", "till", "office", "bay", "street", "aisle_west"]
## Everything the breaker in the alley powers (all but the street lamps).
const SHOP_CIRCUIT := ["front", "till", "aisle_west", "aisle_east", "stock", "freezer", "office", "bay", "sign"]
const OFFICE_DOORS := ["office_door", "office_front"]

const TILL_NOTE := """OFFICE: 0412

(Mr Hoard's birthday. 4th of December.
Don't tell him we know.)
- Dev"""

const STAFF_NOTICE := """STAFF

The office code has been changed AGAIN.
It's on the sticky note under the till, as usual.
Do NOT write it down anywhere else.

- Management"""

const JOB_AD := """STAFF WANTED

Night shifts, start right away.
Aprons provided (there's a spare on the hook by the bins).
New starters: ring the deliveries bell round the back."""

const ELECTRICIAN_NOTE := """SPARKS & SONS, ELECTRICIANS

Mr Hoard,
This breaker trips if you look at it. When the power goes,
the shop goes dark, the cameras go off and the office
door's lock lets go. Get it fixed before someone notices.

Invoice no. 3 enclosed.
(UNPAID - A. Hoard)"""

const HOARD_LETTER := """HOARD PROPERTIES

Pruitt,
Collect from every shop on the High Street by Friday.
The bakery: up again. The launderette: double.
The chip shop: whatever they've got.
The real figures go in the ledger. The nice ones go on the receipts.
And tell Dev to stop eating the stock.
- A. Hoard"""

const DEV_LIST := """DEV'S LIST

1. Restock the beans (again)
2. Bins out. Leave the back door on the latch,
   Pruitt locks it on her rounds anyway
3. Do NOT eat the pickled eggs
4. Office code? Under the till. Obviously."""

var office_pad: Keypad
## The camera switch by Mrs Pruitt's monitor.
var camera_switch: UsableBody
var hatch: UsableBody
var dev: Person
var pruitt: Person
var cams := {}
var till: UsableBody
var bottle_machine: UsableBody
var carts: Array = []
var _carts_home := 0
var _cart_slots: Array = []
var _cookbook_left := false
var _melon_on := false
var _bottle_t := 0.0
var _greeted := false
## How long each office door has stood open.
var _open_t := {}
## The knock at the office door: 0 nobody's coming, 1 she's on her way,
## 2 she's opened up and is looking.
var _knock := 0
var _knock_t := 0.0
var _thanks: Label3D
var _vent_open := false
var _vent_office: UsableBody
var _bag_hooked := false


func build() -> void:
	circuit = SHOP_CIRCUIT
	alarm_time = 25.0
	_street()
	_alley()
	_shop_floor()
	_stock_room()
	_office()
	_roof()
	_furnish_shop()
	_furnish_back()
	_lamps()
	_security()
	_things()
	_marks()
	house_boxes.append(AABB(Vector3(-10, -0.5, -12), Vector3(20, UP + 0.5, 18)))
	areas["office"] = AABB(Vector3(4, -0.5, -12), Vector3(6, UP + 0.5, 8))
	areas["stock_room"] = AABB(Vector3(-10, -0.5, -12), Vector3(14, UP + 0.5, 8))
	areas["roof"] = AABB(Vector3(-10.2, UP - 0.1, -12.2), Vector3(20.4, 3.0, 18.4))
	# The stock room is staff only; nobody belongs in the office but Mrs Pruitt.
	add_zone("stock_room", AABB(Vector3(-10, -0.5, -12), Vector3(14, UP + 0.5, 8)), ["staff"])
	add_zone("office", areas["office"], [])
	# The freezers hum.
	add_masking(AABB(Vector3(-10, -0.5, -3.5), Vector3(2.6, 3.0, 7.0)), 0.35)
	add_masking(AABB(Vector3(-10, -0.5, -12), Vector3(4, 3.0, 4)), 0.5)
	for room in lights:
		set_lights(room, room in LIGHTS_ON)
	for id in OFFICE_DOORS:
		_open_t[id] = 0.0
	doors["shop_door"].opened.connect(_on_shop_door_opened)


# --- The building -------------------------------------------------------------

func _street() -> void:
	# Pavement, road and the far pavement, from one end of the high street to the other.
	Kit.block(self, Vector3(0, -0.04, 7.5), Vector3(60, 0.08, 3), "concrete", Kit.flat(PAVEMENT))
	Kit.block(self, Vector3(0, -0.06, 12.5), Vector3(60, 0.1, 7), "concrete", Kit.flat(ROAD))
	Kit.block(self, Vector3(0, -0.04, 17.5), Vector3(60, 0.08, 3), "concrete", Kit.flat(PAVEMENT))
	# Kerbs.
	Kit.block(self, Vector3(0, 0.05, 9.05), Vector3(60, 0.1, 0.1), "", Kit.flat(Color(0.6, 0.6, 0.58)))
	Kit.block(self, Vector3(0, 0.05, 15.95), Vector3(60, 0.1, 0.1), "", Kit.flat(Color(0.6, 0.6, 0.58)))
	# Shops across the road, and the street's ends.
	var across := [["building-a", -22.0], ["building-c", -12.0], ["building-f", -2.0], ["building-a", 8.0], ["building-c", 18.0], ["building-f", 27.0]]
	for b in across:
		Kit.boxed(self, CITY + b[0] + ".glb", Vector3(b[1], 0, 23.5), 180.0, 9.0)
	Kit.block(self, Vector3(-30.5, 1.5, 12.5), Vector3(1, 3, 13), "")
	Kit.block(self, Vector3(30.5, 1.5, 12.5), Vector3(1, 3, 13), "")
	# The neighbours: the launderette to the west, the chip shop to the east.
	_neighbour(Vector3(-15, 0, -3), "LAUNDERETTE", Color(0.42, 0.3, 0.26))
	_neighbour(Vector3(17, 0, -3), "FISH & CHIPS", Color(0.38, 0.33, 0.28))
	Kit.block(self, Vector3(-25, 3.5, -8), Vector3(10, 7, 28), "", Kit.flat(BRICK_DARK))
	Kit.block(self, Vector3(26, 3.5, -8), Vector3(8, 7, 28), "", Kit.flat(BRICK_DARK))
	# The side passage up to the alley, with a gate to climb.
	floor_rect(0, 10, -12, 12, 6, "concrete", CONCRETE, false)
	Kit.block(self, Vector3(11, 0.7, 2), Vector3(2, 1.4, 0.1), "", Kit.flat(Color(0.3, 0.32, 0.3)))
	Kit.block(self, Vector3(11, 1.38, 2), Vector3(2, 0.06, 0.16), "", Kit.flat(Color(0.25, 0.26, 0.25)))


func _neighbour(center: Vector3, sign_text: String, color: Color) -> void:
	Kit.block(self, center + Vector3(0, 3.5, 0), Vector3(10, 7, 18), "", Kit.flat(color))
	# A dark shop front and its sign.
	var front := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(7, 2.2, 0.05)
	bm.material = Kit.flat(Color(0.1, 0.12, 0.16), 0.2)
	front.mesh = bm
	front.position = center + Vector3(0, 1.3, 9.03)
	add_child(front)
	var label := Label3D.new()
	label.text = sign_text
	label.font_size = 96
	label.pixel_size = 0.006
	label.modulate = Color(0.85, 0.8, 0.7)
	label.position = center + Vector3(0, 2.95, 9.06)
	add_child(label)


func _alley() -> void:
	floor_rect(0, -20, -22.5, 22, -12, "concrete", CONCRETE, false)
	Kit.block(self, Vector3(1, 2.25, -23), Vector3(44, 4.5, 1), "", Kit.flat(BRICK))
	Kit.block(self, Vector3(-20.5, 1.6, -17), Vector3(1, 3.2, 11), "", Kit.flat(BRICK))
	Kit.block(self, Vector3(22.5, 1.6, -17), Vector3(1, 3.2, 11), "", Kit.flat(BRICK))
	# The delivery van backed up to the loading shutter.
	Kit.boxed(self, CARS + "delivery.glb", Vector3(-5.5, 0, -16.5), 0.0, 1.35)
	# The skip under the office's back wall: the way onto the roof.
	Kit.block(self, Vector3(7.5, 0.65, -12.7), Vector3(2.2, 1.3, 1.1), "", Kit.flat(Color(0.22, 0.35, 0.28)))
	Kit.block(self, Vector3(7.5, 1.32, -12.7), Vector3(2.3, 0.06, 1.2), "", Kit.flat(Color(0.18, 0.28, 0.22)))
	# Wheelie bins by the back door.
	for x in [-3.6, -2.8]:
		Kit.block(self, Vector3(x, 0.55, -12.55), Vector3(0.7, 1.1, 0.8), "", Kit.flat(Color(0.2, 0.25, 0.35)))
	# Pallets and crates along the alley wall.
	for c in [Vector3(-12, 0.4, -21.8), Vector3(-10.6, 0.4, -21.8), Vector3(-11.3, 1.2, -21.8), Vector3(14, 0.4, -21.6)]:
		Kit.block(self, c, Vector3(1.2, 0.8, 1.0), "", Kit.flat(Color(0.5, 0.4, 0.28)))
	# The meter cupboard at the west end, where the shop's breaker is.
	Kit.block(self, Vector3(-17, 1.1, -22.15), Vector3(1.6, 2.2, 0.7), "", Kit.flat(Color(0.4, 0.42, 0.38)))


func _shop_floor() -> void:
	floor_rect(0, -10, -4, 10, 6, "tile", TILE, false)
	# The shop front: big windows either side of the door.
	line(0, Vector2(-10, 6), Vector2(1, 0), ".....D....", [
		{"id": "shop_door", "into": Vector2(1, 4), "locked": true, "pick": 7.0, "outside": true}])
	for i in 10:
		if i == 5:
			continue
		var wall := Kit.solid(self, Kit.BUILDING + "wall-window-wide-square.glb", Vector3(-9 + 2 * i, 0, 6), 90.0, WALL_SCALE)
		var glass := StaticBody3D.new()
		glass.collision_layer = Kit.LAYER_GLASS
		glass.collision_mask = 0
		var cs := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(0.04, 1.7, 1.8)
		cs.shape = shape
		cs.position = Vector3(0, 1.35, 0)
		glass.add_child(cs)
		wall.add_child(glass)
	line(0, Vector2(-10, -4), Vector2(0, 1), "WWWWW")
	line(0, Vector2(10, -4), Vector2(0, 1), "WWWWW")
	# The fascia over the windows, with the shop's name.
	Kit.block(self, Vector3(0, UP + 0.35, 6.1), Vector3(20.4, 0.7, 0.2), "", Kit.flat(SHOP_GREEN))
	var label := Label3D.new()
	label.text = "KETTLEFORD CORNER MARKET"
	label.font_size = 110
	label.pixel_size = 0.006
	label.modulate = Color(1.0, 0.95, 0.8)
	label.position = Vector3(0, UP + 0.35, 6.22)
	add_child(label)


func _stock_room() -> void:
	floor_rect(0, -10, -12, 4, -4, "concrete", STOCK_FLOOR, false)
	# The wall between the shop and the back, with the staff door.
	line(0, Vector2(-10, -4), Vector2(1, 0), "WWWWWWD", [{"id": "staff_door", "into": Vector2(3, -6)}])
	# The back wall: the loading shutter, and the back door (the deliveries
	# door, which Dev answers: people answer the door called "front_door").
	line(0, Vector2(-10, -12), Vector2(1, 0), "WWWWDWW", [
		{"id": "front_door", "into": Vector2(-1, -10), "locked": true, "pick": 6.0, "outside": true}])
	line(0, Vector2(-10, -12), Vector2(0, 1), "WWWW")
	# The walk-in freezer.
	line(0, Vector2(-10, -8), Vector2(1, 0), "DW", [{"id": "freezer_door", "into": Vector2(-9, -10)}])
	line(0, Vector2(-6, -12), Vector2(0, 1), "WW")
	# The loading shutter, shut, on the outside.
	Kit.block(self, Vector3(-5, 1.15, -12.14), Vector3(1.9, 2.3, 0.06), "", Kit.flat(Color(0.55, 0.57, 0.6)), false)
	for i in 8:
		Kit.block(self, Vector3(-5, 0.15 + i * 0.28, -12.18), Vector3(1.9, 0.03, 0.02), "", Kit.flat(Color(0.42, 0.44, 0.46)), false)


func _office() -> void:
	floor_rect(0, 4, -12, 10, -4, "carpet", CARPET, false)
	# The keypad door from the stock room, and the door behind the till.
	line(0, Vector2(4, -12), Vector2(0, 1), "WWDW", [
		{"id": "office_door", "into": Vector2(6, -7), "locked": true}])
	line(0, Vector2(4, -4), Vector2(1, 0), "WDW", [
		{"id": "office_front", "into": Vector2(7, -6), "locked": true, "pick": 9.0}])
	line(0, Vector2(4, -12), Vector2(1, 0), "WWW")
	line(0, Vector2(10, -12), Vector2(0, 1), "WwWW")


func _roof() -> void:
	# The flat roof, with a hole for the hatch over the stock room's back corner.
	floor_rect(UP, -10.1, -10.9, 10.1, 6.1, "concrete", ROOF)
	floor_rect(UP, -10.1, -12.1, -4, -10.9, "concrete", ROOF)
	floor_rect(UP, -3, -12.1, 10.1, -10.9, "concrete", ROOF)
	floor_rect(UP, -4, -12.1, -3, -11.9, "concrete", ROOF)
	# A low parapet along the front and the sides (the back is open to the skip).
	Kit.block(self, Vector3(-10.05, UP + 0.2, -3), Vector3(0.1, 0.4, 18.2), "", Kit.flat(ROOF))
	Kit.block(self, Vector3(10.05, UP + 0.2, -3), Vector3(0.1, 0.4, 18.2), "", Kit.flat(ROOF))
	# Air conditioning boxes and the shop sign's frame.
	Kit.block(self, Vector3(6, UP + 0.45, -8), Vector3(1.6, 0.9, 1.2), "", Kit.flat(Color(0.6, 0.62, 0.62)))
	Kit.block(self, Vector3(-6, UP + 0.35, -1), Vector3(1.2, 0.7, 1.2), "", Kit.flat(Color(0.6, 0.62, 0.62)))
	hatch = Hatch.make(self, Vector3(-3.5, UP - 0.04, -11.9))
	hatch.below = Vector3(-3.5, 0, -11.2)
	hatch.above = Vector3(-3.5, UP, -10.3)
	add_child(hatch)
	openings.append({"id": "roof_hatch", "kind": "roof", "pos": Vector3(-3.5, UP, -11.4)})
	# The ladder down from it, on the stock room's back wall.
	var rail := Kit.flat(Color(0.5, 0.52, 0.55), 0.5)
	for x in [-3.85, -3.15]:
		Kit.block(self, Vector3(x, UP * 0.5, -11.88), Vector3(0.05, UP, 0.05), "", rail, false)
	for i in 8:
		Kit.block(self, Vector3(-3.5, 0.3 + i * 0.3, -11.88), Vector3(0.7, 0.04, 0.04), "", rail, false)
	var ladder := UsableBody.new()
	ladder.name = "Ladder"
	ladder.position = Vector3(-3.5, 1.2, -11.8)
	ladder.collision_layer = Kit.LAYER_INTERACT
	ladder.add_box(Vector3.ZERO, Vector3(0.8, 2.4, 0.2))
	ladder.add_action("interact", "Climb the ladder", _climb_ladder)
	add_child(ladder)


func _furnish_shop() -> void:
	# Upright freezers along the west wall.
	for z in [-2.0, 0.0, 2.0]:
		Kit.boxed(self, MARKET + "freezers-standing.glb", Vector3(-9.45, 0, z), 90.0, MINI_SCALE)
	# Three rows of shelves, end on to the street, with room behind them.
	var kinds := ["shelf-bags", "shelf-boxes"]
	var row := 0
	for x in [-6.5, -3.0, 0.5]:
		var i := 0
		for z in [-1.4, 0.2, 1.8]:
			Kit.boxed(self, MARKET + kinds[(row + i) % 2] + ".glb", Vector3(x, 0, z), 90.0, MINI_SCALE)
			i += 1
		Kit.boxed(self, MARKET + "shelf-end.glb", Vector3(x, 0, 3.0), 0.0, MINI_SCALE)
		row += 1
	# Chest freezer and the fruit and bread by the windows.
	Kit.boxed(self, MARKET + "display-fruit.glb", Vector3(-7.4, 0, 5.1), 0.0, MINI_SCALE)
	Kit.boxed(self, MARKET + "display-bread.glb", Vector3(-5.2, 0, 5.1), 0.0, MINI_SCALE)
	Kit.boxed(self, MARKET + "freezer.glb", Vector3(5.5, 0, -2.6), 0.0, MINI_SCALE)
	# Baskets by the door.
	for b in [Vector3(-1.2, 0, 5.6), Vector3(-1.2, 0.25, 5.6)]:
		Kit.model(self, MARKET + "shopping-basket.glb", b, 10.0, MINI_SCALE)
	# Behind the till: shelves of cigarettes and lottery tickets, a stool.
	Kit.furniture(self, "bookcaseClosed", Vector3(9.6, 0, 3.5), -90)
	Kit.furniture(self, "stoolBar", Vector3(8.6, 0, 2.2), 0, false)
	Kit.furniture(self, "trashcan", Vector3(9.5, 0, 5.4), 0)


func _furnish_back() -> void:
	# Stock room: shelving, a crate under the vent, the break table.
	for z in [-6.8, -5.2]:
		Kit.boxed(self, MARKET + "shelf-boxes.glb", Vector3(-9.25, 0, z), 90.0, MINI_SCALE)
	for x in [1.2, 2.8]:
		Kit.boxed(self, MARKET + "shelf-bags.glb", Vector3(x, 0, -11.25), 0.0, MINI_SCALE)
	Kit.block(self, Vector3(3.4, 0.45, -10), Vector3(0.9, 0.9, 0.9), "wood", Kit.flat(Color(0.55, 0.42, 0.28)))
	Kit.furniture(self, "table", Vector3(-0.5, 0, -8.6), 0)
	Kit.furniture(self, "chair", Vector3(-0.5, 0, -7.6), 180, false)
	Kit.furniture(self, "kitchenCoffeeMachine", Vector3(-0.2, 0.66, -8.8), 0, false)
	Kit.furniture(self, "kitchenFridgeSmall", Vector3(-2.0, 0, -11.55), 0)
	# The box pile (a hiding place) and loose boxes.
	for b in [Vector3(-5.3, 0, -5.0), Vector3(-4.7, 0, -5.0), Vector3(-5.3, 0, -5.8), Vector3(-5.3, 0.56, -5.0), Vector3(-4.7, 0, -5.8), Vector3(-5.3, 0.56, -5.8)]:
		Kit.furniture(self, "cardboardBoxClosed", b, randf() * 20.0, b.y == 0.0)
	for b in [Vector3(-1.5, 0, -5.0), Vector3(2.4, 0, -6.6), Vector3(-7.4, 0, -11.2)]:
		Kit.furniture(self, "cardboardBoxOpen", b, randf() * 60.0)
	# The walk-in freezer: shelves of frozen peas.
	Kit.boxed(self, MARKET + "shelf-boxes.glb", Vector3(-9.25, 0, -10.6), 90.0, MINI_SCALE)
	Kit.boxed(self, MARKET + "freezer.glb", Vector3(-7.2, 0, -9.0), 0.0, MINI_SCALE)
	# Office: the desk, the camera monitor, the safe, a filing cabinet under the vent.
	Kit.furniture(self, "desk", Vector3(7, 0, -11.45), 0)
	Kit.furniture(self, "chairDesk", Vector3(7, 0, -10.55), 180, false)
	Kit.furniture(self, "desk", Vector3(9.55, 0, -7), -90)
	Kit.furniture(self, "computerScreen", Vector3(9.65, 0.77, -7), -90, false)
	Kit.furniture(self, "sideTableDrawers", Vector3(4.4, 0, -10), 90)
	Kit.furniture(self, "coatRackStanding", Vector3(9.5, 0, -4.6), 0)
	Kit.furniture(self, "pottedPlant", Vector3(4.5, 0, -11.5), 0)
	Kit.boxed(self, Kit.PROPS + "safe.glb", Vector3(9.4, 0, -11.5), 0.0)


func _lamps() -> void:
	lamp("front", Vector3(-4, UP, 4.6), true, 1.2, 7.0)
	lamp("front", Vector3(3, UP, 4.6), true, 1.2, 7.0)
	lamp("aisle_west", Vector3(-6.5, UP, 0.2), true, 1.0, 6.0, Color(0.9, 0.95, 1.0))
	lamp("aisle_east", Vector3(-1.2, UP, 0.2), true, 1.0, 6.0, Color(0.9, 0.95, 1.0))
	lamp("till", Vector3(7.5, UP, 2.0), true, 1.2, 6.0)
	lamp("stock", Vector3(-3, UP, -8), true, 1.0, 7.0, Color(0.95, 0.95, 0.9))
	lamp("freezer", Vector3(-8, UP, -10), true, 0.6, 4.0, Color(0.6, 0.8, 1.0))
	lamp("office", Vector3(7, UP, -8.5), true, 1.1, 6.0)
	# The security light over the back door.
	Kit.model(self, Kit.FURNITURE + "lampWall.glb", Vector3(-1, 2.25, -12.06), 180, Kit.FURNITURE_SCALE)
	var bay := OmniLight3D.new()
	bay.position = Vector3(-1, 2.2, -12.5)
	bay.light_color = Color(1.0, 0.9, 0.75)
	bay.omni_range = 6.5
	bay.light_energy = 1.5
	bay.shadow_enabled = true
	bay.add_to_group("stealth_lights")
	add_child(bay)
	lights["bay"] = [bay]
	# The "CLOSED" sign glowing in the door.
	var sign_lamp := OmniLight3D.new()
	sign_lamp.position = Vector3(1, 1.9, 5.6)
	sign_lamp.light_color = Color(1.0, 0.35, 0.3)
	sign_lamp.omni_range = 2.5
	sign_lamp.light_energy = 0.8
	add_child(sign_lamp)
	lights["sign"] = [sign_lamp]
	var closed := Label3D.new()
	closed.text = "CLOSED"
	closed.font_size = 64
	closed.pixel_size = 0.005
	closed.modulate = Color(1.0, 0.3, 0.25)
	closed.position = Vector3(-1.3, 1.9, 6.15)
	add_child(closed)
	# Street lamps, one each side of the road.
	for s in [Vector3(-3, 0, 8.7), Vector3(9, 0, 16.3)]:
		Kit.block(self, s + Vector3(0, 2.0, 0), Vector3(0.15, 4.0, 0.15), "", Kit.flat(Color(0.2, 0.2, 0.2)))
		var street := SpotLight3D.new()
		street.position = s + Vector3(0, 4.0, 0)
		street.rotation.x = -PI * 0.5
		street.light_color = Color(1.0, 0.8, 0.5)
		street.spot_range = 9.0
		street.spot_angle = 55.0
		street.light_energy = 2.0
		street.shadow_enabled = true
		street.add_to_group("stealth_lights")
		add_child(street)
		if not lights.has("street"):
			lights["street"] = []
		lights["street"].append(street)
	# Switches, by the doors.
	light_switch(["front", "aisle_west", "aisle_east"], Vector3(2.0, 1.3, -3.9), Vector3(0, 0, 1))
	light_switch(["till"], Vector3(9.9, 1.3, 1.0), Vector3(-1, 0, 0))
	light_switch(["stock"], Vector3(2.0, 1.3, -4.1), Vector3(0, 0, -1))
	light_switch(["freezer"], Vector3(-7.6, 1.3, -7.9), Vector3(0, 0, 1))
	light_switch(["office"], Vector3(4.1, 1.3, -5.9), Vector3(1, 0, 0))


func _security() -> void:
	# Cameras on the shop floor and in the stock room. They think nothing of staff.
	cams["floor"] = camera("floor", Vector3(-4.75, 2.3, -3.9), 0.0, {"sweep": 40.0, "period": 10.0, "pitch": 36.0, "accepts": ["staff"]})
	cams["till"] = camera("till", Vector3(9.5, 2.3, -3.9), -45.0, {"sweep": 40.0, "period": 9.0, "pitch": 34.0, "accepts": ["staff"]})
	cams["stock"] = camera("stock", Vector3(-2.0, 2.3, -4.1), 145.0, {"sweep": 38.0, "period": 11.0, "pitch": 26.0, "accepts": ["staff"]})
	# The office keypad, with a knock for the door, and the exit buttons inside.
	office_pad = keypad("office", OFFICE_CODE, Vector3(3.88, 1.3, -6.15), -90.0, "office_door")
	office_pad.add_action("interact2", "Knock on the door", _knock_on_door)
	_exit_button("office_door", Vector3(4.12, 1.2, -7.85), 90.0)
	_exit_button("office_front", Vector3(6.15, 1.2, -4.12), 180.0)
	# The monitor on Mrs Pruitt's side desk switches the cameras off.
	camera_switch = group_switch("cameras", "Switch off the cameras", "Switch the cameras back on", Vector3(9.4, 0.85, -6.3), -90.0)
	# The breaker, in the meter cupboard at the end of the alley.
	fuse_box(Vector3(-17, 1.2, -21.78), 0.0)


func _exit_button(door_id: String, pos: Vector3, yaw: float) -> void:
	var b := UsableBody.new()
	b.name = "Exit_" + door_id
	b.position = pos
	b.rotation.y = deg_to_rad(yaw)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.1, 0.1, 0.04)
	bm.material = Kit.flat(Color(0.2, 0.7, 0.3))
	mi.mesh = bm
	b.add_child(mi)
	b.add_box(Vector3.ZERO, Vector3(0.14, 0.14, 0.08))
	b.add_action("interact", "Press to exit", _press_exit.bind(door_id))
	add_child(b)


func _things() -> void:
	# The till, with the sticky note under it.
	Kit.boxed(self, MARKET + "cash-register.glb", Vector3(6, 0, 3), -90.0, MINI_SCALE)
	till = UsableBody.new()
	till.name = "Till"
	till.position = Vector3(6, 1.2, 3)
	till.collision_layer = Kit.LAYER_INTERACT
	till.add_box(Vector3(0, 0.15, 0), Vector3(0.9, 0.35, 0.9))
	till.add_action("interact", "Ring up no sale", _ring_till)
	till.add_action("interact2", "", _melon_on_till).is_disabled = true
	till.set_meta("dartable", true)
	add_child(till)
	note("till_note", "A sticky note under the till", TILL_NOTE, Vector3(5.35, 1.21, 2.4), 0, Vector3(0.14, 0.01, 0.14))
	# Things to read outside.
	note("job_ad", "A card in the shop window", JOB_AD, Vector3(-3, 1.4, 6.13), 0)
	note("staff_notice", "A notice by the back door", STAFF_NOTICE, Vector3(0.6, 1.5, -12.13), 180)
	note("electrician_note", "A note taped to the meter cupboard", ELECTRICIAN_NOTE, Vector3(-16.4, 1.6, -21.78), 0)
	# And inside.
	note("hoard_letter", "A letter on the desk", HOARD_LETTER, Vector3(7.05, 0.775, -11.25), 0, Vector3(0.22, 0.01, 0.3))
	note("dev_list", "Dev's list", DEV_LIST, Vector3(-0.8, 0.67, -8.5), 0, Vector3(0.2, 0.01, 0.26))
	# The deliveries bell at the back door.
	var bell := UsableBody.new()
	bell.name = "Doorbell"
	bell.position = Vector3(-0.3, 1.3, -12.1)
	bell.rotation.y = PI
	bell.add_child(Kit.scene(Kit.PROPS + "doorbell.glb").instantiate())
	bell.add_box(Vector3(0, 0, 0.03), Vector3(0.15, 0.2, 0.08))
	bell.add_action("interact", "Ring the deliveries bell", _ring_bell)
	add_child(bell)
	# The spare apron on its hook by the bins.
	var apron := UsableBody.new()
	apron.name = "Pickup_apron"
	apron.position = Vector3(-2.0, 1.15, -12.12)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.5, 0.8, 0.04)
	bm.material = Kit.flat(APRON)
	mi.mesh = bm
	apron.add_child(mi)
	apron.add_box(Vector3.ZERO, Vector3(0.55, 0.85, 0.12))
	apron.add_action("interact", "Put on the spare apron", _wear.bind("staff", "You look like you work here.", apron))
	add_child(apron)
	# The bottle machine by the door.
	Kit.boxed(self, MARKET + "bottle-return.glb", Vector3(-2.2, 0, 5.45), 180.0, MINI_SCALE)
	bottle_machine = UsableBody.new()
	bottle_machine.name = "BottleMachine"
	bottle_machine.position = Vector3(-2.2, 1.3, 5.0)
	bottle_machine.collision_layer = Kit.LAYER_INTERACT
	bottle_machine.add_box(Vector3.ZERO, Vector3(0.9, 0.8, 0.2))
	bottle_machine.add_action("interact", "Press the big green button", _press_bottle_machine)
	bottle_machine.set_meta("dartable", true)
	add_child(bottle_machine)
	_thanks = Label3D.new()
	_thanks.text = "THANK YOU FOR RECYCLING!"
	_thanks.font_size = 40
	_thanks.pixel_size = 0.004
	_thanks.modulate = Color(0.5, 1.0, 0.6)
	_thanks.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_thanks.position = Vector3(-2.2, 2.4, 5.2)
	_thanks.visible = false
	add_child(_thanks)
	# A watermelon on the fruit stand, and a cookbook by the door.
	pickup("melon", "Take a watermelon", Kit.FOOD + "watermelon.glb", Vector3(-7.4, 1.05, 5.1), 0.8)
	_book("cookbook", "Take the cookbook", Color(0.85, 0.3, 0.2), Vector3(-0.2, 0.96, 5.55), "101 Things to Do with Beans")
	Kit.block(self, Vector3(-0.2, 0.48, 5.55), Vector3(0.6, 0.96, 0.4), "", Kit.flat(Color(0.45, 0.35, 0.25)))
	# Carts: two in their line by the door, three left about.
	_cart_slots = [Vector3(2.8, 0, 5.1), Vector3(3.3, 0, 5.1), Vector3(3.8, 0, 5.1), Vector3(4.3, 0, 5.1), Vector3(4.8, 0, 5.1)]
	for i in 2:
		Kit.boxed(self, MARKET + "shopping-cart.glb", _cart_slots[i], 0.0, MINI_SCALE)
	for c in [[Vector3(-6.0, 0, 7.9), 200.0], [Vector3(11, 0, -6), 80.0], [Vector3(-3.0, 0, -9.0), 100.0]]:
		_loose_cart(c[0], c[1])
	# The rent ledger and the rent money on Mrs Pruitt's desk.
	treasure("ledger", "Take the rent ledger", Kit.FURNITURE + "books.glb", Vector3(7.5, 0.77, -11.4), Kit.FURNITURE_SCALE, 0, Vector3(0.45, 0.3, 0.4))
	treasure_stand.action("interact").on_use = _use_ledger
	_book("rent_money", "Take the rent money", Color(0.3, 0.32, 0.34), Vector3(6.55, 0.77, -11.55), "")
	# Hiding places: the box pile, and behind the peas in the walk-in freezer.
	hide_spot("boxes", "Hide in the box pile", Vector3(-5.0, 0, -5.4), 180.0, Vector3(0, 1.0, 0), Vector3(1.2, 1.4, 1.4))
	var peas := hide_spot("freezer", "Hide behind the frozen peas", Vector3(-8.6, 0, -10.6), 90.0, Vector3(0, 1.3, 0), Vector3(1.4, 2.0, 0.8))
	peas.action("interact").on_use = _hide_in_freezer.bind(peas)
	var hum := Sfx.on(peas, "fridge_hum_loop", -14.0)
	hum.max_distance = 10.0
	# The vent from the stock room into the office.
	var vent_stock := UsableBody.new()
	vent_stock.name = "VentStock"
	vent_stock.position = Vector3(3.94, 1.55, -10)
	vent_stock.rotation.y = -PI * 0.5
	vent_stock.add_child(Kit.scene(Kit.PROPS + "wall_vent.glb").instantiate())
	vent_stock.add_box(Vector3(0, 0.2, 0.05), Vector3(0.6, 0.4, 0.1))
	vent_stock.add_action("interact", "Unscrew the vent cover", _use_vent.bind(true))
	add_child(vent_stock)
	_vent_office = UsableBody.new()
	_vent_office.name = "VentOffice"
	_vent_office.position = Vector3(4.06, 1.55, -10)
	_vent_office.rotation.y = PI * 0.5
	_vent_office.add_child(Kit.scene(Kit.PROPS + "wall_vent.glb").instantiate())
	_vent_office.add_box(Vector3(0, 0.2, 0.05), Vector3(0.6, 0.4, 0.1))
	_vent_office.add_action("interact", "Crawl into the vent", _use_vent.bind(false))
	add_child(_vent_office)


func _marks() -> void:
	add_start("street", Vector3(-6, 0, 13.5), 0)
	add_start("loading_bay", Vector3(-13, 0, -17), -90)
	add_start("roof", Vector3(8, UP, -1), 90)
	points = {
		"aisle_a": Vector3(-8.1, 0, 0.5), "aisle_b": Vector3(-4.75, 0, -0.8), "aisle_c": Vector3(-1.25, 0, 1.6),
		"till": Vector3(7.7, 0, 3.0), "shop_door_in": Vector3(1, 0, 4.2), "bottles": Vector3(-2.2, 0, 4.2),
		"stock_shelf": Vector3(-8.2, 0, -6.0), "stock_table": Vector3(-0.5, 0, -7.4),
		"stock_in": Vector3(-1, 0, -10.2), "back_check": Vector3(-1, 0, -9.6),
		"front_door_in": Vector3(-1, 0, -11.0), "front_step": Vector3(-1, 0, -13.2), "bins": Vector3(-3.2, 0, -13.6),
		"desk": Vector3(7, 0, -10.55), "monitor": Vector3(8.5, 0, -7), "office_door_in": Vector3(5.0, 0, -7.0),
		"office_door_out": Vector3(3.0, 0, -7.0), "fuse_box": Vector3(-17, 0, -20.9),
	}


# --- People ------------------------------------------------------------------------

func voice_info() -> Dictionary:
	return {
		"market_dev": {"who": "Dev, the night clerk: a laid-back, chatty young man who talks to himself while he stacks shelves", "kokoro": "am_michael", "speed": 1.0},
		"market_pruitt": {"who": "Mrs Pruitt, Augustus Hoard's rent collector: prim, sharp and penny-pinching, in her fifties", "kokoro": "af_sarah", "speed": 1.0},
	}


func add_people(p_run: JobRun) -> Array:
	var west := Vector3(-1, 0, 0)
	var east := Vector3(1, 0, 0)
	var north := Vector3(0, 0, -1)
	dev = MarketPerson.new()
	dev.setup("Dev", MARKET + "character-employee.glb", self, p_run, [
		{"at": "aisle_a", "face": west, "clip": "interact-right", "time": 22.0, "room": "aisle_west", "say": "Peas. More peas. Why is it always peas?"},
		{"at": "stock_shelf", "face": west, "clip": "pick-up", "time": 6.0, "room": "stock", "say": "Right. Beans."},
		{"at": "aisle_b", "face": east, "clip": "interact-right", "time": 22.0, "room": "aisle_west", "leave_dark": true},
		{"at": "till", "face": west, "time": 10.0, "room": "till", "say": "Nobody ever buys the pickled eggs."},
		{"at": "aisle_c", "face": east, "clip": "interact-left", "time": 20.0, "room": "aisle_east", "leave_dark": true, "say": "Who puts the soup in alphabetical order? Me. I do."},
		{"at": "stock_table", "face": north, "clip": "sit", "time": 25.0, "room": "stock", "say": "Office code's oh-four-one-two now. Who picks these?"},
		{"at": "bins", "face": north, "clip": "interact-right", "time": 12.0, "say": "Bins. Living the dream.", "do": "bins"},
		{"at": "stock_in", "time": 2.0},
	], "market_dev", {
		"mumble": "low", "answers_door": true, "accepts": ["staff"],
		"lines": {
			"curious": ["Hello? We're closed!", "Is someone there?", "Was that a rat?"],
			"seen": ["Hm? Who's that?"],
			"spotted": ["Hey! We're closed!", "Oi! Shoplifter!"],
			"others": ["What's going on?"],
			"lost": ["Where'd they go?"],
			"give_up": ["Probably a rat. Hope it's a rat.", "Just the freezers humming."],
			"catch": ["Gotcha! Out you go, we're closed."],
			"door": ["Delivery? At this hour?"],
			"door_nobody": ["Nobody. Again."],
			"wake": ["Wha...? Was I asleep on shift?"],
		},
		"extra_lines": [
			"Evening! Didn't know you were on tonight.",
			"Oh! The new starter? Come in, come in. Stock room's through there.",
			"Thank you for recycling. You're welcome, machine.",
		],
	})
	dev.position = points["aisle_a"]
	add_child(dev)
	pruitt = MarketPerson.new()
	pruitt.setup("Pruitt", "female-d", self, p_run, [
		{"at": "desk", "face": north, "clip": "sit", "time": 35.0, "room": "office", "say": "Twenty, forty, sixty... Mr Hoard wants every penny."},
		{"at": "monitor", "face": east, "time": 12.0, "room": "office", "say": "Camera two's fuzzy again. Cheap things.", "do": "check_cameras"},
		{"at": "desk", "face": north, "clip": "sit", "time": 25.0, "room": "office"},
		{"at": "till", "face": west, "time": 14.0, "room": "till", "say": "Short by fifty pence. Typical."},
		{"at": "desk", "face": north, "clip": "sit", "time": 30.0, "room": "office", "say": "The bakery's rent goes up again. Lovely."},
		{"at": "back_check", "face": north, "time": 8.0, "room": "stock", "leave_dark": true, "say": "Back door. Locked. Good.", "do": "lock_back_door"},
	], "market_pruitt", {
		"mumble": "high", "answers_alarm": true, "fixes_power": true, "accepts": ["staff"],
		"lines": {
			"curious": ["Dev? Is that you?", "Who's there?"],
			"seen": ["Who's that?"],
			"spotted": ["Thief! Stop right there!", "I knew it! A burglar!"],
			"others": ["Dev! What is going on?"],
			"lost": ["Where have they got to?"],
			"give_up": ["Hmph. Rats.", "Dev's been at the pickled eggs again."],
			"catch": ["Caught you! Mr Hoard will hear about this."],
			"power_out": ["Not again! That breaker!"],
			"power_fixed": ["There. And stay on."],
			"alarm": ["The alarm! Someone's on camera!"],
			"wake": ["Hm? I was only resting my eyes."],
		},
		"extra_lines": [
			"Who's that knocking?",
			"The till's short again? Honestly. I'll count it myself.",
			"Hm. Dev, if that's you, it isn't funny.",
			"Who switched the cameras off? Honestly.",
		],
	})
	pruitt.leave_to_closers = OFFICE_DOORS
	pruitt.position = points["desk"]
	add_child(pruitt)
	dev.said.connect(_on_said)
	return [dev, pruitt]


## A routine step's "do", when someone gets there.
func person_did(person: Person, what: String) -> void:
	match what:
		"bins":
			_record("dev_at_bins")
		"check_cameras":
			# She notices the cameras are off, and switches them back on.
			if not camera_switch.get_meta("on"):
				_flip_group(null, "cameras", "Switch off the cameras", "Switch the cameras back on", camera_switch)
				person.say("Who switched the cameras off? Honestly.")
		"lock_back_door":
			var d: HouseDoor = doors["front_door"]
			var p := get_tree().get_first_node_in_group("moth") as Node3D
			var in_way := p != null and p.global_position.distance_to(points["front_door_in"]) < 1.2
			if d.is_open and not in_way:
				d.person_close(person)
			if not d.is_open:
				d.locked = true
				d._update_text()


## Dev greets a colleague in the apron the first time he sees them.
func expects(person: Person, p: Moth) -> bool:
	var ok := super(person, p)
	if ok and person == dev and p.disguise == "staff" and not _greeted and person.global_position.distance_to(p.global_position) < 6.0:
		_greeted = true
		person.say("Evening! Didn't know you were on tonight.")
		_record("on_shift")
	return ok


## Dev at the deliveries door: the new starter in the apron gets let in.
func at_front_door(person: Person, p: Moth) -> bool:
	if person != dev or p.disguise != "staff":
		return false
	person.say("Oh! The new starter? Come in, come in. Stock room's through there.")
	_record("let_in_as_staff")
	person.wait_at("stock_table", 6.0)
	return true


func _on_said(person: Person, text: String) -> void:
	var p := get_tree().get_first_node_in_group("moth") as Node3D
	if p == null or p.global_position.distance_to(person.global_position) > 9.0:
		return
	if text.begins_with("Office code"):
		_record("heard:office_code")


# --- Every frame ---------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	super(delta)
	_door_closers(delta)
	_check_cameras()
	_knocking(delta)
	if not _bag_hooked:
		var p := get_tree().get_first_node_in_group("moth")
		if p:
			_bag_hooked = true
			p.bag_changed.connect(_on_bag_changed.bind(p))
	if _bottle_t > 0.0:
		_bottle_t -= delta
		if _bottle_t <= 0.0:
			_thanks.visible = false


## The office doors swing shut a while after they're opened, and lock.
func _door_closers(delta: float) -> void:
	for id in OFFICE_DOORS:
		var d: HouseDoor = doors[id]
		if not d.is_open:
			_open_t[id] = 0.0
			continue
		_open_t[id] += delta
		if _open_t[id] < CLOSER_TIME or _someone_near(Person._door_center(d), 1.4):
			continue
		d.person_close(null)
		_lock_office_door(id)
		_open_t[id] = 0.0


func _lock_office_door(id: String) -> void:
	var d: HouseDoor = doors[id]
	if d.is_open:
		return
	if id == "office_door":
		d.locked = not (office_pad.solved or power_off())
	else:
		d.locked = true
	d._update_text()


func _someone_near(at: Vector3, r: float) -> bool:
	at.y = 0.0
	for n in get_tree().get_nodes_in_group("people") + get_tree().get_nodes_in_group("moth"):
		var q: Vector3 = n.global_position
		q.y = 0.0
		if q.distance_to(at) < r:
			return true
	return false


## Each camera knocked out by a dart, and all three.
func _check_cameras() -> void:
	if JobRun.current == null:
		return
	var all := true
	for id in cams:
		var c: SecurityCamera = cams[id]
		if c.powered and c.switched_on and not c.is_working():
			_record("camera_darted:" + id)
		if not JobRun.current.has("camera_darted:" + id):
			all = false
	if all:
		_record("all_cameras_darted")


# --- The power -----------------------------------------------------------------------

## The office keypad's lock lets go with the power off, and holds again when
## it comes back (if the door's shut).
func set_power(on: bool) -> void:
	super(on)
	var d: HouseDoor = doors["office_door"]
	if not on:
		d.locked = false
		d._update_text()
	else:
		_lock_office_door("office_door")


# --- Knocking at the office door ---------------------------------------------------

func _knock_on_door(pic: PlayerInteractionComponent) -> void:
	var p: Node3D = pic.get_parent()
	Sfx.at(self, "kenney:beltHandle2", office_pad.global_position, -4.0, 0.7)
	StealthNoise.make(self, office_pad.global_position, 3.0, "voice", p)
	_record("knocked_office")
	if _knock != 0 or not areas["office"].has_point(pruitt.global_position):
		return
	if pruitt.state not in [Person.State.ROUTINE, Person.State.WAIT]:
		return
	pruitt.say("Who's that knocking?")
	pruitt.wait_at("office_door_in", 30.0)
	_knock = 1
	_knock_t = 0.0


func _knocking(delta: float) -> void:
	if _knock == 0:
		return
	_knock_t += delta
	if pruitt.state != Person.State.WAIT or _knock_t > 30.0:
		_knock = 0
		return
	var d: HouseDoor = doors["office_door"]
	if _knock == 1:
		if pruitt.global_position.distance_to(points["office_door_in"]) < 0.8:
			d.person_open(pruitt)
			_knock = 2
			_knock_t = 0.0
		return
	if _knock_t < 1.2:
		return
	var p := get_tree().get_first_node_in_group("moth") as Moth
	var at_door := p != null and p.global_position.distance_to(points["office_door_out"] + Vector3(0, 0.9, 0)) < 2.5
	if at_door and p.disguise == "staff" and not p.is_crouching:
		pruitt.say("The till's short again? Honestly. I'll count it myself.")
		_record("pruitt_to_till")
		pruitt.wait_at("till", 25.0)
		_knock = 0
	elif _knock_t > 4.0:
		pruitt.say("Hm. Dev, if that's you, it isn't funny.")
		d.person_close(pruitt)
		_lock_office_door("office_door")
		pruitt.wait_at("desk", 0.5)
		_knock = 0


func _press_exit(_pic: PlayerInteractionComponent, door_id: String) -> void:
	var d: HouseDoor = doors[door_id]
	Sfx.at(self, "kenney:metalClick", Person._door_center(d), -8.0, 1.3)
	if d.locked:
		d.locked = false
		d._update_text()
		Sfx.at(self, "lock_open", Person._door_center(d), -8.0)


# --- Things to use -----------------------------------------------------------------

func _on_shop_door_opened(by: Node) -> void:
	if by == null or not by.is_in_group("moth"):
		return
	var at: Vector3 = Person._door_center(doors["shop_door"]) + Vector3(0, 1.2, 0)
	Sfx.at(self, "shop_bell", at, -2.0)
	StealthNoise.make(self, at, 12.0, "door", by)
	_record("shop_bell")


func _ring_bell(pic: PlayerInteractionComponent) -> void:
	var at := Vector3(-0.3, 1.3, -12.1)
	Sfx.at(self, "doorbell", at, 0.0, 0.8)
	StealthNoise.make(self, at, 30.0, "bell", pic.get_parent())
	_record("doorbell_rung")


func _ring_till(pic: PlayerInteractionComponent) -> void:
	Sfx.at(self, "till_ding", till.global_position, -2.0)
	StealthNoise.make(self, till.global_position, 9.0, "knock", pic.get_parent())
	_record("rang_till")


func _melon_on_till(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if _melon_on or not player.take_item("melon"):
		return
	_melon_on = true
	var m := Kit.model(self, Kit.FOOD + "watermelon.glb", till.position + Vector3(0.1, 0.0, 0.25), 30.0, 0.8)
	m.name = "MelonOnTill"
	Sfx.at(self, "kenney:bookPlace1", till.global_position, -6.0, 0.6)
	_record("melon_on_till")
	_update_till(player)


func _on_bag_changed(player: Node) -> void:
	_update_till(player)
	_update_stand(player)


func _update_till(player: Node) -> void:
	var can: bool = not _melon_on and player.has_item("melon")
	till.set_action_text("interact2", "Put the melon on the till" if can else "")


func _press_bottle_machine(pic: PlayerInteractionComponent) -> void:
	if _bottle_t > 0.0:
		return
	_bottle_t = 3.0
	_thanks.visible = true
	Sfx.at(self, "bottle_machine", bottle_machine.global_position, 0.0)
	StealthNoise.make(self, bottle_machine.global_position, 13.0, "knock", pic.get_parent())
	_record("bottle_machine")


func _loose_cart(pos: Vector3, yaw: float) -> void:
	var cart := UsableBody.new()
	cart.name = "Cart_%d" % carts.size()
	cart.position = pos
	cart.rotation.y = deg_to_rad(yaw)
	var m: Node3D = Kit.scene(MARKET + "shopping-cart.glb").instantiate()
	m.scale = Vector3.ONE * MINI_SCALE
	cart.add_child(m)
	cart.add_box(Vector3(0, 0.4, 0), Vector3(0.6, 0.8, 0.95))
	cart.add_action("interact", "Push it back to the others", _stack_cart.bind(cart))
	add_child(cart)
	carts.append(cart)


func _stack_cart(pic: PlayerInteractionComponent, cart: UsableBody) -> void:
	if cart.get_meta("home", false):
		return
	cart.set_meta("home", true)
	var slot: Vector3 = _cart_slots[2 + _carts_home]
	_carts_home += 1
	Sfx.at(self, "cart_rattle", cart.global_position, -4.0)
	StealthNoise.make(self, cart.global_position, 6.0, "cart", pic.get_parent())
	cart.set_action_text("interact", "")
	var t := cart.create_tween()
	t.tween_property(cart, "position", slot, 0.8).set_trans(Tween.TRANS_SINE)
	t.parallel().tween_property(cart, "rotation:y", 0.0, 0.8)
	if _carts_home >= carts.size():
		_record("carts_stacked")


## A book-sized box to pick up (the cookbook, the rent money).
func _book(item: String, verb: String, color: Color, pos: Vector3, title: String) -> UsableBody:
	var b := UsableBody.new()
	b.name = "Pickup_" + item
	b.position = pos
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.26, 0.06 if title != "" else 0.14, 0.32 if title != "" else 0.2)
	bm.material = Kit.flat(color, 0.6)
	mi.mesh = bm
	mi.position = Vector3(0, bm.size.y * 0.5, 0)
	b.add_child(mi)
	b.add_box(mi.position, bm.size.max(Vector3(0.2, 0.15, 0.2)))
	b.add_action("interact", verb, _take.bind(item, "", b))
	add_child(b)
	return b


## The ledger, and the cookbook left in its place.
func _use_ledger(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if _treasure_model != null:
		_take_treasure(pic)
		_update_stand(player)
		return
	if not _cookbook_left and player.take_item("cookbook"):
		_cookbook_left = true
		var b := MeshInstance3D.new()
		b.name = "Cookbook"
		var bm := BoxMesh.new()
		bm.size = Vector3(0.26, 0.06, 0.32)
		bm.material = Kit.flat(Color(0.85, 0.3, 0.2), 0.6)
		b.mesh = bm
		b.position = Vector3(0, 0.03, 0)
		treasure_stand.add_child(b)
		_record("cookbook_on_desk")
		treasure_stand.set_action_text("interact", "")


func _update_stand(player: Node) -> void:
	if _treasure_model != null:
		return
	var can: bool = not _cookbook_left and player.has_item("cookbook")
	treasure_stand.set_action_text("interact", "Leave the cookbook" if can else "")


func return_treasure() -> void:
	super()
	if treasure_stand != null:
		treasure_stand.set_action_text("interact", "Take the rent ledger")


func _hide_in_freezer(pic: PlayerInteractionComponent, spot: HideSpot) -> void:
	spot._use(pic)
	_record("hid_in:freezer")


## The vent: unscrew the cover on the stock room side, then crawl through
## either way. The office side is screwed shut from the stock room's.
func _use_vent(pic: PlayerInteractionComponent, from_stock: bool) -> void:
	var player: Node3D = pic.get_parent()
	if from_stock and not _vent_open:
		_vent_open = true
		Sfx.at(self, "kenney:metalClick", Vector3(3.9, 1.7, -10), -6.0, 0.8)
		StealthNoise.make(self, Vector3(3.9, 1.7, -10), 2.5, "pry", player)
		UsableBody.hint(pic, "The cover's off. It's a tight squeeze.")
		get_node("VentStock").set_action_text("interact", "Crawl into the vent")
		_record("vent_open")
		return
	if not _vent_open:
		UsableBody.hint(pic, "Screwed shut from the other side.")
		return
	var to := Vector3(5.2, 0, -10) if from_stock else Vector3(3.4, 0.9, -10)
	player.global_position = to + Vector3(0, 0.9, 0)
	player.velocity = Vector3.ZERO
	Sfx.at(self, "vent_crawl", Vector3(4, 1.7, -10), -4.0)
	StealthNoise.make(self, to + Vector3(0, 0.5, 0), 6.0, "climb", player)
	_record("crawled_vent")


func _climb_ladder(pic: PlayerInteractionComponent) -> void:
	if not hatch.is_open:
		UsableBody.hint(pic, "The hatch at the top is shut.")
		return
	hatch.climb(pic.get_parent(), true)


func screenshot_views() -> Dictionary:
	return {
		"street": [Vector3(-6, 0, 13.5), 0.0, 0.0],
		"front": [Vector3(4, 0, 11), 20.0, 5.0],
		"window": [Vector3(-3, 0, 7.6), 0.0, -5.0],
		"shop": [Vector3(1, 0, 4.5), 10.0, -10.0],
		"aisles": [Vector3(-1.25, 0, 4.8), 0.0, -8.0],
		"till": [Vector3(3, 0, 1.5), -110.0, -15.0],
		"stock": [Vector3(2.5, 0, -5), 70.0, -10.0],
		"stock_back": [Vector3(-6, 0, -6), -130.0, -5.0],
		"freezer": [Vector3(-8, 0, -8.6), 20.0, -15.0],
		"office": [Vector3(5, 0, -5), -150.0, -15.0],
		"desk": [Vector3(5.5, 0, -9), -60.0, -25.0],
		"bay": [Vector3(-8, 0, -19), -130.0, 5.0],
		"alley": [Vector3(10, 0, -18), 90.0, 0.0],
		"fuse": [Vector3(-15, 0, -19), 40.0, -5.0],
		"passage": [Vector3(12, 0, 9.5), 8.0, 3.0],
		"roof": [Vector3(8, UP, 4), 37.0, -10.0],
		"hatch": [Vector3(-3.5, 0, -9.0), 0.0, 35.0],
	}
