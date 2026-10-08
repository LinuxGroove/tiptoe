class_name MapleCloseLevel
extends JobLevel
## The Pembertons' house on Maple Close: two storeys and a garage on a 2 m
## grid, with front and back gardens, a side alley and the street. X runs
## east, Z runs south towards the street, and each storey is 2.5 m.
##
## Ground floor: living room (west), hall with the stairs, dining room
## (east), kitchen and utility room at the back, garage to the east.
## Upstairs: the Pembertons' bedroom, the spare room, the bathroom and the
## study, where the trophy is.

const UP := JobLevel.STOREY
const ROOF := JobLevel.STOREY * 2.0

const CARPET_RED := Color(0.47, 0.3, 0.3)
const CARPET_BLUE := Color(0.33, 0.39, 0.52)
const WOOD := Color(0.56, 0.41, 0.28)
const TILE := Color(0.78, 0.79, 0.76)
const CONCRETE := Color(0.5, 0.5, 0.49)
const GRASS := Color(0.24, 0.4, 0.2)
const HEDGE := Color(0.16, 0.3, 0.15)
const ROAD := Color(0.2, 0.2, 0.22)
const FENCE := Color(0.62, 0.5, 0.36)
const ROOF_TILES := Color(0.36, 0.22, 0.2)

## Lights on when the night starts.
const LIGHTS_ON := ["living", "kitchen", "master", "porch", "tv", "street"]
## Lights that go off with the fuse box (all but the street lamp).
const HOUSE_CIRCUIT := ["living", "hall", "kitchen", "dining", "utility", "garage",
	"master", "spare", "bathroom", "landing", "study", "porch", "tv"]

const SHOPPING_LIST := """Milk
Eggs (big ones)
Dog food - Biscuit's the chicken one
Bulb for the porch light
Cupcakes for Maggie's book club

TED - stop leaving the spare key under the planter by the front door!"""

const PIZZA_FLYER := """PEPPI'S PIZZA
Friday nights, we come to you!

Pembertons, 12 Maple Close:
the usual, about ten o'clock.
Ring the bell, Ted always answers."""

const NEIGHBOR_NOTE := """Ted,
Your garage fuse box tripped again and plunged the whole house into darkness. Third time this month!
The main breaker's on the wall by your workbench. Flip it and everything goes off.
Get it looked at.
- Dave, number 14"""

var trophy_stand: UsableBody
var _trophy: Node3D
var _cupcake_left := false
var _breaker_off := false
var _lights_before := {}


func build() -> void:
	_grounds()
	_ground_floor()
	_upstairs()
	_garage()
	_roof()
	_furnish()
	_lamps()
	_things()
	_marks()
	house_boxes.append(AABB(Vector3(-6, -0.5, -5), Vector3(12, ROOF + 0.5, 10)))
	indoor_boxes.append(AABB(Vector3(6, -0.5, -5), Vector3(6, UP + 0.5, 6)))
	areas["garage"] = indoor_boxes[0]
	for room in lights:
		set_lights(room, room in LIGHTS_ON)


