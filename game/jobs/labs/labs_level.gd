class_name LabsLevel
extends JobLevel
## Hoard Labs after hours: a one-storey lab block with a tall test hangar
## and a loading bay, on a 2 m grid. X runs east, Z runs south towards the
## car park, and the roof is at 2.5 m (the hangar's at 5 m).
##
## South row: the security office (west), the lobby, the break room and
## Hoard's office. A corridor runs east to the hangar, with laser gates in
## front of the hangar door. North row: Dr Fenwick's chemistry lab, the
## clean room, the server room and the workshop, all behind sliding doors.
## Behind them a crawl duct runs from the roof hatch to the hangar, with a
## vent into every lab. The hangar has a catwalk under its high windows, and
## the rocket stands in the test cell at the back, behind more lasers and a
## camera. Goods in (the loading bay) is south of the hangar.
##
## Routes to the rocket:
## - Tea break: read the night rota on the reception desk, wait for Officer
##   Marsh's tea break, switch off the lasers (and cameras) in the security
##   office, take the spare hangar card and swipe into the hangar.
## - Dr Fenwick's coat: her journal (in the break room, through the open
##   window) says her spare lab coat hangs there with her lab card in the
##   pocket. In the coat the guards and cameras let you walk the corridor;
##   swipe into the workshop, crawl the loose vent to the hangar, dart the
##   camera over the rocket and crouch under the lasers.
## - Sputnik year: overhear Dr Fenwick muttering the server room code by its
##   door, open the server room (its hum drowns your steps), release the
##   hangar door on the door controller and time the blinking lasers.
## - The roof: from the roof hatch (or up the pallets in the yard), drop down
##   the shaft into the duct and crawl to the hangar vent; or walk across
##   the roof to the hangar's stuck-open high window, onto the catwalk and
##   down the stairs, minding Rook's rounds.
## - The breaker: pick the goods-in door, trip the main breaker, and run for
##   the rocket while lights, cameras and lasers are dead and Briggs comes to
##   fix it.
## - Nap time: snooze-dart Briggs (or Rook) and borrow the hangar card from
##   their belt; or snooze Officer Marsh so nobody watches the cameras.
## - The confetti cannon: fire it in the workshop to pull everyone that way.

const UP := JobLevel.STOREY
const HANGAR_TOP := JobLevel.STOREY * 2.0

const SS := "res://assets/kenney/space-station-kit/"
const SPACE := "res://assets/kenney/space-kit/"
const MSK := "res://assets/kenney/modular-space-kit/"
const CARS := "res://assets/kenney/car-kit/"
const SOLDIER := "res://assets/kenney/mini-arena/character-soldier.glb"
const LAB_DOOR := "door-rotate-square-d.glb"
## Space Station Kit pieces are modelled small.
const SS_SCALE := 1.6
const ROCKET_SCALE := 0.42

const LAB_FLOOR := Color(0.78, 0.8, 0.84)
const CORRIDOR_FLOOR := Color(0.55, 0.58, 0.66)
const CARPET := Color(0.32, 0.35, 0.44)
const HOARD_CARPET := Color(0.45, 0.16, 0.18)
const CONCRETE := Color(0.5, 0.5, 0.5)
const ASPHALT := Color(0.17, 0.17, 0.19)
const PAVEMENT := Color(0.46, 0.46, 0.47)
const GRASS := Color(0.22, 0.36, 0.2)
const ROOF := Color(0.3, 0.31, 0.34)
const METAL := Color(0.36, 0.38, 0.44)
const DARK := Color(0.12, 0.13, 0.15)
const WOOD := Color(0.55, 0.4, 0.26)
const SHUTTER := Color(0.62, 0.64, 0.68)

## Lights on when the night starts.
const LIGHTS_ON := ["lobby", "office", "corridor", "chem", "cell", "hangar", "entrance", "yard", "car_park"]
## Lights on the building's breaker (the car park's lamps are the street's).
const CIRCUIT := ["lobby", "office", "break", "hoard", "corridor", "chem", "clean", "server",
	"workshop", "hangar", "cell", "bay", "entrance", "yard"]
## Doors that slide (and so count for the hands-off caper).
const SLIDING := ["entrance", "chem_door", "clean_door", "server_door", "workshop_door", "hangar_door", "bay_hangar"]
const SERVER_CODE := "1957"
## The roof hatch's shaft, down into the duct: x, z of its corners.
const SHAFT := Rect2(-17.8, -9.85, 1.8, 1.7)

const CODE_LINE := "One, nine, five, seven. Sputnik year. Server room. Don't forget, Lily."
const BREAK_LINE := "Tea time. The cameras can watch themselves for five minutes."
const RESET_LINE := "Who's been fiddling with my switches?"
const CAMERA_LINE := "Got you on camera three! Briggs! Rook!"
const COFFEE_LINE := "Ooh, someone made coffee. Don't mind if I do."

const NIGHT_ROTA := """NIGHT ROTA - HOARD LABS

Security office: Officer Marsh (monitors)
Rounds inside: Briggs
Rounds outside and goods in: Rook

Officer Marsh takes her tea in the break room every few minutes, regular as clockwork. Nobody touches her mug.

The spare hangar card lives in the key cabinet in the security office. It is NOT for borrowing, Briggs."""

const FENWICK_JOURNAL := """Lab journal - Dr L. Fenwick

Tuesday. Mr Hoard brought in the Kettleford school's model rocket. "Confiscated for safety," he says, and we're to "improve" it. It won the county science fair. It doesn't need improving.

Wednesday. Left my spare lab coat on the rack in here again. My lab card's in the pocket, which is where that went.

Thursday. The vent cover in the workshop is loose. The ducts run behind every lab and straight into the hangar. Must tell Maintenance. Must not tell Mr Hoard.

Friday. New code on the server room. I keep saying it out loud so I don't forget it. Very secure, Lily."""

const HOARD_LETTER := """Dear Head Teacher,

Thank you for your pupils' entry to the county science fair. I have confiscated their rocket, for safety. Rockets are dangerous in the wrong hands. In the right hands (mine) they are a business opportunity.

Hoard Labs will launch the Hoard Rocket next spring. Your pupils are welcome to buy one.

Yours, with great foresight,
Augustus Hoard"""

const MAINTENANCE_LOG := """MAINTENANCE LOG - GOODS IN

- Roof hatch over the lab ducts: the lid doesn't lock. The duct runs behind all four labs and into the hangar.
- Hangar high window by the catwalk: stuck open. Pigeons in again.
- Main breaker for the whole building: on the wall in here. If it trips, Briggs knows how to reset it.
- Lasers in the corridor blink while they warm up. They've been warming up since March."""

const IT_MEMO := """IT MEMO

The hangar door can be released from the door controller in the server room (big red button, you can't miss it).

Please stop releasing it to save swiping your card, Briggs. That's what the card is for."""

const FIREWORKS_NOTE := """CONFISCATED
Kettleford Primary School, Bonfire Night.
For safety.
- A.H."""

const CANNON_CARD := """PATENT PENDING
The Hoard Celebration Cannon
(formerly the Kettleford fete's confetti cannon)
Do not fire indoors."""

const LOBBY_PLAQUE := """HOARD LABS
Tomorrow's ideas, today.
Other people's ideas, also today."""

var doors_ctl: LabsDoors
var marsh: LabsOfficer
var fenwick: Person
var dobbs: Person
var rook: Person
var vents := {}
var coffee_ready := false
var _run: JobRun
var _switches := {}
var _alarm_switch: UsableBody
var _desk_t := 0.0
var _bottle_left := false
var _cannon_fired := false
var _pockets := {}
var _cup: Node3D
var _stand_watching := false


func build() -> void:
	circuit = CIRCUIT
	alarm_time = 25.0
	doors_ctl = LabsDoors.new(self)
	add_child(doors_ctl)
	_grounds()
	_main_block()
	_hangar()
	_loading_bay()
	_roofs()
	_duct()
	_furnish()
	_lamps()
	_security()
	_things()
	_marks()
	house_boxes.append(AABB(Vector3(-18, -0.5, -10), Vector3(24, UP + 0.5, 18)))
	house_boxes.append(AABB(Vector3(6, -0.5, -16), Vector3(12, HANGAR_TOP + 0.5, 18)))
	house_boxes.append(AABB(Vector3(6, -0.5, 2), Vector3(12, UP + 0.5, 6)))
	areas["hangar"] = house_boxes[1]
	areas["duct"] = AABB(Vector3(-18, -0.5, -10), Vector3(24, 1.5, 2))
	areas["office"] = AABB(Vector3(-18, -0.5, 2), Vector3(6, 3, 6))
	areas["server"] = AABB(Vector3(-6, -0.5, -8), Vector3(6, 3, 8))
	areas["cell"] = AABB(Vector3(10, -0.5, -16), Vector3(6, 3, 6))
	openings.append({"id": "roof_vent", "kind": "vent", "pos": Vector3(SHAFT.get_center().x, UP - 0.5, SHAFT.get_center().y)})
	# The lab coat belongs in the labs, not the hangar, goods in or the office.
	add_zone("hangar", house_boxes[1], [])
	add_zone("goods_in", house_boxes[2], [])
	add_zone("office", areas["office"], [])
	add_masking(areas["server"], 0.7)
	for room in lights:
		set_lights(room, room in LIGHTS_ON)