func _grounds() -> void:
	# Grass from the back hedge to the pavement, then the road.
	Kit.block(self, Vector3(1, -0.06, -2.75), Vector3(31, 0.1, 27.5), "grass", Kit.flat(GRASS))
	Kit.block(self, Vector3(1, -0.04, 12), Vector3(31, 0.08, 2), "concrete", Kit.flat(CONCRETE))
	Kit.block(self, Vector3(1, -0.06, 17), Vector3(31, 0.1, 8), "concrete", Kit.flat(ROAD))
	# The front path and the driveway.
	Kit.block(self, Vector3(-1, -0.035, 8), Vector3(1.4, 0.07, 6), "concrete", Kit.flat(CONCRETE))
	Kit.block(self, Vector3(10, -0.035, 6), Vector3(4, 0.07, 10), "concrete", Kit.flat(CONCRETE))
	# Hedges all round (too tall to climb), with the road's far side.
	var hedge := Kit.flat(HEDGE)
	Kit.block(self, Vector3(-15, 1.3, 2), Vector3(1, 2.6, 37), "", hedge)
	Kit.block(self, Vector3(17, 1.3, 2), Vector3(1, 2.6, 37), "", hedge)
	Kit.block(self, Vector3(1, 1.3, -17), Vector3(33, 2.6, 1), "", hedge)
	Kit.block(self, Vector3(1, 1.3, 21), Vector3(33, 2.6, 1), "", hedge)
	# Front fence, with gaps for the path and the driveway.
	var fence := Kit.flat(Color(0.9, 0.9, 0.86))
	Kit.block(self, Vector3(-8.25, 0.4, 11), Vector3(12.5, 0.8, 0.08), "", fence)
	Kit.block(self, Vector3(3.75, 0.4, 11), Vector3(7.5, 0.8, 0.08), "", fence)
	Kit.block(self, Vector3(14.25, 0.4, 11), Vector3(4.5, 0.8, 0.08), "", fence)
	# The back garden's fence to the alley, and the alley gate (climbable).
	var wood := Kit.flat(FENCE)
	Kit.block(self, Vector3(12, 0.7, -11), Vector3(0.1, 1.4, 12), "", wood)
	Kit.block(self, Vector3(14.5, 0.7, 1.05), Vector3(5, 1.4, 0.1), "", wood)
	# Trees.
	for t in [Vector3(-11, 0, -9), Vector3(-12, 0, 7), Vector3(6, 0, -12), Vector3(-8, 0, -14), Vector3(5, 0, 9)]:
		var tree := Kit.boxed(self, Kit.SUBURBAN + "tree-large.glb", t, randf() * 360.0, 6.0)
		# Only the trunk blocks.
		var cs: CollisionShape3D = tree.get_child(1)
		cs.shape.size = Vector3(0.4, 4.0, 0.4)
		cs.position = Vector3(0, 2.0, 0)


func _ground_floor() -> void:
	floor_rect(0, -6, -1, -2, 5, "carpet", CARPET_RED, false)
	floor_rect(0, -2, -1, 2, 5, "wood", WOOD, false)
	floor_rect(0, 2, -1, 6, 5, "wood", WOOD, false)
	floor_rect(0, -6, -5, 2, -1, "tile", TILE, false)
	floor_rect(0, 2, -5, 6, -1, "tile", TILE, false)
	# Outside walls.
	line(0, Vector2(-6, 5), Vector2(1, 0), "wwDWww", [
		{"id": "front_door", "into": Vector2(-1, 3), "locked": true, "key": "spare_key", "pick": 8.0, "outside": true}])
	line(0, Vector2(-6, -5), Vector2(1, 0), "WDwWWw", [
		{"id": "back_door", "into": Vector2(-3, -3), "outside": true}])
	line(0, Vector2(-6, -5), Vector2(0, 1), "WowWw", ["kitchen_window"])
	line(0, Vector2(6, -5), Vector2(0, 1), "DWWww", [{"id": "utility_garage", "into": Vector2(4, -4), "outside": true}])
	# Inside walls.
	line(0, Vector2(-2, -1), Vector2(0, 1), "WdW")
	line(0, Vector2(2, -1), Vector2(0, 1), "WWD", [{"id": "dining_door", "into": Vector2(4, 4)}])
	line(0, Vector2(-6, -1), Vector2(1, 0), "WddWWW")
	line(0, Vector2(2, -5), Vector2(0, 1), "DW", [{"id": "utility_door", "into": Vector2(4, -4)}])
	# The stairs climb north from the hall to the landing.
	Kit.model(self, Kit.BUILDING + "stairs-closed.glb", Vector3(1.35, 0, 1), 180.0)
	var stairs := StaticBody3D.new()
	stairs.collision_layer = Kit.LAYER_WORLD
	stairs.collision_mask = 0
	var cs := CollisionShape3D.new()
	var wedge := ConvexPolygonShape3D.new()
	var pts := PackedVector3Array()
	for x in [0.7, 2.0]:
		pts.append_array([Vector3(x, 0, 3), Vector3(x, 0, -1), Vector3(x, UP, -1), Vector3(x, UP, -0.5), Vector3(x, 0.15, 3)])
	wedge.points = pts
	cs.shape = wedge
	stairs.add_child(cs)
	add_child(stairs)
	Kit.add_surface(stairs, "wood")
	stairs.add_to_group(Kit.NAV_GROUP)