func _ready() -> void:
	at_way_out.connect(_on_way_out)


# --- The site -------------------------------------------------------------------

func _grounds() -> void:
	Kit.block(self, Vector3(1, -0.07, -7), Vector3(54, 0.1, 30), "grass", Kit.flat(GRASS))
	Kit.block(self, Vector3(-4, -0.05, 16), Vector3(44, 0.1, 12), "concrete", Kit.flat(ASPHALT))
	Kit.block(self, Vector3(-4, -0.04, 9), Vector3(44, 0.08, 2), "concrete", Kit.flat(PAVEMENT))
	Kit.block(self, Vector3(23, -0.045, 2), Vector3(10, 0.09, 40), "concrete", Kit.flat(CONCRETE))
	# Parking bays.
	var paint := Kit.flat(Color(0.85, 0.85, 0.8))
	for i in 9:
		Kit.block(self, Vector3(-22 + i * 3.0, -0.0, 13.2), Vector3(0.1, 0.02, 4.4), "", paint, false)
	Kit.block(self, Vector3(-10, -0.0, 15.4), Vector3(24, 0.02, 0.1), "", paint, false)
	# The perimeter fence: too tall to climb.
	var mesh := StandardMaterial3D.new()
	mesh.albedo_color = Color(0.25, 0.27, 0.3, 0.55)
	mesh.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	Kit.block(self, Vector3(-26, 1.3, 1), Vector3(0.1, 2.6, 46), "", mesh)
	Kit.block(self, Vector3(28, 1.3, 1), Vector3(0.1, 2.6, 46), "", mesh)
	Kit.block(self, Vector3(1, 1.3, -22), Vector3(54, 2.6, 0.1), "", mesh)
	Kit.block(self, Vector3(1, 1.3, 24), Vector3(54, 2.6, 0.1), "", mesh)
	for x in range(-26, 29, 6):
		for z in [-22, 24]:
			Kit.block(self, Vector3(x, 1.35, z), Vector3(0.12, 2.7, 0.12), "", Kit.flat(DARK), false)
	# Cars: Dr Fenwick's, the guards', the officer's, and the delivery truck.
	Kit.boxed(self, CARS + "hatchback-sports.glb", Vector3(-19, 0, 13.4), 180, 1.7)
	Kit.boxed(self, CARS + "sedan.glb", Vector3(-13, 0, 13.4), 180, 1.7)
	Kit.boxed(self, CARS + "van.glb", Vector3(-4, 0, 13.4), 0, 1.7)
	Kit.boxed(self, CARS + "sedan.glb", Vector3(2, 0, 13.4), 180, 1.7)
	Kit.boxed(self, CARS + "delivery.glb", Vector3(23.5, 0, -6), 0, 1.8)
	for c in [Vector3(20.5, 0, 9), Vector3(21.5, 0, 9.4), Vector3(26, 0, -1)]:
		Kit.model(self, CARS + "cone.glb", c, randf() * 90.0, 1.5)
	# Pallets stacked in the yard against goods in: a way up to the roof.
	var pallet := Kit.flat(WOOD)
	Kit.block(self, Vector3(18.55, 0.75, 7.1), Vector3(0.9, 1.5, 1.2), "wood", pallet)
	Kit.block(self, Vector3(19.5, 0.35, 7.1), Vector3(1.0, 0.7, 1.2), "wood", pallet)
	for y in [0.3, 0.75, 1.2]:
		Kit.block(self, Vector3(18.55, y, 7.1), Vector3(0.94, 0.06, 1.24), "", Kit.flat(Color(0.4, 0.28, 0.18)), false)
	Kit.boxed(self, SS + "container-tall.glb", Vector3(20.6, 0, 7.4), 0, SS_SCALE)


# --- The building -----------------------------------------------------------------

func _spec(id: String, into: Vector2, extra := {}) -> Dictionary:
	var d := {"id": id, "into": into}
	d.merge(extra)
	return d


func _lab_door(id: String, into: Vector2, key := "lab_keycard", verb := "Swipe the lab card") -> Dictionary:
	return _spec(id, into, {"locked": true, "key": key, "slide": true, "model": LAB_DOOR, "key_verb": verb})


func _main_block() -> void:
	# Floors.
	floor_rect(0, -18, 2, -12, 8, "carpet", CARPET, false)
	floor_rect(0, -12, 2, -4, 8, "tile", LAB_FLOOR, false)
	floor_rect(0, -4, 2, 2, 8, "tile", Color(0.7, 0.66, 0.6), false)
	floor_rect(0, 2, 2, 6, 8, "carpet", HOARD_CARPET, false)
	floor_rect(0, -18, 0, 6, 2, "tile", CORRIDOR_FLOOR, false)
	floor_rect(0, -18, -8, -12, 0, "tile", LAB_FLOOR, false)
	floor_rect(0, -12, -8, -6, 0, "tile", Color(0.9, 0.92, 0.94), false)
	floor_rect(0, -6, -8, 0, 0, "concrete", Color(0.4, 0.42, 0.48), false)
	floor_rect(0, 0, -8, 6, 0, "concrete", CONCRETE, false)
	floor_rect(0, -18, -10, 6, -8, "concrete", METAL, false)
	# Outside walls.
	line(0, Vector2(-18, 8), Vector2(1, 0), "WwWwDwwwoWwW", [
		_spec("entrance", Vector2(-9, 6), {"locked": true, "pick": 8.0, "slide": true, "outside": true, "model": LAB_DOOR}),
		"break_window"])
	line(0, Vector2(-18, -10), Vector2(0, 1), "WWwWwDWwW", [
		_spec("fire_exit", Vector2(-20, 1), {"locked": true, "outside": true, "people_open": false, "model": "door-rotate-square-a.glb"})])
	line(0, Vector2(-18, -10), Vector2(1, 0), "WWWWWWWWWWWW")
	# The corridor, with the labs to the north and the offices to the south.
	line(0, Vector2(-18, 0), Vector2(1, 0), "WDWWDWWDWDWW", [
		_lab_door("chem_door", Vector2(-15, -2)),
		_lab_door("clean_door", Vector2(-9, -2)),
		_spec("server_door", Vector2(-3, -2), {"locked": true, "slide": true, "model": LAB_DOOR}),
		_lab_door("workshop_door", Vector2(1, -2))])
	line(0, Vector2(-18, 2), Vector2(1, 0), "WDWWddWWDWDW", [
		_spec("office_door", Vector2(-15, 4), {"model": "door-rotate-square-b.glb"}),
		_spec("break_door", Vector2(-1, 4), {"model": "door-rotate-square-b.glb"}),
		_spec("hoard_door", Vector2(3, 4), {"locked": true, "pick": 6.0, "model": "door-rotate-square-c.glb"})])
	line(0, Vector2(-12, 2), Vector2(0, 1), "Www")
	line(0, Vector2(-4, 2), Vector2(0, 1), "WWW")
	line(0, Vector2(2, 2), Vector2(0, 1), "WWW")
	for x in [-12, -6, 0]:
		line(0, Vector2(x, -8), Vector2(0, 1), "WWWW")
	# The duct's wall, with a vent into each lab.
	line(0, Vector2(-18, -8), Vector2(1, 0), "W.WW.WW.WW.W")
	for v in [["chem", -15], ["clean", -9], ["server", -3], ["workshop", 3]]:
		vents[v[0]] = LabsVent.in_wall(v[0], self, Vector3(v[1], 0, -8), Vector3(0, 0, 1))
	doors_ctl.manage("entrance", Vector3(-9, 0, 5))
	doors_ctl.manage("fire_exit", Vector3(-16, 0, 1), false, true)
	doors_ctl.manage("chem_door", Vector3(-15, 0, -3))
	doors_ctl.manage("clean_door", Vector3(-9, 0, -3))
	doors_ctl.manage("server_door", Vector3(-3, 0, -3))
	doors_ctl.manage("workshop_door", Vector3(1, 0, -3))