func _upstairs() -> void:
	floor_rect(UP, -6, -5, -2, 1, "carpet", CARPET_BLUE)
	floor_rect(UP, -6, 1, -2, 5, "carpet", CARPET_BLUE)
	floor_rect(UP, -2, -5, 2, -3, "tile", TILE)
	floor_rect(UP, -2, -3, 0, 5, "wood", WOOD)
	floor_rect(UP, 0, -3, 2, -1, "wood", WOOD)
	floor_rect(UP, 0, 3, 2, 5, "wood", WOOD)
	floor_rect(UP, 2, -5, 6, 5, "wood", WOOD)
	line(UP, Vector2(-6, 5), Vector2(1, 0), "wwwWww")
	line(UP, Vector2(-6, -5), Vector2(1, 0), "oWwWWw", ["master_window"])
	line(UP, Vector2(-6, -5), Vector2(0, 1), "WwWwW")
	line(UP, Vector2(6, -5), Vector2(0, 1), "pWWwW", ["study_window"])
	line(UP, Vector2(-2, -5), Vector2(0, 1), "WDWDW", [
		{"id": "master_door", "into": Vector2(-4, -2)},
		{"id": "spare_door", "into": Vector2(-4, 2)}])
	line(UP, Vector2(-2, -3), Vector2(1, 0), "DW", [{"id": "bath_door", "into": Vector2(-1, -4)}])
	line(UP, Vector2(-6, 1), Vector2(1, 0), "WW")
	line(UP, Vector2(2, -5), Vector2(0, 1), "WDWWW", [{"id": "study_door", "into": Vector2(4, -2)}])
	# Railings round the stairwell.
	line(UP, Vector2(0, -1), Vector2(0, 1), "--")
	line(UP, Vector2(0, 3), Vector2(1, 0), "-")


func _garage() -> void:
	floor_rect(0, 6, -5, 12, 1, "concrete", CONCRETE, false)
	line(0, Vector2(12, -5), Vector2(0, 1), "WDW", [
		{"id": "garage_side", "into": Vector2(9, -2), "locked": true, "pick": 4.0}])
	line(0, Vector2(6, -5), Vector2(1, 0), "WWW")
	line(0, Vector2(6, 1), Vector2(1, 0), "W")
	# The up-and-over door, shut.
	Kit.block(self, Vector3(10, UP * 0.5, 1), Vector3(4, UP, 0.12), "", Kit.flat(Color(0.75, 0.76, 0.78)))
	# A flat roof you can walk on, up to the study window.
	floor_rect(UP, 6, -5, 12, 1, "concrete", Color(0.32, 0.32, 0.34))


func _roof() -> void:
	floor_rect(ROOF, -6, -5, 6, 5, "", ROOF_TILES)
	var roof := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(10.6, 2.6, 12.6)
	pm.material = Kit.flat(ROOF_TILES)
	roof.mesh = pm
	roof.position = Vector3(0, ROOF + 1.3, 0)
	roof.rotation.y = PI * 0.5
	add_child(roof)