func _hangar() -> void:
	floor_rect(0, 6, -16, 18, 2, "concrete", Color(0.45, 0.46, 0.5), false)
	# West wall, shared with the lab block: the duct's vent and the door.
	line(0, Vector2(6, -16), Vector2(0, 1), "WWW.WWWWDWWW", [
		_lab_door("hangar_door", Vector2(8, 1), "hangar_keycard", "Swipe the hangar card")])
	vents["hangar"] = LabsVent.in_wall("hangar", self, Vector3(6, 0, -9), Vector3(1, 0, 0))
	line(0, Vector2(6, -16), Vector2(1, 0), "WWWWWW")
	line(0, Vector2(18, -16), Vector2(0, 1), "WWWW..WWW")
	line(0, Vector2(6, 2), Vector2(1, 0), "WW..DW", [
		_lab_door("bay_hangar", Vector2(15, 0), "hangar_keycard", "Swipe the hangar card")])
	# Upper storey, with the stuck-open window onto the catwalk.
	line(UP, Vector2(6, -16), Vector2(0, 1), "WWWWWWWWW")
	line(UP, Vector2(6, -16), Vector2(1, 0), "WwWWwW")
	line(UP, Vector2(18, -16), Vector2(0, 1), "WWwWWwWWW")
	line(UP, Vector2(6, 2), Vector2(1, 0), "WWWoWW", ["hangar_high_window"])
	# Roller shutters, down for the night.
	_shutter(Vector3(18, 0, -6), 90.0)
	_shutter(Vector3(12, 0, 2), 0.0)
	# The catwalk along the south wall, its railing and the stairs down.
	floor_rect(UP, 6, 0, 18, 2, "concrete", METAL)
	line(UP, Vector2(6, 0), Vector2(1, 0), "-----")
	Kit.model(self, Kit.BUILDING + "stairs-closed.glb", Vector3(17, 0, -2), 0)
	_ramp(Vector2(16.35, 17.65), -4.0, 0.0, 0.0, UP, "concrete")
	# The test cell at the back, with its own roof and a doorway behind lasers.
	line(0, Vector2(10, -16), Vector2(0, 1), "WWW")
	line(0, Vector2(16, -16), Vector2(0, 1), "WWW")
	line(0, Vector2(10, -10), Vector2(1, 0), "WdW")
	floor_rect(0, 10, -16, 16, -10, "concrete", Color(0.36, 0.37, 0.42), false)
	floor_rect(UP, 10, -16, 16, -10, "concrete", METAL)
	doors_ctl.manage("hangar_door", Vector3(8, 0, 1))
	doors_ctl.manage("bay_hangar", Vector3(15, 0, -1))


func _loading_bay() -> void:
	floor_rect(0, 6, 2, 18, 8, "concrete", CONCRETE, false)
	line(0, Vector2(6, 2), Vector2(0, 1), "WWW")
	line(0, Vector2(6, 8), Vector2(1, 0), "WW..WW")
	line(0, Vector2(18, 2), Vector2(0, 1), "WDW", [
		_spec("bay_door", Vector2(16, 5), {"locked": true, "pick": 5.0, "key": "goods_in_key", "outside": true})])
	_shutter(Vector3(12, 0, 8), 0.0)
	doors_ctl.manage("bay_door", Vector3(14, 0, 5))


## A 4 m roller shutter, closed, in a gap left in a wall line.
func _shutter(c: Vector3, yaw: float) -> void:
	var s := Kit.block(self, c + Vector3(0, UP * 0.5, 0), Vector3(4.0, UP, 0.14), "", Kit.flat(SHUTTER))
	s.rotation.y = deg_to_rad(yaw)
	for i in 8:
		var rib := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(4.0, 0.04, 0.18)
		bm.material = Kit.flat(Color(0.48, 0.5, 0.54))
		rib.mesh = bm
		rib.position = Vector3(0, -UP * 0.5 + 0.3 * (i + 1), 0)
		s.add_child(rib)


## A solid ramp (stairs) between x0..x1 (a Vector2), rising from y_a at z_a
## to y_b at z_b.
func _ramp(xs: Vector2, z_a: float, z_b: float, y_a: float, y_b: float, surface: String) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = Kit.LAYER_WORLD
	body.collision_mask = 0
	var cs := CollisionShape3D.new()
	var wedge := ConvexPolygonShape3D.new()
	var pts := PackedVector3Array()
	for x in [xs.x, xs.y]:
		pts.append_array([Vector3(x, 0, z_a), Vector3(x, 0, z_b), Vector3(x, y_b, z_b), Vector3(x, y_a + 0.12, z_a)])
	wedge.points = pts
	cs.shape = wedge
	body.add_child(cs)
	add_child(body)
	Kit.add_surface(body, surface)
	body.add_to_group(Kit.NAV_GROUP)


func _roofs() -> void:
	# The lab block's flat roof, with the hatch's shaft cut out of it.
	var s := SHAFT
	floor_rect(UP, -18, s.end.y, 6, 8, "concrete", ROOF)
	floor_rect(UP, -18, -10, 6, s.position.y, "concrete", ROOF)
	floor_rect(UP, -18, s.position.y, s.position.x, s.end.y, "concrete", ROOF)
	floor_rect(UP, s.end.x, s.position.y, 6, s.end.y, "concrete", ROOF)
	floor_rect(UP, 6, 2, 18, 8, "concrete", ROOF)
	floor_rect(HANGAR_TOP, 6, -16, 18, 2, "", ROOF)
	# A low parapet round the lab block's roof edge (not over the yard side).
	var lip := Kit.flat(Color(0.5, 0.5, 0.54))
	Kit.block(self, Vector3(-6, UP + 0.15, 8), Vector3(24, 0.3, 0.2), "", lip)
	Kit.block(self, Vector3(-18, UP + 0.15, -1), Vector3(0.2, 0.3, 18), "", lip)
	Kit.block(self, Vector3(-6, UP + 0.15, -10), Vector3(24, 0.3, 0.2), "", lip)
	# Things on the roof.
	Kit.boxed(self, SPACE + "satelliteDish.glb", Vector3(-6, UP, -6), 200, 2.8)
	Kit.boxed(self, SPACE + "machine_wireless.glb", Vector3(0, UP, 4), 30, 2.0)
	for c in [Vector3(-10, UP, 4), Vector3(-2, UP, -2)]:
		Kit.block(self, c + Vector3(0, 0.45, 0), Vector3(1.4, 0.9, 1.2), "concrete", Kit.flat(Color(0.6, 0.62, 0.66)))
		Kit.block(self, c + Vector3(0, 0.92, 0), Vector3(0.9, 0.04, 0.9), "", Kit.flat(DARK), false)
	vents["roof"] = LabsVent.hatch("roof", self, Vector3(s.get_center().x, UP, s.get_center().y), s.size)


## The crawl duct behind the labs: 0.95 m high, dark, with the shaft from
## the roof hatch at its west end (and a step in it, to climb back out).
func _duct() -> void:
	var s := SHAFT
	var lid := Kit.flat(Color(0.22, 0.23, 0.27))
	var h := 0.95
	Kit.block(self, Vector3((s.end.x + 6) * 0.5, h + 0.05, -9), Vector3(6 - s.end.x, 0.1, 2), "", lid)
	Kit.block(self, Vector3((s.position.x - 18) * 0.5, h + 0.05, -9), Vector3(s.position.x + 18, 0.1, 2), "", lid)
	Kit.block(self, Vector3(s.get_center().x, h + 0.05, (s.position.y - 10) * 0.5), Vector3(s.size.x, 0.1, s.position.y + 10), "", lid)
	Kit.block(self, Vector3(s.get_center().x, h + 0.05, (s.end.y - 8) * 0.5), Vector3(s.size.x, 0.1, -8 - s.end.y), "", lid)
	# The shaft's east side shuts off the space above the duct.
	Kit.block(self, Vector3(s.end.x + 0.05, (h + UP) * 0.5, -9), Vector3(0.1, UP - h, 2), "", lid)
	# The step in the shaft.
	Kit.block(self, Vector3(-17.6, 0.5, -9), Vector3(0.7, 1.0, 1.8), "concrete", Kit.flat(METAL))


# --- Furniture ------------------------------------------------------------------------

## A model with no collision, centred on its footprint at `pos`.
func _prop(path: String, pos: Vector3, yaw := 0.0, scale := 1.0) -> Node3D:
	var holder := Node3D.new()
	holder.position = pos
	holder.rotation.y = deg_to_rad(yaw)
	var n: Node3D = Kit.scene(path).instantiate()
	n.scale = Vector3.ONE * scale
	holder.add_child(n)
	var box := Kit.aabb_of(n)
	n.position = Vector3(-box.get_center().x, -box.position.y, -box.get_center().z)
	add_child(holder)
	return holder


## A Space Station Kit piece that blocks, standing on the floor at `pos`.
func _ss(name_: String, pos: Vector3, yaw := 0.0, scale := SS_SCALE, solid := true) -> Node3D:
	if not solid:
		return _prop(SS + name_ + ".glb", pos, yaw, scale)
	var body := Kit.boxed(self, SS + name_ + ".glb", pos, yaw, scale, "concrete")
	# Some pieces hang below their origin; stand them on the floor.
	var box := Kit.aabb_of(body.get_child(0))
	if box.position.y < -0.01:
		body.position.y -= box.position.y
	return body


func _furnish() -> void:
	# Security office: consoles under the lobby windows, a wall of screens.
	_ss("computer-wide", Vector3(-12.6, 0, 4.2), -90)
	_ss("computer-wide", Vector3(-12.6, 0, 5.8), -90)
	_ss("chair-armrest-headrest", Vector3(-14.4, 0, 5.0), 90, SS_SCALE, false)
	for x in [-13.0, -17.0]:
		_ss("display-wall-wide", Vector3(x, 1.5, 2.3), 0, SS_SCALE, false)
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(-17.6, 0, 7.4), 90)
	# Lobby: the reception desk faces the doors.
	Kit.furniture(self, "desk", Vector3(-8.75, 0, 4.4), 180)
	Kit.furniture(self, "desk", Vector3(-7.25, 0, 4.4), 180)
	_prop(Kit.FURNITURE + "computerScreen.glb", Vector3(-8.3, 0.76, 4.6), 180, Kit.FURNITURE_SCALE)
	Kit.furniture(self, "chairDesk", Vector3(-8.0, 0, 3.4), 0)
	Kit.furniture(self, "loungeDesignSofa", Vector3(-11.4, 0, 6.2), 90)
	Kit.furniture(self, "pottedPlant", Vector3(-11.5, 0, 4.3), 0)
	Kit.furniture(self, "pottedPlant", Vector3(-4.5, 0, 7.5), 0)
	_ss("table-display", Vector3(-5.0, 0, 4.6), 90)
	_prop(SPACE + "craft_cargoA.glb", Vector3(-5.0, 0.62, 4.6), 30, 0.45)
	_sign("HOARD LABS", Vector3(-8, 2.0, 2.13), 0.0, 48, Color(0.95, 0.7, 0.25))
	_sign("Tomorrow's ideas, today.", Vector3(-8, 1.72, 2.13), 0.0, 22)
	# Break room.
	Kit.furniture(self, "kitchenCabinet", Vector3(1.5, 0, 5.0), -90)
	Kit.furniture(self, "kitchenCabinet", Vector3(1.5, 0, 5.86), -90)
	Kit.furniture(self, "kitchenFridge", Vector3(1.6, 0, 3.0), -90)
	Kit.furniture(self, "table", Vector3(-1.6, 0, 4.6), 90)
	for c in [[Vector3(-2.3, 0, 4.1), 90], [Vector3(-2.3, 0, 5.1), 90], [Vector3(-0.9, 0, 4.1), -90], [Vector3(-0.9, 0, 5.1), -90]]:
		Kit.furniture(self, "chair", c[0], c[1])
	Kit.furniture(self, "coatRackStanding", Vector3(-3.4, 0, 7.3), 0)
	Kit.furniture(self, "trashcan", Vector3(-3.5, 0, 2.5), 0)
	# Hoard's office.
	Kit.furniture(self, "desk", Vector3(4.0, 0, 7.3), 180)
	Kit.furniture(self, "chairDesk", Vector3(4.0, 0, 6.5), 0)
	Kit.furniture(self, "bookcaseClosedWide", Vector3(2.5, 0, 6.0), 90)
	Kit.furniture(self, "loungeChair", Vector3(5.0, 0, 5.0), -120)
	_prop(Kit.FURNITURE + "rugRectangle.glb", Vector3(4.0, 0, 5.0), 0, Kit.FURNITURE_SCALE)
	_sign("A. HOARD\nFounder, Inventor,\nOwner of Ideas", Vector3(5.88, 1.6, 6.0), -90.0, 18, Color(0.95, 0.85, 0.5))
	# Chemistry lab: benches on the west wall, an island, drums.
	for z in [-6.6, -5.74, -4.88, -4.02, -3.16, -2.3]:
		Kit.furniture(self, "kitchenCabinet", Vector3(-17.5, 0, z), 90)
	_ss("table-inset", Vector3(-14.4, 0, -3.6), 0)
	_ss("computer", Vector3(-12.6, 0, -6.8), -90)
	for c in [Vector3(-12.6, 0, -2.0), Vector3(-12.6, 0, -1.2)]:
		_ss("container-tall", c, 0)
	# Clean room: spotless benches and a particle counter.
	_ss("table-inset", Vector3(-10.4, 0, -4.0), 90)
	_ss("table-inset", Vector3(-7.6, 0, -4.0), 90)
	_ss("computer-screen", Vector3(-6.7, 0, -6.6), -90)
	# Server room: two rows of racks humming away.
	for x in [-5.3, -0.7]:
		for z in [-6.8, -5.8, -4.8, -3.8]:
			_rack(Vector3(x, 0, z))
	var hum := Node3D.new()
	hum.position = Vector3(-3, 1.5, -4)
	add_child(hum)
	Sfx.on(hum, "server_hum_loop", -8.0)
	# Workshop: a big bench, tool drums, parts.
	_ss("table-large", Vector3(4.6, 0, -3.0), 90)
	_ss("computer-system", Vector3(5.2, 0, -6.6), -90)
	_ss("container", Vector3(0.7, 0, -1.0), 0)
	_ss("container-wide", Vector3(0.7, 0, -1.9), 0)
	_prop(SPACE + "machine_generator.glb", Vector3(4.6, 0.64, -3.0), 90, 1.0)
	# Hangar: the prototype van, crates, a generator.
	Kit.boxed(self, SPACE + "craft_cargoA.glb", Vector3(9.0, 0, -4.0), 15, 1.6)
	for c in [Vector3(17.2, 0, -14.6), Vector3(17.2, 0, -13.6), Vector3(16.6, 0, -12.4)]:
		_ss("container-tall", c, 0)
	_ss("container-flat", Vector3(7.0, 0, -15.0), 0)
	Kit.boxed(self, SPACE + "machine_generator.glb", Vector3(17.0, 0, -9.0), -90, 2.2)
	_ss("structure", Vector3(7.0, 0, -6.2), 0)
	# Goods in: boxes everywhere.
	for b in [Vector3(9, 0, 7.4), Vector3(9.5, 0, 6.8), Vector3(14.8, 0, 7.4), Vector3(15.4, 0, 7.4), Vector3(7.0, 0, 5.8)]:
		Kit.furniture(self, "cardboardBoxClosed", b, randf() * 30.0)
	for c in [Vector3(16.9, 0, 2.7), Vector3(16.9, 0, 3.4)]:
		_ss("container-wide", c, 0)
	_ss("skip", Vector3(10.0, 0, 3.3), 90)


## A server rack: a dark cabinet with blinking lights.
func _rack(at: Vector3) -> void:
	var body := Kit.block(self, at + Vector3(0, 1.0, 0), Vector3(0.9, 2.0, 0.9), "", Kit.flat(DARK))
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color(0.3, 0.9, 1.0)
	glow.emission_enabled = true
	glow.emission = Color(0.3, 0.9, 1.0)
	glow.emission_energy_multiplier = 2.0
	for i in 6:
		var led := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.92, 0.03, 0.5)
		bm.material = glow
		led.mesh = bm
		led.position = Vector3(0, -0.7 + i * 0.28, 0)
		body.add_child(led)


## Words on a wall (a sign, a plaque): `yaw` 0 faces south.
func _sign(text: String, pos: Vector3, yaw: float, size: int, color := Color(0.9, 0.92, 0.95)) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.position = pos
	l.rotation.y = deg_to_rad(yaw)
	l.font_size = size
	l.pixel_size = 0.005
	l.modulate = color
	l.outline_size = 0
	l.shaded = true
	add_child(l)
	return l