func _furnish() -> void:
	# Living room: Ted's sofa faces the telly on the west wall.
	Kit.furniture(self, "cabinetTelevision", Vector3(-5.7, 0, 2), 90)
	Kit.furniture(self, "televisionModern", Vector3(-5.7, 0.62, 2), 90, false)
	Kit.furniture(self, "loungeSofa", Vector3(-3.0, 0, 2), -90)
	Kit.furniture(self, "tableCoffee", Vector3(-4.3, 0, 2), 90)
	Kit.furniture(self, "rugRectangle", Vector3(-4.2, 0, 2), 90, false)
	Kit.furniture(self, "lampRoundFloor", Vector3(-2.5, 0, 4.4), 0)
	Kit.furniture(self, "bookcaseOpen", Vector3(-5.6, 0, -0.5), 90)
	# Hall.
	Kit.furniture(self, "coatRackStanding", Vector3(0.2, 0, 4.4), 0)
	Kit.furniture(self, "rugDoormat", Vector3(-1, 0, 4.4), 0, false)
	Kit.furniture(self, "sideTable", Vector3(-1.6, 0, 0.5), 90)
	# Dining room.
	Kit.furniture(self, "table", Vector3(4, 0, 2), 0)
	for c in [Vector3(3.5, 0, 1.2), Vector3(4.5, 0, 1.2)]:
		Kit.furniture(self, "chair", c, 0)
	for c in [Vector3(3.5, 0, 2.8), Vector3(4.5, 0, 2.8)]:
		Kit.furniture(self, "chair", c, 180)
	Kit.furniture(self, "pottedPlant", Vector3(5.5, 0, -0.5), 0)
	# Kitchen: counters along the back wall, the sink under the window.
	Kit.furniture(self, "kitchenFridge", Vector3(1.5, 0, -4.6), 0)
	Kit.furniture(self, "kitchenCabinet", Vector3(0.6, 0, -4.55), 0)
	Kit.furniture(self, "kitchenSink", Vector3(-0.3, 0, -4.55), 0)
	Kit.furniture(self, "kitchenCabinet", Vector3(-1.15, 0, -4.55), 0)
	Kit.furniture(self, "kitchenStove", Vector3(-5.55, 0, -4.1), 90)
	Kit.furniture(self, "kitchenCabinet", Vector3(-5.55, 0, -3.25), 90)
	Kit.furniture(self, "table", Vector3(-2.6, 0, -2.6), 90)
	for c in [Vector3(-3.4, 0, -2.2), Vector3(-3.4, 0, -3.0)]:
		Kit.furniture(self, "chair", c, 90)
	for c in [Vector3(-1.8, 0, -2.2), Vector3(-1.8, 0, -3.0)]:
		Kit.furniture(self, "chair", c, -90)
	Kit.furniture(self, "trashcan", Vector3(0.6, 0, -1.4), 0)
	# Utility room.
	Kit.furniture(self, "washer", Vector3(2.5, 0, -1.5), 90)
	Kit.furniture(self, "dryer", Vector3(2.5, 0, -2.4), 90)
	Kit.furniture(self, "cardboardBoxClosed", Vector3(5.4, 0, -1.5), 20)
	# Bedroom: the bed's head against the west wall.
	Kit.furniture(self, "bedDouble", Vector3(-4.85, UP, -2.0), 90)
	Kit.furniture(self, "sideTable", Vector3(-5.6, UP, -0.3), 90)
	Kit.furniture(self, "bookcaseClosedWide", Vector3(-2.5, UP, -4.4), -90)
	Kit.furniture(self, "rugRounded", Vector3(-3.4, UP, -2), 0, false)
	# Spare room, full of boxes.
	Kit.furniture(self, "bedSingle", Vector3(-5.3, UP, 3.6), 90)
	for b in [Vector3(-2.7, UP, 4.3), Vector3(-3.3, UP, 4.4), Vector3(-2.6, UP, 1.6)]:
		Kit.furniture(self, "cardboardBoxClosed", b, randf() * 40.0)
	# Bathroom.
	Kit.furniture(self, "bathtub", Vector3(0.6, UP, -4.4), 0)
	Kit.furniture(self, "toilet", Vector3(-1.6, UP, -4.5), 0)
	Kit.furniture(self, "bathroomSink", Vector3(-0.5, UP + 0.8, -4.7), 0)
	# Study: desk, shelves, and the trophy on its stand.
	Kit.furniture(self, "desk", Vector3(4, UP, -4.4), 0)
	Kit.furniture(self, "chairDesk", Vector3(4, UP, -3.6), 180)
	Kit.furniture(self, "bookcaseOpen", Vector3(2.5, UP, 1.5), 90)
	Kit.furniture(self, "bookcaseOpen", Vector3(2.5, UP, 2.5), 90)
	Kit.furniture(self, "loungeChair", Vector3(4.5, UP, 3.8), 200)
	# Garage.
	Kit.furniture(self, "desk", Vector3(9, 0, -4.5), 0)
	Kit.block(self, Vector3(9.5, 0.6, -1.5), Vector3(1.8, 1.2, 3.8), "", Kit.flat(Color(0.3, 0.45, 0.6)))
	# Outside: the shed, compost bin and wheelie bin make the climbs.
	Kit.block(self, Vector3(-5, 1.05, -6.2), Vector3(2, 2.1, 2), "wood", Kit.flat(FENCE))
	Kit.block(self, Vector3(-3.3, 0.5, -6.0), Vector3(0.8, 1.0, 0.8), "wood", Kit.flat(Color(0.25, 0.3, 0.22)))
	Kit.block(self, Vector3(12.55, 0.55, -4.2), Vector3(0.7, 1.1, 0.8), "concrete", Kit.flat(Color(0.2, 0.35, 0.25)))
	Kit.boxed(self, Kit.SUBURBAN + "planter.glb", Vector3(-3.0, 0, 5.9), 0, 4.0)


func _lamps() -> void:
	lamp("living", Vector3(-4, UP, 2))
	lamp("hall", Vector3(-0.6, UP, 2.5))
	lamp("kitchen", Vector3(-2, UP, -3))
	lamp("dining", Vector3(4, UP, 2))
	lamp("utility", Vector3(4, UP, -3), true, 1.0, 4.5)
	lamp("garage", Vector3(9, UP, -2), true, 1.0, 6.0, Color(0.9, 0.95, 1.0))
	lamp("master", Vector3(-4, ROOF, -2))
	lamp("spare", Vector3(-4, ROOF, 3))
	lamp("bathroom", Vector3(0, ROOF, -4), true, 1.0, 4.0)
	lamp("landing", Vector3(-1, ROOF, 0.5))
	lamp("study", Vector3(4, ROOF, 0))
	# The telly's glow.
	var tv := OmniLight3D.new()
	tv.position = Vector3(-5.2, 1.1, 2)
	tv.light_color = Color(0.5, 0.65, 1.0)
	tv.omni_range = 4.0
	tv.light_energy = 0.8
	tv.add_to_group("stealth_lights")
	add_child(tv)
	lights["tv"] = [tv]
	# The porch light, and the street lamp.
	Kit.model(self, Kit.FURNITURE + "lampWall.glb", Vector3(0.45, 2.1, 5.12), 0, Kit.FURNITURE_SCALE)
	var porch := OmniLight3D.new()
	porch.position = Vector3(0.45, 2.1, 5.5)
	porch.light_color = Color(1.0, 0.85, 0.6)
	porch.omni_range = 6.0
	porch.light_energy = 1.4
	porch.shadow_enabled = true
	porch.add_to_group("stealth_lights")
	add_child(porch)
	lights["porch"] = [porch]
	Kit.block(self, Vector3(4, 2.0, 12.4), Vector3(0.15, 4.0, 0.15), "", Kit.flat(Color(0.2, 0.2, 0.2)), false)
	var street := SpotLight3D.new()
	street.position = Vector3(4, 4.0, 12.4)
	street.rotation.x = -PI * 0.5
	street.light_color = Color(1.0, 0.8, 0.5)
	street.spot_range = 9.0
	street.spot_angle = 60.0
	street.light_energy = 2.0
	street.shadow_enabled = true
	street.add_to_group("stealth_lights")
	add_child(street)
	lights["street"] = [street]
	# Switches, just inside the doorways.
	light_switch(["hall", "porch"], Vector3(-1.9, 1.3, 4.6), Vector3(1, 0, 0), "")
	light_switch(["living", "tv"], Vector3(-2.1, 1.3, 0.75), Vector3(-1, 0, 0))
	light_switch(["kitchen"], Vector3(-0.3, 1.3, -1.1), Vector3(0, 0, -1))
	light_switch(["dining"], Vector3(2.1, 1.3, 4.6), Vector3(1, 0, 0))
	light_switch(["utility"], Vector3(2.1, 1.3, -2.8), Vector3(1, 0, 0))
	light_switch(["garage"], Vector3(6.1, 1.3, -2.8), Vector3(1, 0, 0))
	light_switch(["master"], Vector3(-2.1, UP + 1.3, -0.8), Vector3(-1, 0, 0))
	light_switch(["spare"], Vector3(-2.1, UP + 1.3, 3.2), Vector3(-1, 0, 0))
	light_switch(["bathroom"], Vector3(0.2, UP + 1.3, -3.1), Vector3(0, 0, -1))
	light_switch(["landing"], Vector3(-1.9, UP + 1.3, -0.8), Vector3(1, 0, 0))
	light_switch(["study"], Vector3(2.1, UP + 1.3, -0.8), Vector3(1, 0, 0))