func _lamps() -> void:
	var cool := Color(0.85, 0.92, 1.0)
	lamp("office", Vector3(-15, UP, 5), true, 1.0, 5.5, cool)
	lamp("lobby", Vector3(-8, UP, 5), true, 0.7, 5.5, cool)
	lamp("break", Vector3(-1, UP, 5), false)
	lamp("hoard", Vector3(4, UP, 5), false)
	for x in [-13.0, -5.0, 3.0]:
		lamp("corridor", Vector3(x, UP, 1), true, 0.6, 4.5, cool)
	lamp("chem", Vector3(-15, UP, -4), true, 1.1, 6.0, cool)
	lamp("clean", Vector3(-9, UP, -4), false, 1.2, 6.0, Color(1, 1, 1))
	lamp("server", Vector3(-3, UP, -4), false, 0.9, 5.0, cool)
	lamp("workshop", Vector3(3, UP, -4), false, 1.1, 6.0)
	lamp("bay", Vector3(12, UP, 5), false, 1.0, 7.0, cool)
	lamp("hangar", Vector3(8.5, HANGAR_TOP, -7), true, 0.5, 9.0, cool)
	lamp("hangar", Vector3(14.5, HANGAR_TOP, -3), true, 0.5, 9.0, cool)
	lamp("cell", Vector3(13, UP, -13), true, 2.2, 6.0, Color(1.0, 0.95, 0.85))
	# A blue glow in the server room that isn't a lamp (it doesn't light you).
	var leds := OmniLight3D.new()
	leds.position = Vector3(-3, 1.2, -4.5)
	leds.light_color = Color(0.3, 0.8, 1.0)
	leds.light_energy = 0.4
	leds.omni_range = 4.0
	add_child(leds)
	# Outside: over the entrance, the car park and the goods-in door.
	lights["entrance"] = [_outside_light(Vector3(-9, 2.4, 8.6), 7.0, 1.6)]
	lights["yard"] = [_outside_light(Vector3(18.6, 2.3, 5.0), 7.0, 1.4)]
	lights["car_park"] = []
	for x in [-16.0, -2.0]:
		Kit.block(self, Vector3(x, 2.2, 15.8), Vector3(0.15, 4.4, 0.15), "", Kit.flat(DARK))
		lights["car_park"].append(_outside_light(Vector3(x, 4.4, 15.8), 10.0, 2.0, false))
	# Switches by the doors.
	light_switch(["lobby"], Vector3(-4.12, 1.3, 3.0), Vector3(-1, 0, 0))
	light_switch(["office"], Vector3(-13.6, 1.3, 2.12), Vector3(0, 0, 1))
	light_switch(["break"], Vector3(-2.4, 1.3, 2.12), Vector3(0, 0, 1))
	light_switch(["hoard"], Vector3(4.4, 1.3, 2.12), Vector3(0, 0, 1))
	light_switch(["corridor"], Vector3(-17.4, 1.3, 0.12), Vector3(0, 0, 1))
	light_switch(["corridor"], Vector3(0.6, 1.3, 1.88), Vector3(0, 0, -1))
	light_switch(["chem"], Vector3(-13.6, 1.3, -0.12), Vector3(0, 0, -1))
	light_switch(["clean"], Vector3(-7.6, 1.3, -0.12), Vector3(0, 0, -1))
	light_switch(["server"], Vector3(-1.6, 1.3, -0.12), Vector3(0, 0, -1))
	light_switch(["workshop"], Vector3(2.4, 1.3, -0.12), Vector3(0, 0, -1))
	light_switch(["hangar"], Vector3(6.12, 1.3, -0.6), Vector3(1, 0, 0))
	light_switch(["cell"], Vector3(14.6, 1.3, -10.12), Vector3(0, 0, -1))
	light_switch(["bay"], Vector3(17.88, 1.3, 3.4), Vector3(-1, 0, 0))


func _outside_light(pos: Vector3, reach: float, energy: float, shade := true) -> SpotLight3D:
	var l := SpotLight3D.new()
	l.position = pos
	l.rotation.x = -PI * 0.5
	l.light_color = Color(1.0, 0.85, 0.6)
	l.spot_range = reach
	l.spot_angle = 55.0
	l.light_energy = energy
	l.shadow_enabled = shade
	l.add_to_group("stealth_lights")
	add_child(l)
	var fitting := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.4, 0.12, 0.3)
	bm.material = Kit.flat(DARK)
	fitting.mesh = bm
	fitting.position = pos + Vector3(0, 0.08, 0)
	add_child(fitting)
	return l


# --- Security: cameras, lasers, the office panel ---------------------------------------

func _security() -> void:
	var coat := {"accepts": ["labcoat"]}
	camera("lobby", Vector3(-5.0, 2.15, 2.12), 0, coat.merged({"sweep": 40.0, "pitch": 22.0}))
	camera("corridor_w", Vector3(-17.88, 2.1, 1.0), 90, coat.merged({"sweep": 20.0, "pitch": 12.0, "period": 10.0}))
	camera("corridor_e", Vector3(5.88, 2.1, 1.0), -90, coat.merged({"sweep": 20.0, "pitch": 12.0, "period": 10.0}))
	camera("hangar", Vector3(17.88, 4.0, -3.0), -90, coat.merged({"sweep": 55.0, "pitch": 30.0, "period": 12.0}))
	camera("cell", Vector3(12.0, 2.1, -10.12), 180, coat.merged({"sweep": 30.0, "pitch": 28.0, "period": 7.0}))
	camera("yard", Vector3(18.12, 2.2, 2.6), 90, coat.merged({"sweep": 50.0, "pitch": 25.0}))
	# The corridor lasers blink (two seconds on, two off); the cell's are
	# high, with room to crawl under.
	lasers("corridor", Vector3(4.6, 0, 0.25), Vector3(4.6, 0, 1.75), [0.35, 0.9, 1.45], 4.0)
	_prop(MSK + "gate.glb", Vector3(4.6, 0, 1.0), 90, 0.45)
	lasers("cell", Vector3(12.45, 0, -10), Vector3(13.55, 0, -10), [0.9, 1.45])
	_sign("TEST CELL\nLASERS ACTIVE", Vector3(13, 2.0, -9.88), 0.0, 20, Color(1.0, 0.45, 0.3))
	# The office panel: cameras, lasers, alarm, and the key cabinet.
	_switches["cameras"] = _office_switch("cameras", "Switch off the cameras", "Switch on the cameras", Vector3(-17.9, 1.4, 3.3))
	_switches["lasers"] = _office_switch("lasers", "Switch off the lasers", "Switch on the lasers", Vector3(-17.9, 1.4, 3.9))
	_alarm_switch = alarm_switch(Vector3(-17.9, 1.4, 4.6), 90)
	_sign("CAMERAS   LASERS   ALARM", Vector3(-17.92, 1.72, 3.95), 90.0, 12)
	var cabinet := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.1, 0.55, 0.45)
	bm.material = Kit.flat(Color(0.55, 0.57, 0.6))
	cabinet.mesh = bm
	cabinet.position = Vector3(-17.93, 1.35, 6.3)
	add_child(cabinet)
	_card("hangar_keycard", "Take the spare hangar card", Vector3(-17.85, 1.35, 6.3), 90, Color(0.85, 0.2, 0.18))
	# The server room's keypad and door controller.
	keypad("server", SERVER_CODE, Vector3(-1.7, 1.3, 0.13), 0, "server_door")
	var ctl := UsableBody.new()
	ctl.name = "DoorController"
	ctl.position = Vector3(-0.75, 0, -1.3)
	var cab := MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(0.6, 1.4, 0.6)
	cm.material = Kit.flat(Color(0.3, 0.32, 0.38))
	cab.mesh = cm
	cab.position = Vector3(0, 0.7, 0)
	ctl.add_child(cab)
	var button := MeshInstance3D.new()
	var bb := BoxMesh.new()
	bb.size = Vector3(0.06, 0.16, 0.16)
	bb.material = Kit.flat(Color(0.85, 0.12, 0.1))
	button.mesh = bb
	button.position = Vector3(-0.32, 1.1, 0)
	ctl.add_child(button)
	ctl.add_box(Vector3(0, 0.7, 0), Vector3(0.6, 1.4, 0.6))
	ctl.add_action("interact", "Release the hangar door", _release_hangar.bind(ctl))
	ctl.set_meta("dartable", true)
	add_child(ctl)
	_sign("HANGAR DOOR", Vector3(-1.06, 1.35, -1.3), -90.0, 12)


func _office_switch(group: String, verb_off: String, verb_on: String, pos: Vector3) -> UsableBody:
	var s := group_switch(group, verb_off, verb_on, pos, 90)
	var a := s.action("interact")
	a.on_use = _flip_office.bind(a.on_use)
	return s


func _flip_office(pic: PlayerInteractionComponent, flip: Callable) -> void:
	flip.call(pic)
	if not cameras_on() and not lasers_on() and marsh != null and not cameras_watched():
		_record("office_all_off")


func cameras_on() -> bool:
	return _switches["cameras"].get_meta("on")


func lasers_on() -> bool:
	return _switches["lasers"].get_meta("on")


## The cameras only raise the alarm while Officer Marsh is at her monitors.
func cameras_watched() -> bool:
	return marsh != null and marsh.watching()


func raise_alarm(at: Vector3, cause := "") -> void:
	if cause == "camera":
		if not cameras_watched():
			_record("camera_unwatched")
			return
		if not alarm_ringing and alarm_armed and not power_off():
			marsh.say(CAMERA_LINE)
	super(at, cause)


## Back at her desk, Marsh puts everything back on.
func _reset_office() -> void:
	for group in _switches:
		var s: UsableBody = _switches[group]
		if not s.get_meta("on"):
			s.action("interact").on_use.call(null)
	if not alarm_armed:
		_alarm_switch.action("interact").on_use.call(null)
	marsh.say(RESET_LINE)
	_record("officer_reset")


func _release_hangar(_pic: PlayerInteractionComponent, ctl: UsableBody) -> void:
	if doors_ctl.is_held("hangar_door"):
		return
	doors_ctl.release("hangar_door")
	Sfx.at(self, "keypad_ok", ctl.global_position + Vector3(0, 1.1, 0), -4.0)
	Sfx.at(self, "kenney:metalLatch", doors.hangar_door.global_position + Vector3(0, 1, 0), -4.0)
	_record("hangar_released")
	ctl.set_action_text("interact", "")


# --- Things to use ---------------------------------------------------------------------

func _things() -> void:
	note("night_rota", "The night rota", NIGHT_ROTA, Vector3(-7.6, 0.77, 4.5), 80, Vector3(0.22, 0.01, 0.3))
	note("fenwick_journal", "Dr Fenwick's journal", FENWICK_JOURNAL, Vector3(-1.6, 0.67, 4.9), 20, Vector3(0.24, 0.03, 0.3))
	note("hoard_letter", "A letter on Hoard's desk", HOARD_LETTER, Vector3(4.2, 0.77, 7.3), 10, Vector3(0.22, 0.01, 0.3))
	note("maintenance_log", "The maintenance log", MAINTENANCE_LOG, Vector3(6.12, 1.4, 6.0), 90)
	note("it_memo", "A memo on the wall", IT_MEMO, Vector3(-0.12, 1.5, -2.4), -90)
	note("lobby_plaque", "A plaque", LOBBY_PLAQUE, Vector3(-4.12, 1.4, 5.5), -90, Vector3(0.3, 0.2, 0.01))
	# The lab coat on the rack, with Dr Fenwick's lab card in the pocket.
	var coat := UsableBody.new()
	coat.name = "LabCoat"
	coat.position = Vector3(-3.4, 0.55, 7.0)
	var white := Kit.flat(Color(0.95, 0.96, 0.97))
	for part in [[Vector3(0, 0.55, 0), Vector3(0.5, 1.0, 0.16)], [Vector3(-0.3, 0.7, 0), Vector3(0.12, 0.7, 0.14)], [Vector3(0.3, 0.7, 0), Vector3(0.12, 0.7, 0.14)]]:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = part[1]
		bm.material = white
		mi.mesh = bm
		mi.position = part[0]
		coat.add_child(mi)
	coat.add_box(Vector3(0, 0.55, 0), Vector3(0.7, 1.1, 0.3))
	coat.collision_layer = Kit.LAYER_INTERACT
	coat.add_action("interact", "Put on the lab coat", _wear_coat.bind(coat))
	add_child(coat)
	# The coffee machine.
	_prop(Kit.FURNITURE + "kitchenCoffeeMachine.glb", Vector3(1.55, 0.9, 5.0), -90, Kit.FURNITURE_SCALE)
	var machine := UsableBody.new()
	machine.name = "CoffeeMachine"
	machine.position = Vector3(1.6, 1.08, 5.0)
	machine.add_box(Vector3.ZERO, Vector3(0.5, 0.4, 0.5))
	machine.collision_layer = Kit.LAYER_INTERACT
	machine.add_action("interact", "Make a coffee", _make_coffee.bind(machine))
	add_child(machine)
	# The confetti cannon in the workshop.
	var cannon := UsableBody.new()
	cannon.name = "ConfettiCannon"
	cannon.position = Vector3(1.4, 0, -6.6)
	var base := MeshInstance3D.new()
	var bbm := BoxMesh.new()
	bbm.size = Vector3(0.7, 0.5, 0.7)
	bbm.material = Kit.flat(Color(0.85, 0.3, 0.55))
	base.mesh = bbm
	base.position = Vector3(0, 0.25, 0)
	cannon.add_child(base)
	var tube := MeshInstance3D.new()
	var tm := CylinderMesh.new()
	tm.top_radius = 0.2
	tm.bottom_radius = 0.16
	tm.height = 1.0
	tm.material = Kit.flat(Color(0.95, 0.8, 0.2))
	tube.mesh = tm
	tube.position = Vector3(0, 0.85, 0.15)
	tube.rotation.x = deg_to_rad(25)
	cannon.add_child(tube)
	cannon.add_box(Vector3(0, 0.6, 0), Vector3(0.7, 1.2, 0.7))
	cannon.add_action("interact", "Light the fuse", _fire_cannon.bind(cannon))
	cannon.set_meta("dartable", true)
	add_child(cannon)
	note("cannon_card", "A card on the cannon", CANNON_CARD, Vector3(1.4, 0.4, -6.24), 0, Vector3(0.2, 0.14, 0.01))
	# Confiscated fireworks in goods in, with a bottle rocket on top.
	Kit.block(self, Vector3(13.0, 0.35, 7.3), Vector3(1.0, 0.7, 0.8), "wood", Kit.flat(WOOD))
	note("fireworks_note", "A label on the crate", FIREWORKS_NOTE, Vector3(13.0, 0.45, 6.89), 0)
	var bottle := pickup("bottle_rocket", "Take a bottle rocket", SPACE + "rocket_topA.glb", Vector3(13.0, 0.95, 7.3), 0.12)
	_stick(bottle)
	# The fuse box in goods in.
	fuse_box(Vector3(6.12, 1.2, 3.6), 90)
	# The rocket on its launch stand in the test cell.
	_prop(SPACE + "rocket_baseB.glb", Vector3(13, 0, -13.6), 0, 0.6)
	treasure("rocket", "Take the rocket", SPACE + "rocket_topA.glb", Vector3(13, 0.62, -13.6), ROCKET_SCALE, 0, Vector3(0.7, 1.3, 0.7))
	treasure_stand.action("interact").on_use = _use_stand
	# Somewhere to hide.
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(-11.6, 0, 2.6), 90)
	hide_spot("lobby_cupboard", "Hide in the stationery cupboard", Vector3(-11.6, 0, 2.6), 90, Vector3(0, 1.4, 0), Vector3(0.6, 1.7, 0.6))
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(-6.6, 0, -1.0), -90)
	hide_spot("gowning_locker", "Hide in the gowning locker", Vector3(-6.6, 0, -1.0), -90, Vector3(0, 1.4, 0), Vector3(0.6, 1.7, 0.6))
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(5.6, 0, 3.0), -90)
	hide_spot("hoard_cupboard", "Hide in Hoard's coat cupboard", Vector3(5.6, 0, 3.0), -90, Vector3(0, 1.4, 0), Vector3(0.6, 1.7, 0.6))
	Kit.block(self, Vector3(7.6, 0.7, -12.5), Vector3(1.3, 1.4, 1.3), "wood", Kit.flat(WOOD))
	hide_spot("crate", "Hide in the packing crate", Vector3(7.6, 0, -12.5), 90, Vector3(0, 1.1, 0), Vector3(1.4, 1.5, 1.4))
	Kit.block(self, Vector3(16.9, 0.7, 6.9), Vector3(1.3, 1.4, 1.3), "wood", Kit.flat(WOOD))
	hide_spot("bay_crate", "Hide in the empty crate", Vector3(16.9, 0, 6.9), -90, Vector3(0, 1.1, 0), Vector3(1.4, 1.5, 1.4))


## A keycard to pick up: a little coloured card.
func _card(item: String, verb: String, pos: Vector3, yaw: float, color: Color) -> UsableBody:
	var c := UsableBody.new()
	c.name = "Card_" + item
	c.position = pos
	c.rotation.y = deg_to_rad(yaw)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.09, 0.055, 0.01)
	bm.material = Kit.flat(color)
	mi.mesh = bm
	c.add_child(mi)
	c.add_box(Vector3.ZERO, Vector3(0.18, 0.14, 0.06))
	c.collision_layer = Kit.LAYER_INTERACT
	c.add_action("interact", verb, _take.bind(item, "", c))
	add_child(c)
	return c


## A bottle rocket's stick.
func _stick(on: Node3D) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.015, 0.45, 0.015)
	bm.material = Kit.flat(Color(0.7, 0.55, 0.35))
	mi.mesh = bm
	mi.position = Vector3(0, -0.2, 0)
	on.add_child(mi)


func _wear_coat(pic: PlayerInteractionComponent, coat: UsableBody) -> void:
	var player: Node = pic.get_parent()
	player.add_item("lab_keycard")
	_wear(pic, "labcoat", "Dr Fenwick's spare coat. Her lab card's in the pocket.", coat)


func _make_coffee(pic: PlayerInteractionComponent, machine: UsableBody) -> void:
	if coffee_ready:
		UsableBody.hint(pic, "There's a fresh cup waiting already.")
		return
	coffee_ready = true
	Sfx.at(self, "coffee_machine", machine.global_position, -4.0)
	StealthNoise.make(self, machine.global_position, 5.0, "coffee", pic.get_parent())
	_cup = Kit.model(self, Kit.FOOD + "mug.glb", Vector3(1.45, 0.9, 5.55), 0, 0.4)
	_record("made_coffee")