func _things() -> void:
	# The spare key under the planter.
	var planter := UsableBody.new()
	planter.name = "PlanterKey"
	planter.position = Vector3(-3.0, 0.35, 5.9)
	planter.add_box(Vector3.ZERO, Vector3(1.7, 0.8, 1.3))
	planter.collision_layer = Kit.LAYER_INTERACT
	planter.add_action("interact", "Look under the planter", _look_under_planter.bind(planter))
	add_child(planter)
	# The doorbell and the porch light's bulb.
	var bell := UsableBody.new()
	bell.name = "Doorbell"
	bell.position = Vector3(0.3, 1.3, 5.1)
	bell.add_child(Kit.scene(Kit.PROPS + "doorbell.glb").instantiate())
	bell.add_box(Vector3(0, 0, 0.03), Vector3(0.15, 0.2, 0.08))
	bell.add_action("interact", "Ring the bell", _ring_bell)
	add_child(bell)
	var bulb := UsableBody.new()
	bulb.name = "PorchBulb"
	bulb.position = Vector3(0.45, 2.1, 5.3)
	bulb.add_box(Vector3.ZERO, Vector3(0.4, 0.4, 0.4))
	bulb.collision_layer = Kit.LAYER_INTERACT
	bulb.add_action("interact", "Unscrew the bulb", _unscrew_bulb)
	add_child(bulb)
	# Things to read.
	note("shopping_list", "Shopping list", SHOPPING_LIST, Vector3(1.5, 1.2, -4.13), 0)
	note("pizza_flyer", "A flyer in the post box", PIZZA_FLYER, Vector3(-3.2, 1.08, 11.4), 0, Vector3(0.22, 0.02, 0.3))
	Kit.block(self, Vector3(-3.2, 0.5, 11.4), Vector3(0.12, 1.0, 0.12), "", Kit.flat(Color(0.3, 0.25, 0.2)), false)
	Kit.block(self, Vector3(-3.2, 1.0, 11.4), Vector3(0.3, 0.12, 0.4), "", Kit.flat(Color(0.2, 0.3, 0.45)), false)
	note("neighbor_note", "A note pinned to the gate", NEIGHBOR_NOTE, Vector3(14.5, 1.0, 1.12), 0)
	# The pizza scooter by the kerb, with a spare box and the delivery cap.
	Kit.block(self, Vector3(-9, 0.45, 14), Vector3(0.6, 0.9, 1.6), "", Kit.flat(Color(0.75, 0.15, 0.12)), false)
	pickup("pizza", "Take a pizza", Kit.FOOD + "pizza-box.glb", Vector3(-9, 0.92, 14.4), 0.45)
	var cap := pickup("pizza_cap", "Put on the cap", Kit.PROTOTYPE + "hat-cap.glb", Vector3(-9, 0.92, 13.7), 1.0, 0, "got_pizza_cap")
	cap.action("interact").on_use = _wear_cap.bind(cap)
	# The trophy, and a cupcake on the kitchen table to leave in its place.
	trophy_stand = UsableBody.new()
	trophy_stand.name = "TrophyStand"
	trophy_stand.position = Vector3(5.4, UP, 0)
	Kit.furniture(self, "sideTable", Vector3(5.5, UP, 0), 90)
	_trophy = Kit.scene("res://assets/kenney/mini-arena/trophy.glb").instantiate()
	_trophy.scale = Vector3.ONE * 0.7
	_trophy.position = Vector3(0, 0.77, 0)
	trophy_stand.add_child(_trophy)
	trophy_stand.add_box(Vector3(0, 0.95, 0), Vector3(0.45, 0.4, 0.4))
	trophy_stand.add_action("interact", "Take the trophy", _take_trophy)
	add_child(trophy_stand)
	pickup("cupcake", "Take a cupcake", Kit.FOOD + "cupcake.glb", Vector3(-2.6, 0.66, -2.3), 0.35)
	# The fuse box in the garage.
	var fuse := UsableBody.new()
	fuse.name = "FuseBox"
	fuse.position = Vector3(10.5, 1.2, -4.9)
	fuse.add_child(Kit.scene(Kit.PROPS + "fuse_box.glb").instantiate())
	fuse.add_box(Vector3(0, 0.25, 0.08), Vector3(0.4, 0.5, 0.16))
	fuse.add_action("interact", "Flip the main breaker", _flip_breaker)
	add_child(fuse)


func _marks() -> void:
	add_start("street", Vector3(-4, 0, 16), 0)
	add_start("garden", Vector3(-10, 0, -14), 160)
	add_start("alley", Vector3(14.5, 0, -8), 180)
	points = {
		"sofa": Vector3(-3.3, 0, 2), "tv": Vector3(-4.8, 0, 2), "living": Vector3(-4, 0, 0.5),
		"hall": Vector3(-0.6, 0, 2), "front_door_in": Vector3(-1, 0, 4.1), "front_step": Vector3(-1, 0, 6),
		"kitchen": Vector3(-1.5, 0, -2), "fridge": Vector3(1.4, 0, -3.8), "back_door_in": Vector3(-3, 0, -4),
		"dog_bed": Vector3(-4.6, 0, -4.3), "dining": Vector3(4, 0, 0.3), "utility": Vector3(4, 0, -3),
		"garage": Vector3(8, 0, -3.5), "fuse_box": Vector3(10.5, 0, -4.2),
		"stairs_foot": Vector3(1.35, 0, 3.6), "landing": Vector3(1, UP, -2),
		"corridor": Vector3(-1, UP, 1), "bedroom": Vector3(-3.4, UP, -2.2), "bed": Vector3(-3.7, UP, -1),
		"bathroom": Vector3(-0.6, UP, -4.1), "spare": Vector3(-4, UP, 2.8), "study": Vector3(4, UP, 0),
		"garden": Vector3(-6, 0, -10), "front_yard": Vector3(-6, 0, 8),
	}


func _look_under_planter(pic: PlayerInteractionComponent, planter: UsableBody) -> void:
	pic.get_parent().add_item("spare_key")
	UsableBody.hint(pic, "A spare key. Of course.")
	_record("found_key")
	planter.queue_free()


func _ring_bell(pic: PlayerInteractionComponent) -> void:
	var at := Vector3(0.3, 1.3, 5.1)
	Sfx.at(self, "doorbell", at, 0.0)
	StealthNoise.make(self, at, 30.0, "bell", pic.get_parent())
	_record("doorbell_rung")


func _unscrew_bulb(pic: PlayerInteractionComponent) -> void:
	if not lights_on("porch"):
		UsableBody.hint(pic, "It's already dark.")
		return
	set_lights("porch", false)
	Sfx.at(self, "kenney:metalClick", Vector3(0.45, 2.1, 5.3), -12.0, 1.4)
	_record("porch_light_off")


func _wear_cap(pic: PlayerInteractionComponent, cap: UsableBody) -> void:
	var player: Node = pic.get_parent()
	player.set_disguise("pizza")
	Sfx.at(self, "kenney:cloth2", cap.global_position, -8.0)
	UsableBody.hint(pic, "You look like you deliver pizza.")
	_record("got_pizza_cap")
	_record("wore_pizza_cap")
	cap.queue_free()


func _take_trophy(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if _trophy == null:
		if player.take_item("cupcake"):
			var cake: Node3D = Kit.scene(Kit.FOOD + "cupcake.glb").instantiate()
			cake.scale = Vector3.ONE * 0.35
			cake.position = Vector3(0, 0.77, 0)
			trophy_stand.add_child(cake)
			_cupcake_left = true
			_record("cupcake_on_stand")
			trophy_stand.set_action_text("interact", "")
		return
	player.add_item("trophy")
	_trophy.queue_free()
	_trophy = null
	Sfx.at(self, "caper_done", trophy_stand.global_position, -6.0)
	_record("took_treasure")
	player.bag_changed.connect(_update_stand.bind(player))
	_update_stand(player)


## Once the trophy's gone, the stand offers to take the cupcake.
func _update_stand(player: Node) -> void:
	var can_leave: bool = not _cupcake_left and player.has_item("cupcake")
	trophy_stand.set_action_text("interact", "Leave the cupcake" if can_leave else "")


func _flip_breaker(pic: PlayerInteractionComponent) -> void:
	_breaker_off = not _breaker_off
	Sfx.at(self, "breaker_off" if _breaker_off else "breaker_on", Vector3(10.5, 1.4, -4.9), -2.0)
	StealthNoise.make(self, Vector3(10.5, 1.4, -4.9), 3.0, "breaker", pic.get_parent())
	if _breaker_off:
		for r in HOUSE_CIRCUIT:
			_lights_before[r] = lights_on(r)
			set_lights(r, false)
		_record("lights_out")
		_record("porch_light_off")
	else:
		for r in HOUSE_CIRCUIT:
			set_lights(r, _lights_before.get(r, false))


## Is the power off at the fuse box?
func power_off() -> bool:
	return _breaker_off