func _fire_cannon(pic: PlayerInteractionComponent, cannon: UsableBody) -> void:
	if _cannon_fired:
		return
	_cannon_fired = true
	cannon.set_action_text("interact", "")
	UsableBody.hint(pic, "The fuse fizzes...")
	Sfx.at(self, "noisemaker_wind", cannon.global_position + Vector3(0, 0.8, 0), -4.0)
	await get_tree().create_timer(1.5).timeout
	if not is_inside_tree():
		return
	var mouth := cannon.global_position + Vector3(0, 1.4, 0.4)
	Sfx.at(self, "confetti_pop", mouth, 0.0)
	Sfx.at(self, "kenney:explosion2", mouth, -6.0, 1.6)
	StealthNoise.make(self, mouth, 26.0, "knock", pic.get_parent())
	_confetti(mouth)
	_record("confetti")


func _confetti(at: Vector3) -> void:
	var p := CPUParticles3D.new()
	p.position = at
	p.one_shot = true
	p.amount = 160
	p.lifetime = 4.0
	p.explosiveness = 0.95
	p.direction = Vector3(0, 1, 0.4)
	p.spread = 40.0
	p.initial_velocity_min = 4.0
	p.initial_velocity_max = 7.0
	p.gravity = Vector3(0, -3.0, 0)
	p.damping_min = 1.5
	p.damping_max = 2.5
	var q := QuadMesh.new()
	q.size = Vector2(0.05, 0.03)
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	q.material = m
	p.mesh = q
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(1, 0.3, 0.4), Color(0.3, 0.8, 1), Color(1, 0.9, 0.2), Color(0.5, 1, 0.4)])
	g.offsets = PackedFloat32Array([0.0, 0.33, 0.66, 1.0])
	p.color_initial_ramp = g
	p.angular_velocity_min = -360.0
	p.angular_velocity_max = 360.0
	add_child(p)
	p.emitting = true
	get_tree().create_timer(6.0).timeout.connect(p.queue_free)


# --- The rocket ---------------------------------------------------------------------------

## The school's rocket, stacked from Space Kit parts (they share an origin
## off to one side, which this puts back in the middle).
func _place_treasure_model() -> void:
	_treasure_model = rocket_model(_treasure_scale)
	treasure_stand.add_child(_treasure_model)


static func rocket_model(scale: float) -> Node3D:
	var r := Node3D.new()
	r.name = "Rocket"
	var y := 0.0
	for part in [["rocket_finsA", 0.7], ["rocket_sidesA", 1.0], ["rocket_topA", 0.8]]:
		var m: Node3D = Kit.scene(SPACE + part[0] + ".glb").instantiate()
		m.scale = Vector3.ONE * scale
		m.position = Vector3(-2.0, y, -1.5) * scale
		r.add_child(m)
		y += part[1]
	return r


func _use_stand(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if _treasure_model != null:
		_take_treasure(pic)
		if not _stand_watching:
			_stand_watching = true
			player.bag_changed.connect(_update_stand.bind(player))
		_update_stand(player)
		return
	if not _bottle_left and player.take_item("bottle_rocket"):
		var b: Node3D = Kit.scene(SPACE + "rocket_topA.glb").instantiate()
		b.scale = Vector3.ONE * 0.12
		b.position = Vector3(-0.24, 0.45, -0.18)
		var holder := Node3D.new()
		holder.name = "BottleRocket"
		holder.add_child(b)
		_stick(b)
		treasure_stand.add_child(holder)
		_bottle_left = true
		Sfx.at(self, "kenney:bookPlace1", treasure_stand.global_position + Vector3(0, 0.5, 0), -6.0)
		_record("bottle_on_stand")
		_update_stand(player)


## Once the rocket's gone, the stand offers to take a bottle rocket.
func _update_stand(player: Node) -> void:
	if _treasure_model != null:
		return
	var can_leave: bool = not _bottle_left and player.has_item("bottle_rocket")
	treasure_stand.set_action_text("interact", "Leave the bottle rocket" if can_leave else "")


func return_treasure() -> void:
	if _treasure_model != null:
		return
	var b := treasure_stand.get_node_or_null("BottleRocket")
	if b:
		b.queue_free()
	_bottle_left = false
	_place_treasure_model()
	treasure_stand.set_action_text("interact", "Take the rocket")


# --- Every frame ------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	super(delta)
	if marsh == null or _run == null or not _run.running:
		return
	# Marsh back at her desk puts the switches back.
	if marsh.watching():
		_desk_t += delta
		if _desk_t > 2.5 and (not cameras_on() or not lasers_on() or not alarm_armed):
			_reset_office()
	else:
		_desk_t = 0.0
	if marsh.is_asleep() and marsh.global_position.distance_to(points["monitors"]) < 1.5:
		_record("officer_snoozed")
	# A fresh coffee stops whoever finds it.
	if coffee_ready:
		for p in [marsh, fenwick, dobbs]:
			if p.state in [Person.State.ROUTINE, Person.State.WAIT] and p._arrived and p.global_position.distance_to(points["coffee"]) < 1.3:
				coffee_ready = false
				p.say(COFFEE_LINE)
				p.wait_at("coffee", 25.0)
				if is_instance_valid(_cup):
					_cup.queue_free()
				_record("coffee_drunk")
				break
	# A napping guard's keycard can be borrowed.
	for g in _pockets:
		var pocket: UsableBody = _pockets[g]
		var want := "Borrow the hangar card" if g.is_asleep() and not pocket.get_meta("taken") else ""
		if pocket.action("interact").interaction_text != want:
			pocket.set_action_text("interact", want)


func _on_way_out(id: String) -> void:
	var p := get_tree().get_first_node_in_group("moth")
	if p and p.has_item("rocket"):
		_record("left_by:" + id)


func _on_event(event: String) -> void:
	if event.begins_with("vent:"):
		for v in vents:
			if not _run.has("vent:" + v):
				return
		_record("all_vents")


func _on_fenwick_said(_who: Person, text: String) -> void:
	if text != CODE_LINE:
		return
	var p := get_tree().get_first_node_in_group("moth") as Moth
	if p == null:
		return
	var mouth := fenwick.global_position + Vector3(0, 1.5, 0)
	if p.global_position.distance_to(mouth) < 9.0 and StealthNoise.count_walls(self, mouth, p.eye_position()) <= 1:
		_record("heard:server_code")


## A hangar card on a guard's belt, there for the borrowing while they nap.
func _pocket(guard: Person) -> void:
	var b := UsableBody.new()
	b.name = "Pocket"
	b.collision_layer = Kit.LAYER_INTERACT
	b.add_box(Vector3(0, 0.6, 0), Vector3(1.0, 1.0, 1.0))
	b.set_meta("taken", false)
	b.add_action("interact", "", _borrow_card.bind(b)).is_disabled = true
	guard.add_child(b)
	_pockets[guard] = b


func _borrow_card(pic: PlayerInteractionComponent, pocket: UsableBody) -> void:
	if pocket.get_meta("taken"):
		return
	pocket.set_meta("taken", true)
	pic.get_parent().add_item("hangar_keycard")
	Sfx.at(self, "kenney:handleSmallLeather", pocket.global_position + Vector3(0, 0.8, 0), -10.0)
	UsableBody.hint(pic, "One hangar card. They won't miss it for a while.")
	_record("borrowed_keycard")
	pocket.set_action_text("interact", "")


# --- Marks and people ------------------------------------------------------------------

func _marks() -> void:
	add_start("car_park", Vector3(-7, 0, 19), 0)
	add_start("loading_bay", Vector3(25, 0, 3), 90)
	add_start("roof", Vector3(-12, UP, -6), 90)
	points = {
		"monitors": Vector3(-13.7, 0, 5.0), "office_visit": Vector3(-15.3, 0, 3.4),
		"lobby": Vector3(-8.0, 0, 6.6), "coffee": Vector3(0.55, 0, 5.4),
		"corridor_w": Vector3(-16.6, 0, 1.0), "corridor_mid": Vector3(-7.0, 0, 1.0),
		"corridor_e": Vector3(2.6, 0, 1.0), "server_door_out": Vector3(-3.0, 0, 1.2),
		"fenwick_bench": Vector3(-16.6, 0, -3.6), "clean": Vector3(-9.0, 0, -5.4),
		"hangar_in": Vector3(7.6, 0, 1.0), "cell_front": Vector3(13.0, 0, -8.2),
		"hangar_west": Vector3(8.0, 0, -9.5), "hangar_east": Vector3(14.5, 0, -6.0),
		"bay_hangar_in": Vector3(15.0, 0, 0.6), "catwalk": Vector3(11.0, UP, 1.0),
		"bay": Vector3(12.0, 0, 4.8), "fuse_box": Vector3(6.8, 0, 3.6),
		"car_park_w": Vector3(-16.0, 0, 17.5), "front_step": Vector3(-9.0, 0, 9.4),
		"car_park_e": Vector3(4.0, 0, 17.5), "yard": Vector3(22.0, 0, 5.0), "yard_n": Vector3(21.0, 0, -12.0),
	}


func voice_info() -> Dictionary:
	return {
		"labs_guard_a": {"who": "Briggs, a cheerful, chatty night guard in his thirties who loves a quiet night", "kokoro": "am_puck", "speed": 1.0},
		"labs_guard_b": {"who": "Rook, a dry, bored night guard in her forties who has seen it all", "kokoro": "af_river", "speed": 0.95},
		"labs_scientist": {"who": "Dr Lily Fenwick, a brilliant, scatterbrained scientist working late, who talks to herself", "kokoro": "bf_lily", "speed": 1.05},
		"labs_officer": {"who": "Officer Marsh, a sharp, no-nonsense security officer who loves her tea break", "kokoro": "af_sky", "speed": 1.0},
	}


func screenshot_views() -> Dictionary:
	return {
		"car_park": [Vector3(-7, 0, 19), 10.0, 5.0],
		"front": [Vector3(-9, 0, 11.6), 0.0, 10.0],
		"yard": [Vector3(24, 0, 9), 50.0, 8.0],
		"lobby": [Vector3(-5, 0, 7.4), 60.0, -5.0],
		"office": [Vector3(-17.3, 0, 2.7), -135.0, -10.0],
		"break": [Vector3(-3.4, 0, 2.6), -130.0, -10.0],
		"corridor": [Vector3(-16.5, 0, 1.0), -90.0, 0.0],
		"corridor_east": [Vector3(0, 0, 1.0), -90.0, 0.0],
		"chem": [Vector3(-12.6, 0, -0.6), 50.0, -10.0],
		"server": [Vector3(-3, 0, -0.6), 0.0, -10.0],
		"workshop": [Vector3(5.4, 0, -0.6), 40.0, -10.0],
		"duct": [Vector3(-14, 0, -9), -90.0, 0.0],
		"hangar": [Vector3(7.5, 0, 0.5), -30.0, 5.0],
		"cell": [Vector3(13, 0, -8.0), 0.0, -5.0],
		"rocket": [Vector3(13, 0, -11.4), 0.0, -15.0],
		"catwalk": [Vector3(7, UP, 1), -100.0, -15.0],
		"bay": [Vector3(16.5, 0, 6.5), 120.0, -5.0],
		"roof": [Vector3(-6, UP, 6), 30.0, -10.0],
		"hoard": [Vector3(2.6, 0, 2.6), -140.0, -10.0],
	}


func add_people(p_run: JobRun) -> Array:
	_run = p_run
	p_run.event_recorded.connect(_on_event)
	var guard_lines := {
		"spotted": ["Oi! The lab's closed!", "Stop right there!", "Intruder!"],
		"catch": ["Out you go. Visiting hours are over."],
		"lost": ["Where'd they go?", "I know you're in here."],
		"give_up": ["Must be the air con.", "Just the building settling.", "Pigeons, probably."],
		"alarm": ["The alarm! I'm on it!", "Someone's in!"],
		"wake": ["Wha...? Was I asleep? Don't tell Marsh."],
	}
	dobbs = Person.new()
	dobbs.setup("Briggs", SOLDIER, self, p_run, [
		{"at": "lobby", "time": 6.0, "face": Vector3(0, 0, 1), "say": "Quiet night. Love a quiet night."},
		{"at": "corridor_w", "time": 3.0, "clip": "look-around"},
		{"at": "corridor_e", "time": 2.0},
		{"at": "hangar_in", "time": 3.0},
		{"at": "cell_front", "time": 8.0, "face": Vector3(0, 0, -1), "clip": "look-around", "say": "Still there. Still a rocket."},
		{"at": "hangar_west", "time": 4.0},
		{"at": "hangar_in", "time": 2.0},
		{"at": "corridor_mid", "time": 3.0},
		{"at": "office_visit", "time": 8.0, "face": Vector3(1, 0, 0.5), "say": "Anything on the cameras, Marsh?"},
	], "labs_guard_a", {
		"torch": true, "answers_alarm": true, "fixes_power": true, "accepts": ["labcoat"], "mumble": "low",
		"lines": guard_lines.merged({"power_out": ["Lights! Hang on, I'll get the breaker."], "power_fixed": ["There. Let there be light."]}, true),
		"extra_lines": [COFFEE_LINE],
	})
	dobbs.position = points["lobby"]
	add_child(dobbs)
	_pocket(dobbs)
	rook = Person.new()
	rook.setup("Rook", SOLDIER, self, p_run, [
		{"at": "car_park_w", "time": 5.0, "say": "Car park's empty. Like my social life."},
		{"at": "front_step", "time": 3.0, "face": Vector3(0, 0, -1)},
		{"at": "car_park_e", "time": 3.0},
		{"at": "yard", "time": 4.0, "clip": "look-around"},
		{"at": "bay", "time": 4.0, "room": "bay", "leave_dark": true, "say": "Goods in. Goods still in."},
		{"at": "bay_hangar_in", "time": 2.0},
		{"at": "catwalk", "time": 6.0, "face": Vector3(0, 0, -1), "clip": "look-around", "say": "Pigeons again?"},
		{"at": "hangar_east", "time": 3.0},
		{"at": "bay", "time": 2.0},
		{"at": "yard_n", "time": 4.0},
	], "labs_guard_b", {
		"torch": true, "answers_alarm": true, "accepts": ["labcoat"], "mumble": "high",
		"lines": guard_lines.merged({"spotted": ["Hey! You!", "Oh, for... stop!", "Intruder!"], "wake": ["Mm? I was resting my eyes."]}, true),
	})
	rook.position = points["car_park_w"]
	add_child(rook)
	_pocket(rook)
	fenwick = Person.new()
	fenwick.setup("Dr Fenwick", "female-d", self, p_run, [
		{"at": "fenwick_bench", "time": 30.0, "face": Vector3(-1, 0, 0), "room": "chem", "say": "If Mr Hoard says \"improve\" one more time..."},
		{"at": "server_door_out", "time": 6.0, "face": Vector3(0, 0, -1), "say": CODE_LINE},
		{"at": "coffee", "time": 14.0, "face": Vector3(1, 0, 0), "room": "break", "leave_dark": true, "say": "Coffee. Then science. Then more coffee."},
		{"at": "clean", "time": 12.0, "clip": "look-around", "room": "clean", "leave_dark": true, "say": "Clean room's clean. Good clean room."},
	], "labs_scientist", {
		"mumble": "high",
		"lines": {
			"curious": ["Hello? Briggs, is that you?", "What was that?", "Hm?"],
			"seen": ["Who's that? You're not on my team."],
			"spotted": ["Security! Someone's in the labs!", "Who are you?"],
			"others": ["What's all the fuss?"],
			"lost": ["Where did they go?"],
			"give_up": ["I'm imagining things. Too much coffee.", "Probably the centrifuge."],
			"catch": ["Right. Out. This is a laboratory."],
			"wake": ["Oh! Did I fall asleep in the lab again?"],
		},
		"extra_lines": [COFFEE_LINE],
	})
	fenwick.position = points["fenwick_bench"]
	add_child(fenwick)
	fenwick.said.connect(_on_fenwick_said)
	marsh = LabsOfficer.new()
	marsh.setup("Officer Marsh", "female-a", self, p_run, [
		{"at": "monitors", "time": 999.0, "face": Vector3(1, 0, 0), "clip": "sit-watch", "room": "office", "sit": Vector3(-0.6, 0, 0), "say": "Right. Where was I?"},
	], "labs_officer", {
		"accepts": ["labcoat"], "mumble": "high",
		"lines": {
			"curious": ["Hm? Who's there?", "What was that?"],
			"seen": ["Is someone out there?"],
			"spotted": ["Intruder! Briggs! Rook!", "I can see you, you know!"],
			"lost": ["They've gone off camera."],
			"give_up": ["Nothing on the monitors.", "Back to the screens, then."],
			"catch": ["Gotcha. Out you go."],
			"wake": ["Huh? I wasn't asleep. I was monitoring."],
		},
		"extra_lines": [BREAK_LINE, RESET_LINE, CAMERA_LINE, COFFEE_LINE],
	})
	marsh.setup_breaks(60.0, 180.0, 45.0, BREAK_LINE)
	marsh.position = points["monitors"]
	add_child(marsh)
	for who in [dobbs, rook, fenwick, marsh]:
		# Follow the path closely: the narrow office and lab doorways catch
		# anyone who cuts the corner.
		(who as Person).agent.path_desired_distance = 0.2
	return [dobbs, rook, fenwick, marsh]
