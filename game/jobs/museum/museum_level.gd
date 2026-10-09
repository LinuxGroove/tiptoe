class_name MuseumLevel
extends JobLevel
## The Hoard Museum on its opening night: a gala in the grand hall, galleries
## either side, the founder's statue in the rotunda behind it, and the
## kitchen, staff corridor and security office round the back. X runs east, Z
## runs south towards the street, storeys are 2.5 m, and the hall and the
## rotunda are two storeys tall.
##
## Ground floor: the foyer (front, with the cloakroom to the west and the
## security office to the east), the grand hall with the buffet, the string
## quartet and the gong, the pirate gallery (west, its camera broken) and the
## castle gallery (east), the nature gallery (north-west), the rotunda
## (north), and the store room, staff room, kitchen and staff corridor
## (north-east and east). Upstairs: the balcony over the foyer where Hoard
## gives his toast, the curator's office, a landing, a walkway along the
## hall's west wall and the rotunda's upper gallery. The galleries and back
## rooms have flat roofs; the hall and rotunda roof is higher, with the
## skylight over the statue. Outside: the street and front steps, the
## sculpture garden with the plant room (the fuse box) to the west, and the
## kitchen yard to the north-east.
##
## The statue stands on a plinth inside a square of lasers (the north side
## blinks), watched by a camera on the rotunda's north wall. The routes to it:
##   The guard's birthday: two guests gossip the security office's code
##     (0912). While the guard is on his rounds or at the toast, key into the
##     office off the foyer, switch off the lasers and cameras at the panel,
##     and walk into the rotunda through the arch.
##   The waiter: from the kitchen yard, put on a waiter's jacket in the staff
##     room and take a tray of drinks from the pass; the cook, the head waiter
##     and the guard think nothing of a waiter at work. The service key by the
##     back door opens the store room's service door into the rotunda; dart
##     the camera and step through the north lasers while they blink off.
##   Lights out: the electrician's note in the sculpture garden says the plant
##     room's breaker takes everything with it. Flip it and the lights,
##     lasers, cameras and alarm all die while the guard walks all the way
##     round from the security office to fix it.
##   The skylight: from the roof (climb the yard's bins and the air
##     conditioning units, or start up there), lift the skylight, dart the
##     camera from above and drop inside the lasers onto the plinth. Climb
##     out at the blink and up the workmen's crates to the upper gallery.
##   The curator's keys: climb in at the cloakroom window from the front
##     steps, borrow an evening coat and the curator's keys from her handbag,
##     mingle up the grand stairs as a guest, and use the curator's office's
##     maintenance switch to turn off the rotunda's lasers and camera. The
##     keys open the walkway door to the upper gallery: drop down, take the
##     statue and climb back up the crates.
##   The toast: Hoard's toast pulls everyone into the hall facing the
##     balcony, the guard included, and the chatter stops. Any of the above
##     is easier while it lasts (and the gong by the quartet starts it early).

const UP := JobLevel.STOREY
const TOP := JobLevel.STOREY * 2.0

const ARENA := "res://assets/kenney/mini-arena/"
const STATION := "res://assets/kenney/space-station-kit/"
const CASTLE := "res://assets/kenney/castle-kit/"
const PIRATE := "res://assets/kenney/pirate-kit/"
const NATURE := "res://assets/kenney/nature-kit/"
const STATUE := ARENA + "statue.glb"
const TOADSTOOL := NATURE + "mushroom_redTall.glb"

const MARBLE := Color(0.86, 0.84, 0.79)
const MARBLE_DARK := Color(0.55, 0.53, 0.52)
const PARQUET := Color(0.5, 0.34, 0.21)
const GALLERY_WOOD := Color(0.43, 0.31, 0.22)
const RED_CARPET := Color(0.56, 0.12, 0.14)
const CLOAK_CARPET := Color(0.38, 0.2, 0.26)
const BLUE_CARPET := Color(0.24, 0.29, 0.4)
const STONE := Color(0.58, 0.58, 0.54)
const LINO := Color(0.6, 0.64, 0.58)
const KITCHEN_TILE := Color(0.8, 0.82, 0.8)
const CONCRETE := Color(0.5, 0.5, 0.49)
const ROOF := Color(0.3, 0.3, 0.32)
const GRASS := Color(0.22, 0.38, 0.2)
const HEDGE := Color(0.15, 0.29, 0.15)
const ROAD := Color(0.2, 0.2, 0.22)
const PLINTH_STONE := Color(0.92, 0.9, 0.86)
const CRATE := Color(0.62, 0.48, 0.3)
const BRONZE := Color(0.72, 0.52, 0.22)
const CLOTH_BLACK := Color(0.08, 0.08, 0.1)

## Lights off when the night starts.
const DARK_AT_START := ["store", "office", "landing", "plant_room"]
## Everything goes off with the plant room's breaker.
const CIRCUIT := ["foyer", "hall", "quartet", "walkway", "balcony", "office", "landing",
	"rotunda", "statue", "gallery", "nature", "pirates", "castles", "cloakroom",
	"security", "corridor", "kitchen", "store", "staff_room", "plant_room",
	"front", "yard", "garden"]

## The skylight's hole in the rotunda roof (x, z, width, depth).
const SKYLIGHT := Rect2(-1.5, -10.8, 3.0, 3.3)
const PLINTH_AT := Vector3(0, 0, -9)
const PLINTH_TOP := 0.9

## The pairs' gossip spots: guests stand either side of one of these.
const PAIR_SPOTS := {
	"p1_hall": Vector3(-2.2, 0, 1.6), "p1_pirates": Vector3(-12.2, 0, -0.6),
	"p1_buffet": Vector3(-1.8, 0, -1.9), "p1_castles": Vector3(10.6, 0, 1.0),
	"p2_castles": Vector3(10.6, 0, 4.0), "p2_hall": Vector3(1.8, 0, 3.4),
	"p2_nature": Vector3(-11.0, 0, -6.4), "p2_foyer": Vector3(-2.8, 0, 11.6),
	"p2_steps": Vector3(-2.6, 0, 15.6),
}

const INVITATION := """Augustus Hoard
requests the pleasure of your company
at the opening of
THE HOARD MUSEUM OF LOCAL HERITAGE

Champagne, canapés and a string quartet.
A toast from Mr Hoard on the balcony.
Coats to the cloakroom, please."""

const STAFF_NOTICE := """WAITING STAFF WANTED - TONIGHT

Two of my waiters are off with the sniffles.
Spare jackets in the staff room lockers.
Trays of drinks at the pass.

Anyone in a jacket with a tray in their hands is a waiter tonight.
Anyone in a jacket WITHOUT a tray will hear from me.

- Mr Pring, Head Waiter"""

const ELECTRICIAN_NOTE := """To the Hoard Museum,

Your plant room fuse box is older than the museum.
One flip of the main breaker and the whole lot goes off: lights, alarm, cameras, the fancy lasers, the lot.
Your guard will have to walk all the way round from his office to put it back.

Get it replaced. Please.
- Sparks & Sons, Electricians"""

const HOARD_LETTER := """Miss Finch,

The founder goes in the rotunda, on the big plinth. Lasers all round, and the good camera on him.
If anyone from Kettleford asks, he was "donated".

You keep asking about the skylight latch. It's a skylight. Nobody comes in through the roof.

And stop leaving your handbag in the cloakroom. Your keys open my office.

A. Hoard"""

const SPEECH_NOTES := """MY TOAST (practise in mirror)

1. Friends! Neighbours! People who owe me money!
2. Welcome. Pause for applause.
3. Everything was given freely. (Don't look at the Mayor.)
4. Point at the founder. Through the arch.
5. To Kettleford! And to me!

Photo from the hall. Tell Ron to come and stand in it.
He can leave his desk for one minute."""

const ROUNDS := """GUARD'S ROUNDS - R. Bassett

Desk. Foyer. Pirates. Nature. Look in on the founder.
Castles. Kitchen (sausage rolls). Back door. Desk.

The lasers and cameras: panel by the desk.
Do NOT switch them off for anyone but Mr Hoard.
Do NOT tell anyone the door code.

Note to self: the code is my birthday."""

const FOUNDER_LABEL := """THE FOUNDER
Bronze, 1874.

Stood in Kettleford's square for one hundred and fifty years.
Kindly lent to the Hoard Museum by the people of Kettleford.
(They have not been told.)"""

const PIRATE_LABEL := """THE PIRATE GALLERY

A cannon found on Kettleford beach,
a ship from the harbour master's mantelpiece,
and a sea chest nobody has opened.

All found. Some of it was still being used."""

## Doors that lock again behind the guard.
const RELOCK := ["security_door", "security_back"]

var party: MuseumParty
var pad: Keypad
var rotunda_cam: SecurityCamera
var skylight_open := false
var maintenance := false
var _skylight: UsableBody
var _toadstool: Node3D
## [AABB, amount]: the party's chatter drowning out noise in the hall.
var _chatter := []
var _murmur: AudioStreamPlayer3D
var _quartet: AudioStreamPlayer3D
var _castle_flag: Node3D
var _flag_flown := false
var _maint_switch: UsableBody


func build() -> void:
	circuit = CIRCUIT
	_marks()
	_grounds()
	_core()
	_west_wing()
	_east_wing()
	_plant_room()
	_roofs()
	_furnish_front()
	_furnish_hall()
	_furnish_upstairs()
	_furnish_rotunda()
	_furnish_galleries()
	_furnish_back()
	_lamps()
	_security()
	_things()
	_notes()
	# The museum, a storey at a time (its flat roofs are outside).
	house_boxes.append(AABB(Vector3(-6, -0.5, -14), Vector3(12, TOP - 0.1, 28)))
	house_boxes.append(AABB(Vector3(-16, -0.5, -14), Vector3(10, UP + 0.4, 22)))
	house_boxes.append(AABB(Vector3(-12, -0.5, 8), Vector3(6, UP + 0.4, 6)))
	house_boxes.append(AABB(Vector3(6, -0.5, -14), Vector3(10, UP + 0.4, 28)))
	indoor_boxes.append(AABB(Vector3(-24, -0.5, -14), Vector3(4, UP + 0.4, 4)))
	areas["plant_room"] = indoor_boxes[0]
	areas["rotunda"] = AABB(Vector3(-6, -0.5, -14), Vector3(12, TOP - 0.1, 10))
	areas["security"] = AABB(Vector3(6, -0.5, 8), Vector3(10, UP + 0.4, 6))
	areas["kitchen"] = AABB(Vector3(10, -0.5, -14), Vector3(6, UP + 0.4, 10))
	areas["office"] = AABB(Vector3(-6, UP - 0.5, 10), Vector3(6, UP, 4))
	# Where each disguise belongs: waiters in the kitchen and staff corridor,
	# nobody in the security office, the rotunda, the office or the plant room.
	add_zone("kitchen", AABB(Vector3(6, -1, -24), Vector3(16, UP + 1.0, 20)), ["waiter"])
	add_zone("corridor", AABB(Vector3(14, -1, -4), Vector3(2, UP + 1.0, 12)), ["waiter"])
	add_zone("security", AABB(Vector3(6, -1, 8), Vector3(10, UP + 1.0, 6)), [])
	add_zone("rotunda", AABB(Vector3(-6, -1, -14), Vector3(12, TOP + 0.5, 10)), [])
	add_zone("office", AABB(Vector3(-6, UP - 0.5, 10), Vector3(6, UP, 4)), [])
	add_zone("plant_room", AABB(Vector3(-24, -1, -14), Vector3(4, UP + 1.0, 4)), [])
	# The party's chatter masks footsteps in the hall, until the toast.
	_chatter = [AABB(Vector3(-6, -1, -4), Vector3(12, TOP + 1.0, 18)), 0.5]
	masking.append(_chatter)
	add_masking(AABB(Vector3(10, -1, -14), Vector3(6, UP + 1.0, 10)), 0.3)
	for room in lights:
		set_lights(room, not room in DARK_AT_START)


# --- The building --------------------------------------------------------------

func _grounds() -> void:
	Kit.block(self, Vector3(-3, -0.06, 0), Vector3(58, 0.1, 60), "grass", Kit.flat(GRASS))
	# The front: a paved square, the red carpet and the street.
	Kit.block(self, Vector3(0, -0.04, 17.5), Vector3(32, 0.08, 7), "concrete", Kit.flat(CONCRETE))
	Kit.block(self, Vector3(0, -0.02, 17.5), Vector3(2.2, 0.06, 7), "carpet", Kit.flat(RED_CARPET), false)
	Kit.block(self, Vector3(-3, -0.06, 25.5), Vector3(58, 0.1, 9), "concrete", Kit.flat(ROAD))
	# The kitchen yard and the garden paths.
	Kit.block(self, Vector3(14, -0.04, -19), Vector3(16, 0.08, 10), "concrete", Kit.flat(CONCRETE))
	Kit.block(self, Vector3(-21, -0.035, -2), Vector3(1.4, 0.07, 22), "concrete", Kit.flat(STONE))
	Kit.block(self, Vector3(-18.5, -0.035, -9), Vector3(5, 0.07, 1.4), "concrete", Kit.flat(STONE))
	# Hedges all round (too tall to climb).
	var hedge := Kit.flat(HEDGE)
	Kit.block(self, Vector3(-31, 1.3, 0), Vector3(1, 2.6, 60), "", hedge)
	Kit.block(self, Vector3(25, 1.3, 0), Vector3(1, 2.6, 60), "", hedge)
	Kit.block(self, Vector3(-3, 1.3, -29.5), Vector3(57, 2.6, 1), "", hedge)
	Kit.block(self, Vector3(-3, 1.3, 29.5), Vector3(57, 2.6, 1), "", hedge)
	# Low hedges between the front square and the garden and yard.
	Kit.block(self, Vector3(-22, 0.6, 14), Vector3(16, 1.2, 0.8), "", hedge)
	Kit.block(self, Vector3(21.5, 0.6, 14), Vector3(7, 1.2, 0.8), "", hedge)
	# The caterer's van and the yard's bins, which make the climb to the roof.
	Kit.block(self, Vector3(20, 1.0, -20), Vector3(2.2, 2.0, 4.6), "", Kit.flat(Color(0.92, 0.92, 0.9)))
	Kit.block(self, Vector3(16.6, 0.55, -9), Vector3(0.8, 1.1, 1.4), "concrete", Kit.flat(Color(0.2, 0.33, 0.24)))
	Kit.block(self, Vector3(16.6, 0.45, -10.6), Vector3(0.8, 0.9, 1.0), "concrete", Kit.flat(Color(0.25, 0.25, 0.3)))
	# A stack of deliveries by the cloakroom, up to its roof.
	Kit.boxed(self, PIRATE + "crate.glb", Vector3(-12.75, 0, 12.4), 90, 1.0, "wood")
	Kit.block(self, Vector3(-12.7, 1.05, 12.4), Vector3(1.0, 0.5, 1.0), "wood", Kit.flat(CRATE))
	# Trees.
	for t in [Vector3(-27, 0, -24), Vector3(-27, 0, 8), Vector3(-13, 0, -24), Vector3(4, 0, -24), Vector3(21, 0, 10), Vector3(-26, 0, 21), Vector3(20, 0, 21)]:
		var tree := Kit.boxed(self, NATURE + "tree_oak.glb", t, randf() * 360.0, 4.0)
		var cs: CollisionShape3D = tree.get_child(1)
		cs.shape.size = Vector3(0.5, 4.0, 0.5)
		cs.position = Vector3(0, 2.0, 0)


func _core() -> void:
	# Foyer, hall and rotunda floors.
	floor_rect(0, -6, 8, 6, 14, "tile", MARBLE, false)
	floor_rect(0, -6, -4, 6, 8, "wood", PARQUET, false)
	floor_rect(0, -6, -14, 6, -4, "tile", MARBLE, false)
	# The foyer: the front doors stand open for the gala.
	line(0, Vector2(-6, 14), Vector2(1, 0), "ww..ww")
	openings.append({"id": "front_doors", "kind": "door", "pos": Vector3(0, 1.0, 14)})
	line(0, Vector2(-6, 8), Vector2(0, 1), "WdW")
	line(0, Vector2(6, 8), Vector2(0, 1), "DwW", [
		{"id": "security_door", "into": Vector2(8, 9), "locked": true, "model": "door-rotate-square-b.glb"}])
	line(0, Vector2(-6, 8), Vector2(1, 0), "WW..WW")
	# The hall: doorways to the galleries, the arch to the rotunda.
	line(0, Vector2(-6, -4), Vector2(0, 1), "WddWWW")
	line(0, Vector2(6, -4), Vector2(0, 1), "WddWWW")
	line(0, Vector2(-6, -4), Vector2(1, 0), "WW..WW")
	# The rotunda.
	line(0, Vector2(-6, -14), Vector2(0, 1), "WWWWW")
	line(0, Vector2(-6, -14), Vector2(1, 0), "WWWWWW")
	line(0, Vector2(6, -14), Vector2(0, 1), "WDWWW", [
		{"id": "service_door", "into": Vector2(8, -11), "locked": true, "key": "service_key", "pick": 10.0, "key_verb": "Unlock it with the service key"}])
	# Upstairs over the foyer: the balcony, the curator's office and a landing.
	floor_rect(UP, -6, 8, 6, 10, "carpet", RED_CARPET)
	floor_rect(UP, -6, 10, 0, 14, "carpet", CLOAK_CARPET)
	floor_rect(UP, 0, 10, 6, 14, "wood", GALLERY_WOOD)
	line(UP, Vector2(-6, 14), Vector2(1, 0), "wWWWWw")
	line(UP, Vector2(-6, 8), Vector2(0, 1), "WoW", ["office_window"])
	line(UP, Vector2(6, 8), Vector2(0, 1), "WoW", ["landing_window"])
	line(UP, Vector2(-4, 8), Vector2(1, 0), "----")
	line(UP, Vector2(-6, 10), Vector2(1, 0), "WDWdWW", [
		{"id": "office_door", "into": Vector2(-3, 12), "locked": true, "key": "curator_keys", "pick": 10.0, "key_verb": "Unlock it with the curator's keys"}])
	line(UP, Vector2(0, 10), Vector2(0, 1), "WW")
	# The hall's upper walls and the walkway along its west side.
	floor_rect(UP, -6, -4, -4, 8, "wood", GALLERY_WOOD)
	line(UP, Vector2(-6, -4), Vector2(0, 1), "WwWwWW")
	line(UP, Vector2(6, -4), Vector2(0, 1), "WwWwWW")
	line(UP, Vector2(-6, -4), Vector2(1, 0), "DWWWWW", [
		{"id": "gallery_door", "into": Vector2(-5, -6), "locked": true, "key": "curator_keys", "pick": 8.0, "key_verb": "Unlock it with the curator's keys"}])
	line(UP, Vector2(-4, -4), Vector2(0, 1), "------")
	# The rotunda's upper walls and its upper gallery, open at the north end
	# where the workmen's crates come up.
	floor_rect(UP, -6, -14, -4, -4, "wood", GALLERY_WOOD)
	line(UP, Vector2(-6, -14), Vector2(0, 1), "wWwWw")
	line(UP, Vector2(-6, -14), Vector2(1, 0), "WwWWwW")
	line(UP, Vector2(6, -14), Vector2(0, 1), "WWwWW")
	line(UP, Vector2(-4, -14), Vector2(0, 1), ".----")
	# A beam under the gallery's edge by the crates, to climb onto.
	Kit.block(self, Vector3(-4.0, 1.95, -12.5), Vector3(0.12, 1.1, 3.0), "wood", Kit.flat(GALLERY_WOOD), false)
	# The grand stairs climb south up the hall's east side to the balcony.
	Kit.model(self, Kit.BUILDING + "stairs-closed.glb", Vector3(5.0, 0, 6), 0.0)
	var stairs := StaticBody3D.new()
	stairs.collision_layer = Kit.LAYER_WORLD
	stairs.collision_mask = 0
	var cs := CollisionShape3D.new()
	var wedge := ConvexPolygonShape3D.new()
	var pts := PackedVector3Array()
	for x in [4.35, 5.65]:
		pts.append_array([Vector3(x, 0, 3.9), Vector3(x, 0, 8), Vector3(x, UP, 8), Vector3(x, UP, 7.5)])
	wedge.points = pts
	cs.shape = wedge
	stairs.add_child(cs)
	add_child(stairs)
	Kit.add_surface(stairs, "carpet")
	stairs.add_to_group(Kit.NAV_GROUP)


func _west_wing() -> void:
	# The nature gallery.
	floor_rect(0, -16, -14, -6, -4, "tile", STONE, false)
	line(0, Vector2(-16, -14), Vector2(0, 1), "wwDww", [
		{"id": "garden_door", "into": Vector2(-14, -9), "locked": true, "pick": 6.0, "outside": true}])
	line(0, Vector2(-16, -14), Vector2(1, 0), "wWwWw")
	line(0, Vector2(-16, -4), Vector2(1, 0), "WWdWW")
	# The pirate gallery.
	floor_rect(0, -16, -4, -6, 8, "wood", GALLERY_WOOD, false)
	line(0, Vector2(-16, -4), Vector2(0, 1), "wwWWww")
	line(0, Vector2(-16, 8), Vector2(1, 0), "wwWWW")
	# The cloakroom, its window left open for the air.
	floor_rect(0, -12, 8, -6, 14, "carpet", CLOAK_CARPET, false)
	line(0, Vector2(-12, 8), Vector2(0, 1), "WWW")
	line(0, Vector2(-12, 14), Vector2(1, 0), "WoW", ["cloak_window"])


func _east_wing() -> void:
	# The castle gallery.
	floor_rect(0, 6, -4, 14, 8, "wood", GALLERY_WOOD, false)
	line(0, Vector2(14, -4), Vector2(0, 1), "WWDWWW", [{"id": "staff_door", "into": Vector2(15, 1)}])
	# The staff corridor.
	floor_rect(0, 14, -4, 16, 8, "tile", LINO, false)
	line(0, Vector2(16, -4), Vector2(0, 1), "WWWWWW")
	# The security office.
	floor_rect(0, 6, 8, 16, 14, "carpet", BLUE_CARPET, false)
	line(0, Vector2(6, 8), Vector2(1, 0), "WWWWD", [
		{"id": "security_back", "into": Vector2(15, 10), "locked": true, "pick": 6.0}])
	line(0, Vector2(6, 14), Vector2(1, 0), "wwwww")
	line(0, Vector2(16, 8), Vector2(0, 1), "WWW")
	# The kitchen, the store room and the staff room.
	floor_rect(0, 10, -14, 16, -4, "tile", KITCHEN_TILE, false)
	floor_rect(0, 6, -14, 10, -8, "concrete", CONCRETE, false)
	floor_rect(0, 6, -8, 10, -4, "tile", LINO, false)
	line(0, Vector2(6, -4), Vector2(1, 0), "WWWWd")
	line(0, Vector2(16, -14), Vector2(0, 1), "WwWwW")
	line(0, Vector2(10, -14), Vector2(1, 0), "WDW", [{"id": "kitchen_back", "into": Vector2(13, -12), "outside": true}])
	line(0, Vector2(6, -14), Vector2(1, 0), "WW")
	line(0, Vector2(10, -14), Vector2(0, 1), "WdWdW")
	line(0, Vector2(6, -8), Vector2(1, 0), "WW")


## The plant room: a brick shed in the sculpture garden with the fuse box.
func _plant_room() -> void:
	floor_rect(0, -24, -14, -20, -10, "concrete", CONCRETE, false)
	line(0, Vector2(-24, -14), Vector2(1, 0), "WW")
	line(0, Vector2(-24, -10), Vector2(1, 0), "WW")
	line(0, Vector2(-24, -14), Vector2(0, 1), "WW")
	line(0, Vector2(-20, -14), Vector2(0, 1), "WD", [
		{"id": "plant_room_door", "into": Vector2(-22, -11), "locked": true, "pick": 5.0}])
	floor_rect(UP, -24, -14, -20, -10, "concrete", ROOF)


func _roofs() -> void:
	floor_rect(UP, 6, -14, 16, 14, "concrete", ROOF)
	floor_rect(UP, -16, -14, -6, 8, "concrete", ROOF)
	floor_rect(UP, -12, 8, -6, 14, "concrete", ROOF)
	# The high roof, round the skylight's hole.
	var s := SKYLIGHT
	floor_rect(TOP, -6, -14, 6, s.position.y, "concrete", ROOF)
	floor_rect(TOP, -6, s.end.y, 6, 14, "concrete", ROOF)
	floor_rect(TOP, -6, s.position.y, s.position.x, s.end.y, "concrete", ROOF)
	floor_rect(TOP, s.end.x, s.position.y, 6, s.end.y, "concrete", ROOF)
	# Air conditioning units: the steps from the low roofs to the high one.
	var unit := Kit.flat(Color(0.7, 0.72, 0.74))
	Kit.block(self, Vector3(6.75, UP + 0.6, -11.5), Vector3(1.3, 1.2, 1.6), "concrete", unit)
	Kit.block(self, Vector3(-6.75, UP + 0.6, 1.0), Vector3(1.3, 1.2, 1.6), "concrete", unit)
	for at in [Vector3(12, UP, -10), Vector3(-11, UP, -9)]:
		Kit.block(self, at + Vector3(0, 0.4, 0), Vector3(1.0, 0.8, 1.0), "concrete", unit)
	# A parapet sign over the front doors.
	var sign := Label3D.new()
	sign.text = "THE HOARD MUSEUM\nof Local Heritage"
	sign.font_size = 96
	sign.pixel_size = 0.006
	sign.outline_size = 16
	sign.modulate = Color(0.95, 0.85, 0.55)
	sign.position = Vector3(0, 3.2, 14.12)
	add_child(sign)


# --- Furnishing -----------------------------------------------------------------

func _furnish_front() -> void:
	# The foyer.
	Kit.block(self, Vector3(0, 0.01, 11), Vector3(2.2, 0.02, 6), "carpet", Kit.flat(RED_CARPET), false)
	Kit.furniture(self, "pottedPlant", Vector3(-5.4, 0, 13.4), 0)
	Kit.furniture(self, "pottedPlant", Vector3(5.4, 0, 13.4), 0)
	Kit.furniture(self, "bench", Vector3(-4.0, 0, 9.0), 0)
	# The cloakroom: a counter, racks of coats and a hiding place among them.
	Kit.furniture(self, "kitchenBar", Vector3(-7.7, 0, 9.4), 90)
	Kit.furniture(self, "kitchenBar", Vector3(-7.7, 0, 12.6), 90)
	for z in [9.0, 10.2, 11.4]:
		Kit.furniture(self, "coatRackStanding", Vector3(-11.4, 0, z), 0)
		_coat(Vector3(-11.4, 0, z))
	for x in [-10.6, -9.6]:
		Kit.furniture(self, "coatRackStanding", Vector3(x, 0, 8.6), 0)
		_coat(Vector3(x, 0, 8.6))
	hide_spot("coats", "Hide among the coats", Vector3(-11.3, 0, 12.8), 90, Vector3(0, 1.3, 0), Vector3(0.8, 1.9, 1.0))
	# Lamp posts on the front square.
	for x in [-6.0, 6.0]:
		Kit.block(self, Vector3(x, 2.0, 19.5), Vector3(0.15, 4.0, 0.15), "", Kit.flat(Color(0.18, 0.18, 0.2)), false)


## A coat hanging on a rack.
func _coat(at: Vector3) -> void:
	_mesh(self, at + Vector3(0.0, 1.05, 0.05), Vector3(0.45, 0.85, 0.22), Color(randf_range(0.1, 0.4), 0.12, randf_range(0.12, 0.3)))


func _furnish_hall() -> void:
	# The buffet along the north wall.
	Kit.furniture(self, "tableCloth", Vector3(-4.6, 0, -3.35), 0)
	Kit.furniture(self, "tableCloth", Vector3(-2.9, 0, -3.35), 0)
	var food := [["cake-birthday.glb", -5.0, 0.7], ["cheese.glb", -4.2, 0.6], ["sandwich.glb", -3.5, 0.8],
		["sandwich.glb", -3.1, 0.8], ["donut.glb", -2.6, 1.2], ["cake.glb", -2.3, 0.7]]
	for f in food:
		Kit.model(self, Kit.FOOD + f[0], Vector3(f[1], 0.66, -3.4), randf() * 360.0, f[2])
	for x in [-5.2, -4.8, -3.8, -2.0]:
		Kit.model(self, Kit.FOOD + "glass-wine.glb", Vector3(x, 0.66, -3.1), 0, 0.45)
	# Cocktail tables.
	for at in [Vector3(3.6, 0, -2.6), Vector3(-1.2, 0, 6.8), Vector3(2.0, 0, -0.4)]:
		# The model's top sits at its origin, with the legs below.
		Kit.furniture(self, "tableRound", at + Vector3(0, 0.54, 0), 0)
		Kit.model(self, Kit.FOOD + "glass-wine.glb", at + Vector3(0.1, 0.72, 0), 0, 0.45)
	# The string quartet's corner, under the walkway: two chairs and a stand.
	Kit.furniture(self, "chairCushion", Vector3(-5.25, 0, 5.0), 90, false)
	Kit.furniture(self, "chairCushion", Vector3(-5.25, 0, 6.6), 90, false)
	_mesh(self, Vector3(-4.45, 0.55, 5.8), Vector3(0.05, 1.1, 0.05), Color(0.15, 0.15, 0.15))
	_mesh(self, Vector3(-4.45, 1.12, 5.8), Vector3(0.06, 0.32, 0.45), Color(0.15, 0.15, 0.15))
	_quartet = Sfx.on(self, "quartet_loop", -12.0)
	_quartet.position = Vector3(-5, 1.5, 5.8)
	# The gong.
	for z in [2.4, 3.6]:
		_mesh(self, Vector3(-5.2, 0.9, z), Vector3(0.08, 1.8, 0.08), Color(0.3, 0.18, 0.1))
	_mesh(self, Vector3(-5.2, 1.78, 3.0), Vector3(0.08, 0.08, 1.3), Color(0.3, 0.18, 0.1))
	var disc := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.45
	cm.bottom_radius = 0.45
	cm.height = 0.04
	cm.material = Kit.flat(BRONZE, 0.4)
	disc.mesh = cm
	disc.position = Vector3(-5.2, 1.15, 3.0)
	disc.rotation.z = PI * 0.5
	add_child(disc)
	# Banners and the founder's name over the arch.
	for z in [-1.0, 3.0]:
		Kit.model(self, ARENA + "banner.glb", Vector3(5.85, 2.9, z), -90, 2.0)
	var over := Label3D.new()
	over.text = "THE FOUNDER"
	over.font_size = 64
	over.pixel_size = 0.006
	over.modulate = Color(0.95, 0.85, 0.55)
	over.position = Vector3(0, 2.75, -3.9)
	add_child(over)
	_murmur = Sfx.on(self, "crowd_murmur_loop", -8.0)
	_murmur.position = Vector3(0, 2.0, 2.0)
	_murmur.max_distance = 26.0


func _furnish_upstairs() -> void:
	# The balcony: Hoard's lectern.
	Kit.block(self, Vector3(1.2, UP + 0.55, 9.5), Vector3(0.5, 1.1, 0.4), "wood", Kit.flat(GALLERY_WOOD))
	# The curator's office.
	Kit.furniture(self, "desk", Vector3(-3.0, UP, 13.4), 180)
	Kit.furniture(self, "chairDesk", Vector3(-3.0, UP, 12.6), 0)
	Kit.furniture(self, "bookcaseClosed", Vector3(-5.6, UP, 12.6), 90)
	Kit.furniture(self, "bookcaseOpen", Vector3(-0.5, UP, 13.4), -90)
	Kit.model(self, NATURE + "statue_head.glb", Vector3(-1.2, UP, 10.6), 200, 0.6)
	# The landing: boxes of things not on show yet.
	for b in [Vector3(4.6, UP, 13.3), Vector3(5.3, UP, 12.7), Vector3(2.0, UP, 13.4)]:
		Kit.furniture(self, "cardboardBoxClosed", b, randf() * 40.0)
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(0.6, UP, 12.2), 90)
	hide_spot("landing_cupboard", "Hide in the cupboard", Vector3(0.6, UP, 12.2), 90, Vector3(0, 1.3, 0), Vector3(0.6, 1.8, 1.0))
	# Benches along the walkway, for the view.
	Kit.furniture(self, "bench", Vector3(-5.6, UP, 1.0), 90)
	Kit.furniture(self, "bench", Vector3(-5.6, UP, 5.0), 90)


func _furnish_rotunda() -> void:
	# The plinth, inside a square of lasers. The north side blinks.
	Kit.block(self, PLINTH_AT + Vector3(0, PLINTH_TOP * 0.5, 0), Vector3(1.3, PLINTH_TOP, 1.3), "tile", Kit.flat(PLINTH_STONE))
	Kit.block(self, PLINTH_AT + Vector3(0, 0.05, 0), Vector3(1.6, 0.1, 1.6), "tile", Kit.flat(MARBLE_DARK))
	lasers("rotunda_south", Vector3(-2, 0, -7), Vector3(2, 0, -7))
	lasers("rotunda_west", Vector3(-2, 0, -11), Vector3(-2, 0, -7))
	lasers("rotunda_east", Vector3(2, 0, -11), Vector3(2, 0, -7))
	lasers("rotunda_north", Vector3(-2, 0, -11), Vector3(2, 0, -11), [0.35, 0.9, 1.45], 6.0)
	rotunda_cam = camera("rotunda", Vector3(0, 3.0, -13.88), 0, {"sweep": 30.0, "period": 10.0, "pitch": 30.0})
	note("founder_label", "A label on a stand", FOUNDER_LABEL, Vector3(0, 1.0, -6.3), 0, Vector3(0.4, 0.3, 0.02))
	_mesh(self, Vector3(0, 0.45, -6.33), Vector3(0.06, 0.9, 0.06), Color(0.2, 0.2, 0.22))
	# Display cases of smaller "loans" round the walls.
	for at in [Vector3(-4.6, 0, -6.0), Vector3(4.6, 0, -6.4), Vector3(4.6, 0, -13.0)]:
		Kit.boxed(self, STATION + "table-display.glb", at + Vector3(0, 0.42, 0), 90, 1.4)
	Kit.model(self, PIRATE + "bottle.glb", Vector3(-4.6, 0.85, -6.0), 0, 0.5)
	Kit.model(self, Kit.FOOD + "cake.glb", Vector3(4.6, 0.85, -6.4), 0, 0.6)
	Kit.model(self, CASTLE + "flag.glb", Vector3(4.6, 0.85, -13.0), 90, 0.8)
	# The workmen's crates: a way up to the upper gallery.
	Kit.boxed(self, PIRATE + "crate.glb", Vector3(-3.0, 0, -12.8), 0, 1.0, "wood")
	Kit.boxed(self, PIRATE + "crate.glb", Vector3(-3.25, 0.77, -13.15), 90, 0.9, "wood")
	Kit.furniture(self, "cardboardBoxOpen", Vector3(-1.6, 0, -13.2), 20)
	_mesh(self, Vector3(-2.2, 0.01, -12.0), Vector3(1.6, 0.02, 1.2), Color(0.85, 0.85, 0.8))


func _furnish_galleries() -> void:
	# Nature: the village green's stone head, obelisks and columns.
	for p in [[Vector3(-11, 0, -10.5), "statue_head.glb", 2.0, 0.0], [Vector3(-14, 0, -12.4), "statue_obelisk.glb", 2.4, 0.0],
			[Vector3(-8, 0, -12.4), "statue_obelisk.glb", 2.4, 0.0], [Vector3(-14.4, 0, -6), "statue_column.glb", 2.2, 0.0],
			[Vector3(-7.6, 0, -6), "statue_columnDamaged.glb", 2.2, 0.0], [Vector3(-11, 0, -13.2), "statue_ring.glb", 2.0, 0.0]]:
		Kit.block(self, p[0] + Vector3(0, 0.15, 0), Vector3(1.2, 0.3, 1.2), "tile", Kit.flat(PLINTH_STONE))
		Kit.boxed(self, NATURE + p[1], p[0] + Vector3(0, 0.3, 0), p[3], p[2], "tile")
	for at in [Vector3(-15.2, 0, -5.0), Vector3(-6.8, 0, -9.0)]:
		Kit.boxed(self, NATURE + "pot_large.glb", at, 0, 2.5)
		Kit.model(self, NATURE + "plant_bushDetailed.glb", at + Vector3(0, 0.45, 0), 0, 1.6)
	# Pirates: the ship on a long table, the cannon, the sea chest and barrels.
	Kit.boxed(self, STATION + "table-large.glb", Vector3(-12, 0, 4.5), 90, 2.0)
	Kit.model(self, PIRATE + "ship-pirate-small.glb", Vector3(-12, 0.8, 4.5), 0, 0.22)
	Kit.boxed(self, PIRATE + "cannon.glb", Vector3(-9.2, 0, 0.5), 30, 1.0)
	Kit.boxed(self, PIRATE + "chest.glb", Vector3(-15.1, 0, -2.6), 90, 0.6)
	Kit.boxed(self, PIRATE + "crate-bottles.glb", Vector3(-15.2, 0, 1.0), 90, 0.8)
	Kit.boxed(self, PIRATE + "barrel.glb", Vector3(-15.1, 0, 6.9), 0, 0.9)
	hide_spot("barrel", "Climb into the barrel", Vector3(-15.1, 0, 6.9), 90, Vector3(0, 0.95, 0), Vector3(1.2, 1.1, 1.2))
	for at in [Vector3(-8.0, 0, 6.6), Vector3(-8.4, 0, -3.0)]:
		Kit.boxed(self, STATION + "table-display-small.glb", at + Vector3(0, 0.42, 0), 0, 1.4)
	Kit.model(self, PIRATE + "bottle.glb", Vector3(-8.0, 0.85, 6.6), 0, 0.5)
	Kit.model(self, PIRATE + "bottle.glb", Vector3(-8.4, 0.85, -3.0), 0, 0.5)
	note("pirate_label", "A label in the pirate gallery", PIRATE_LABEL, Vector3(-6.07, 1.4, 4.6), -90)
	# Its camera's been broken for weeks.
	var broken := Kit.model(self, SecurityCamera.MODEL, Vector3(-11, 2.3, -3.88), 0)
	broken.rotation.z = deg_to_rad(28)
	var label := Label3D.new()
	label.text = "OUT OF ORDER"
	label.font_size = 28
	label.pixel_size = 0.004
	label.position = Vector3(-11, 2.0, -3.9)
	add_child(label)
	# Castles: siege engines, the model castle on its table, banners.
	Kit.boxed(self, CASTLE + "siege-catapult.glb", Vector3(8.6, 0, -2.0), 160, 1.2)
	Kit.boxed(self, CASTLE + "siege-trebuchet.glb", Vector3(12.0, 0, -2.2), 200, 1.2)
	Kit.boxed(self, CASTLE + "siege-ballista.glb", Vector3(8.6, 0, 6.4), 30, 1.1)
	Kit.boxed(self, STATION + "table-large.glb", Vector3(12.4, 0, 5.8), 90, 1.4)
	Kit.model(self, CASTLE + "tower-square.glb", Vector3(12.4, 0.56, 5.8), 0, 1.0)
	_castle_flag = Kit.model(self, CASTLE + "flag.glb", Vector3(12.4, 1.87, 5.8), 0, 0.7)
	for z in [-0.5, 3.5]:
		Kit.model(self, CASTLE + "flag-banner-long.glb", Vector3(13.85, 0.3, z), -90, 0.9)
	camera("castles", Vector3(10, 2.3, -3.88), 0, {"sweep": 40.0, "pitch": 25.0, "accepts": ["guest", "waiter"]})


func _furnish_back() -> void:
	# The kitchen: stoves and counters, the island, the pass with its trays.
	for z in [-12.6, -11.7]:
		Kit.furniture(self, "kitchenStove", Vector3(15.55, 0, z), -90)
	for z in [-10.8, -9.9, -7.0, -6.1]:
		Kit.furniture(self, "kitchenCabinet", Vector3(15.55, 0, z), -90)
	Kit.furniture(self, "kitchenSink", Vector3(15.55, 0, -5.2), -90)
	Kit.furniture(self, "kitchenFridgeLarge", Vector3(10.6, 0, -13.4), 0)
	Kit.furniture(self, "kitchenCabinet", Vector3(12.6, 0, -9.0), 0)
	Kit.furniture(self, "kitchenCabinet", Vector3(13.5, 0, -9.0), 0)
	Kit.furniture(self, "kitchenCabinet", Vector3(12.6, 0, -9.9), 180)
	Kit.furniture(self, "kitchenCabinet", Vector3(13.5, 0, -9.9), 180)
	Kit.furniture(self, "kitchenBar", Vector3(11.3, 0, -5.3), 0)
	Kit.furniture(self, "kitchenBar", Vector3(12.2, 0, -5.3), 0)
	var hum := Sfx.on(self, "fridge_hum_loop", -16.0)
	hum.position = Vector3(10.6, 1.0, -13.2)
	# The staff room: lockers and a bench.
	for x in [6.8, 7.6, 8.4]:
		Kit.furniture(self, "bookcaseClosed", Vector3(x, 0, -7.6), 0)
	Kit.furniture(self, "bench", Vector3(7.6, 0, -4.6), 0)
	# The store room: crates of next month's "donations".
	for at in [Vector3(7.0, 0, -13.2), Vector3(9.2, 0, -13.2), Vector3(7.1, 0, -9.0)]:
		Kit.boxed(self, PIRATE + "crate.glb", at, randf() * 20.0, 1.0, "wood")
	Kit.boxed(self, STATION + "container-tall.glb", Vector3(9.3, 0, -9.0), 0, 2.0)
	hide_spot("store_crate", "Hide in the packing case", Vector3(9.3, 0, -9.0), -90, Vector3(0, 1.3, 0), Vector3(1.2, 1.8, 1.2))
	# The security office: the desk under the window onto the foyer.
	Kit.furniture(self, "desk", Vector3(6.9, 0, 11.0), 90)
	Kit.furniture(self, "chairDesk", Vector3(7.9, 0, 11.0), 90, false)
	Kit.model(self, STATION + "computer-screen.glb", Vector3(6.85, 0.76, 10.7), 90, 0.7)
	Kit.model(self, STATION + "computer-screen.glb", Vector3(6.85, 0.76, 11.4), 90, 0.7)
	Kit.model(self, Kit.FOOD + "mug.glb", Vector3(7.1, 0.76, 11.8), 0, 0.5)
	for z in [9.2, 10.0, 10.8]:
		Kit.furniture(self, "bookcaseClosed", Vector3(15.6, 0, z), -90)
	hide_spot("locker", "Hide in the locker", Vector3(15.6, 0, 12.6), -90, Vector3(0, 1.3, 0), Vector3(0.8, 1.9, 0.6))
	Kit.furniture(self, "bookcaseClosed", Vector3(15.6, 0, 12.6), -90)
	Kit.furniture(self, "loungeSofa", Vector3(12.0, 0, 13.3), 180)
	# The sculpture garden.
	for p in [[Vector3(-26, 0, -4), "statue_obelisk.glb", 3.0], [Vector3(-26, 0, 2), "statue_column.glb", 2.6],
			[Vector3(-18, 0, 4), "statue_ring.glb", 2.4]]:
		Kit.boxed(self, NATURE + p[1], p[0], 0, p[2], "concrete")
	for at in [Vector3(-23.4, 0, -8.2), Vector3(-25.0, 0, -8.6), Vector3(-26.2, 0, -7.4), Vector3(-17.8, 0, -12.0)]:
		Kit.model(self, TOADSTOOL, at, randf() * 360.0, 3.0)
	for at in [Vector3(-19, 0, 0), Vector3(-24, 0, 6), Vector3(-19, 0, -16)]:
		Kit.boxed(self, NATURE + "plant_bushDetailed.glb", at, 0, 2.5)
	# A compost bin by the pirate gallery, up to its roof.
	Kit.block(self, Vector3(-16.6, 0.6, 3.0), Vector3(0.9, 1.2, 1.2), "wood", Kit.flat(Color(0.3, 0.24, 0.16)))


func _lamps() -> void:
	# The hall: big lamps hung from the high ceiling, and the quartet's corner.
	for at in [Vector3(-2, TOP, -1), Vector3(2.5, TOP, -1), Vector3(-1, TOP, 4), Vector3(2.5, TOP, 4)]:
		lamp("hall", at, true, 1.6, 9.0)
	lamp("quartet", Vector3(-5, UP, 5.8), true, 0.9, 4.5)
	lamp("walkway", Vector3(-5, TOP, 2), true, 0.8, 5.0)
	lamp("foyer", Vector3(0, UP, 11), true, 1.4, 7.0)
	lamp("balcony", Vector3(0, TOP, 9), true, 1.0, 5.0)
	lamp("office", Vector3(-3, TOP, 12), false, 1.0, 5.0)
	lamp("landing", Vector3(3, TOP, 12), false, 0.8, 5.0)
	lamp("cloakroom", Vector3(-9, UP, 11), true, 0.8, 5.0)
	# The rotunda: dim, with a spotlight on the founder.
	lamp("rotunda", Vector3(-3.5, TOP, -6.5), true, 0.7, 6.0)
	lamp("rotunda", Vector3(3.5, TOP, -6.5), true, 0.7, 6.0)
	lamp("rotunda", Vector3(3.5, TOP, -12), true, 0.6, 5.0)
	var spot := SpotLight3D.new()
	spot.position = Vector3(0, 4.7, -5.6)
	spot.light_color = Color(1.0, 0.92, 0.75)
	spot.spot_range = 9.0
	spot.spot_angle = 22.0
	spot.light_energy = 3.0
	spot.shadow_enabled = true
	spot.add_to_group("stealth_lights")
	add_child(spot)
	spot.look_at_from_position(spot.position, PLINTH_AT + Vector3(0, 1.4, 0))
	lights["statue"] = [spot]
	lamp("gallery", Vector3(-5, TOP, -9), true, 0.5, 4.0)
	# The galleries.
	lamp("nature", Vector3(-11, UP, -9), true, 1.0, 7.0)
	lamp("pirates", Vector3(-11, UP, -1), true, 0.9, 6.0)
	lamp("pirates", Vector3(-11, UP, 5), true, 0.9, 6.0)
	lamp("castles", Vector3(10, UP, -1), true, 1.0, 6.0)
	lamp("castles", Vector3(10, UP, 5), true, 1.0, 6.0)
	# The back rooms.
	lamp("security", Vector3(9, UP, 11), true, 1.0, 6.0, Color(0.85, 0.92, 1.0))
	lamp("corridor", Vector3(15, UP, -1), true, 0.7, 4.5, Color(0.9, 0.95, 1.0))
	lamp("corridor", Vector3(15, UP, 5), true, 0.7, 4.5, Color(0.9, 0.95, 1.0))
	lamp("kitchen", Vector3(13, UP, -11), true, 1.3, 7.0, Color(0.95, 0.97, 1.0))
	lamp("kitchen", Vector3(13, UP, -6.5), true, 1.1, 6.0, Color(0.95, 0.97, 1.0))
	lamp("store", Vector3(8, UP, -11), false, 0.8, 5.0)
	lamp("staff_room", Vector3(8, UP, -6), true, 0.8, 4.5)
	lamp("plant_room", Vector3(-22, UP, -12), false, 0.8, 4.0)
	# Outside: the lamp posts, the light over the kitchen door and the garden lamp.
	for x in [-6.0, 6.0]:
		_outdoor_light("front", Vector3(x, 4.0, 19.5), 9.0)
	_outdoor_light("yard", Vector3(13, 2.6, -14.4), 7.0)
	_outdoor_light("garden", Vector3(-20, 2.4, -8.0), 6.0)
	light_switch(["office"], Vector3(-2.0, UP + 1.3, 10.12), Vector3(0, 0, 1))
	light_switch(["landing"], Vector3(1.85, UP + 1.3, 10.12), Vector3(0, 0, 1))
	light_switch(["store"], Vector3(9.9, 1.3, -9.6), Vector3(-1, 0, 0))
	light_switch(["plant_room"], Vector3(-20.12, 1.3, -12.6), Vector3(-1, 0, 0))
	light_switch(["rotunda", "gallery"], Vector3(5.88, 1.3, -9.6), Vector3(-1, 0, 0))


func _outdoor_light(room: String, at: Vector3, reach: float) -> void:
	var l := SpotLight3D.new()
	l.position = at
	l.rotation.x = -PI * 0.5
	l.light_color = Color(1.0, 0.82, 0.55)
	l.spot_range = reach
	l.spot_angle = 60.0
	l.light_energy = 2.0
	l.shadow_enabled = true
	l.add_to_group("stealth_lights")
	add_child(l)
	if not lights.has(room):
		lights[room] = []
	lights[room].append(l)


## The security office's keypad and panel, and the doors that lock again
## behind the guard.
func _security() -> void:
	pad = keypad("security", "0912", Vector3(5.93, 1.3, 8.3), -90, "security_door")
	group_switch("lasers", "Switch off the lasers", "Switch on the lasers", Vector3(9.2, 1.4, 8.08), 0)
	group_switch("cameras", "Switch off the cameras", "Switch on the cameras", Vector3(9.9, 1.4, 8.08), 0)
	alarm_switch(Vector3(10.7, 1.4, 8.1), 0)
	for t in [["LASERS", 9.2], ["CAMERAS", 9.9], ["ALARM", 10.7]]:
		var l := Label3D.new()
		l.text = t[0]
		l.font_size = 20
		l.pixel_size = 0.004
		l.position = Vector3(t[1], 1.62, 8.09)
		add_child(l)
	camera("foyer", Vector3(4.6, 2.3, 13.88), 180, {"sweep": 35.0, "pitch": 22.0, "accepts": ["guest", "waiter"]})
	for id in RELOCK:
		doors[id].closed.connect(_relock.bind(id))
	fuse_box(Vector3(-22, 1.2, -13.92), 0)


## People lock these doors behind them again (unless the keypad is solved).
func _relock(by: Node, id: String) -> void:
	if not by is Person:
		return
	if id == "security_door" and pad.solved:
		return
	var d: HouseDoor = doors[id]
	d.locked = true
	d._update_text()


func _things() -> void:
	# The statue on its plinth, which takes a toadstool in its place.
	treasure("statue", "Take the founder's statue", STATUE, PLINTH_AT + Vector3(0, PLINTH_TOP, 0), 1.0, 180, Vector3(0.8, 1.4, 0.8))
	treasure_stand.action("interact").on_use = _use_plinth
	# The waiter's jacket and the trays at the pass.
	_thing("WaiterJacket", Vector3(7.6, 0.47, -4.6), 0, Vector3(0.7, 0.3, 0.4), "Put on a waiter's jacket", _wear_jacket)
	_mesh(self, Vector3(7.6, 0.53, -4.6), Vector3(0.6, 0.1, 0.35), CLOTH_BLACK)
	_mesh(self, Vector3(7.6, 0.6, -4.6), Vector3(0.12, 0.04, 0.05), Color(0.9, 0.9, 0.9))
	var tray := _thing("Trays", Vector3(11.75, 0.84, -5.3), 0, Vector3(1.6, 0.3, 0.5), "Take a tray of drinks", _take_tray)
	for x in [-0.5, 0.4]:
		Kit.model(tray, Kit.FOOD + "plate-rectangle.glb", Vector3(x, 0, 0), 0, 0.7)
		for g in [-0.15, 0.0, 0.15]:
			Kit.model(tray, Kit.FOOD + "glass-wine.glb", Vector3(x + g, 0.08, g * 0.6), 0, 0.4)
	pickup("service_key", "Take the service key", "res://assets/kenney/platformer-kit/key.glb", Vector3(14.6, 1.4, -13.86), 0.35)
	_mesh(self, Vector3(14.6, 1.55, -13.95), Vector3(0.3, 0.08, 0.06), Color(0.35, 0.25, 0.15))
	# The guest's coat, and the curator's handbag on the cloakroom counter.
	_thing("EveningCoat", Vector3(-11.4, 0.6, 10.2), 90, Vector3(0.6, 1.2, 0.6), "Borrow an evening coat", _wear_coat)
	var bag := _thing("Handbag", Vector3(-7.7, 0.84, 12.6), 20, Vector3(0.4, 0.3, 0.3), "Look in the curator's handbag", _search_handbag)
	_mesh(bag, Vector3(0, 0.12, 0), Vector3(0.34, 0.24, 0.14), Color(0.55, 0.12, 0.3))
	# A toadstool to leave on the plinth.
	pickup("toadstool", "Pick a toadstool", TOADSTOOL, Vector3(-22.8, 0, -8.8), 3.0)
	# The pirate flag on the ship, and the castle that wants it.
	pickup("pirate_flag", "Take the pirate flag", PIRATE + "flag-pirate.glb", Vector3(-12.0, 0.8, 5.6), 0.45, 90)
	_thing("Castle", Vector3(12.4, 0, 5.8), 0, Vector3(1.4, 2.0, 1.4), "Look at the model castle", _use_castle)
	# The sea chest with the shanty, the quartet's stand and the gong.
	_thing("SeaChest", Vector3(-15.1, 0, -2.6), 90, Vector3(0.9, 0.75, 0.9), "Open the sea chest", _open_chest)
	_thing("MusicStand", Vector3(-4.45, 0, 5.8), 0, Vector3(0.3, 1.3, 0.6), "Look at the music", _use_music_stand)
	var gong := _thing("Gong", Vector3(-5.2, 0, 3.0), 90, Vector3(0.3, 1.8, 1.3), "Strike the gong", _strike_gong)
	gong.set_meta("dartable", true)
	# The buffet.
	_thing("Buffet", Vector3(-3.75, 0, -3.35), 0, Vector3(3.4, 0.9, 0.9), "Help yourself to a vol-au-vent", _eat)
	# The skylight over the statue.
	_skylight = _thing("Skylight", Vector3(SKYLIGHT.get_center().x, TOP, SKYLIGHT.get_center().y), 0,
		Vector3(SKYLIGHT.size.x, 0.1, SKYLIGHT.size.y), "Lift the skylight", _lift_skylight)
	_skylight.collision_layer = Kit.LAYER_GLASS | Kit.LAYER_INTERACT
	for c in _skylight.get_children():
		if c is CollisionShape3D:
			c.position.y = -0.04
	var glass := MeshInstance3D.new()
	var gm := BoxMesh.new()
	gm.size = Vector3(SKYLIGHT.size.x, 0.04, SKYLIGHT.size.y)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.75, 0.85, 0.3)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gm.material = mat
	glass.mesh = gm
	_skylight.add_child(glass)
	openings.append({"id": "skylight", "kind": "window", "pos": Vector3(0, TOP, SKYLIGHT.get_center().y)})
	# The curator's maintenance switch: the rotunda's lasers and camera off for cleaning.
	_maint_switch = _thing("Maintenance", Vector3(-0.08, UP + 1.4, 11.2), -90, Vector3(0.12, 0.3, 0.4), "Switch on exhibit maintenance", _toggle_maintenance)
	_mesh(_maint_switch, Vector3(0, 0.15, 0), Vector3(0.3, 0.26, 0.06), Color(0.85, 0.7, 0.2))
	_maint_switch.set_meta("dartable", true)


func _notes() -> void:
	note("invitation", "An invitation on the steps", INVITATION, Vector3(2.6, 0.03, 17.2), 30, Vector3(0.22, 0.02, 0.3))
	note("staff_notice", "A notice on the kitchen door", STAFF_NOTICE, Vector3(11.2, 1.4, -14.08), 180)
	note("electrician_note", "A note on the plant room door", ELECTRICIAN_NOTE, Vector3(-19.9, 1.4, -13.0), 90)
	note("hoard_letter", "A letter on the curator's desk", HOARD_LETTER, Vector3(-3.0, UP + 0.78, 13.3), 10, Vector3(0.2, 0.02, 0.28))
	note("speech", "Hoard's speech notes", SPEECH_NOTES, Vector3(1.2, UP + 1.12, 9.5), 180, Vector3(0.22, 0.02, 0.3))
	note("rounds", "The guard's rounds", ROUNDS, Vector3(8.4, 1.4, 8.08), 0)


func _marks() -> void:
	add_start("steps", Vector3(6, 0, 25), 0)
	add_start("yard", Vector3(17, 0, -27), 160)
	add_start("garden", Vector3(-24, 0, 4), -90)
	add_start("roof", Vector3(11, UP, 0), 90)
	points = {
		# The hall and the foyer.
		"hall_c": Vector3(0, 0, 1.5), "hall_w": Vector3(-2.8, 0, -0.4), "hall_e": Vector3(2.8, 0, 1.2),
		"hall_s": Vector3(-1.0, 0, 5.2), "arch": Vector3(0, 0, -2.4), "buffet": Vector3(-3.0, 0, -2.3),
		"violin": Vector3(-5.25, 0, 5.0), "cello": Vector3(-5.25, 0, 6.6),
		"foyer": Vector3(0.5, 0, 11.6), "steps": Vector3(1.4, 0, 17.4),
		# The galleries.
		"pirates": Vector3(-10.5, 0, 2.0), "nature": Vector3(-11, 0, -7.6), "castles": Vector3(10.2, 0, 2.6),
		"castles_n": Vector3(10.2, 0, -0.2),
		# The rotunda.
		"rotunda": Vector3(3.6, 0, -8.0), "rotunda_w": Vector3(-3.6, 0, -8.6),
		# The back.
		"desk": Vector3(7.9, 0, 11.0), "corridor_n": Vector3(15, 0, -2.4), "corridor_s": Vector3(15, 0, 6.4),
		"kitchen": Vector3(13, 0, -11.4), "stove": Vector3(14.7, 0, -12.2), "pass": Vector3(11.8, 0, -6.3),
		"staff_room": Vector3(8.4, 0, -6.0), "yard": Vector3(9.5, 0, -16.2), "store": Vector3(8.2, 0, -11.4),
		"fuse_box": Vector3(-22, 0, -12.9),
		# Upstairs.
		"balcony": Vector3(2.8, UP, 9.0), "office": Vector3(-3.0, UP, 11.8), "walkway": Vector3(-5.0, UP, 3.0),
		# The toast: Hoard on the balcony, the crowd below, the photographer behind.
		"toast_hoard": Vector3(0, UP, 8.9), "toast_curator": Vector3(-1.9, UP, 9.1),
		"toast_1": Vector3(-2.2, 0, 4.4), "toast_2": Vector3(-0.8, 0, 4.9), "toast_3": Vector3(0.8, 0, 4.9),
		"toast_4": Vector3(2.2, 0, 4.4), "toast_5": Vector3(-1.5, 0, 3.2), "toast_6": Vector3(1.5, 0, 3.2),
		"toast_guard": Vector3(3.2, 0, 6.0), "toast_waiter": Vector3(-3.0, 0, -2.3), "photo": Vector3(0, 0, 1.4),
	}
	for spot in PAIR_SPOTS:
		points[spot + "_a"] = PAIR_SPOTS[spot] + Vector3(-0.55, 0, 0)
		points[spot + "_b"] = PAIR_SPOTS[spot] + Vector3(0.55, 0, 0)


# --- Using things ------------------------------------------------------------------

## Something to use, with a box round it and one action.
func _thing(thing_name: String, pos: Vector3, yaw: float, box: Vector3, verb: String, on_use: Callable) -> UsableBody:
	var t := UsableBody.new()
	t.name = thing_name
	t.position = pos
	t.rotation.y = deg_to_rad(yaw)
	t.collision_layer = Kit.LAYER_INTERACT
	t.add_box(Vector3(0, box.y * 0.5, 0), box)
	t.add_action("interact", verb, on_use)
	add_child(t)
	return t


## A plain box to look at, with no collision.
func _mesh(parent: Node, center: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	bm.material = Kit.flat(color)
	mi.mesh = bm
	mi.position = center
	parent.add_child(mi)
	return mi


func _wear_jacket(pic: PlayerInteractionComponent) -> void:
	var player: Moth = pic.get_parent()
	if player.disguise == "waiter":
		UsableBody.hint(pic, "You're already dressed for it.")
		return
	player.set_disguise("waiter")
	Sfx.at(self, "kenney:cloth2", player.global_position, -8.0)
	UsableBody.hint(pic, "A waiter's jacket and bow tie. Now find a tray.")
	_record("wore:waiter")


func _wear_coat(pic: PlayerInteractionComponent) -> void:
	var player: Moth = pic.get_parent()
	if player.disguise == "guest":
		UsableBody.hint(pic, "You look the part already.")
		return
	player.set_disguise("guest")
	Sfx.at(self, "kenney:cloth2", player.global_position, -8.0)
	UsableBody.hint(pic, "An evening coat. You look like you were invited.")
	_record("wore:guest")


func _take_tray(pic: PlayerInteractionComponent) -> void:
	var player: Moth = pic.get_parent()
	var have := int(player.bag.get("drinks", 0))
	if have >= 4:
		UsableBody.hint(pic, "Your tray's full.")
		return
	player.add_item("drinks", 4 - have)
	Sfx.at(self, "glass_clink", player.global_position, -10.0)
	_record("took:drinks")


func _search_handbag(pic: PlayerInteractionComponent) -> void:
	var player: Moth = pic.get_parent()
	if player.has_item("curator_keys"):
		UsableBody.hint(pic, "Tissues, mints and a catalogue. Nothing else.")
		return
	player.add_item("curator_keys")
	Sfx.at(self, "kenney:handleSmallLeather", player.global_position, -8.0)
	UsableBody.hint(pic, "The curator's keys: her office, and the gallery door upstairs.")
	_record("took:curator_keys")


func _use_castle(pic: PlayerInteractionComponent) -> void:
	var player: Moth = pic.get_parent()
	if _flag_flown:
		UsableBody.hint(pic, "Kettleford Castle, under new management.")
		return
	if not player.take_item("pirate_flag"):
		UsableBody.hint(pic, "Kettleford Castle, from the town library. Its flag's a bit dull.")
		return
	_flag_flown = true
	_castle_flag.queue_free()
	var flag := Kit.model(self, PIRATE + "flag-pirate.glb", Vector3(12.4, 1.87, 5.8), 90, 0.45)
	_castle_flag = flag
	Sfx.at(self, "kenney:cloth2", flag.global_position, -8.0)
	UsableBody.hint(pic, "Kettleford Castle, under new management.")
	_record("flag_on_castle")


func _open_chest(pic: PlayerInteractionComponent) -> void:
	var player: Moth = pic.get_parent()
	Sfx.at(self, "kenney:metalLatch", player.global_position, -8.0)
	StealthNoise.make(self, Vector3(-15.1, 0.6, -2.6), 3.0, "door", player)
	if player.has_item("shanty") or JobRun.current and JobRun.current.has("shanty"):
		UsableBody.hint(pic, "Sand, a sock, and a smell of the sea.")
		return
	player.add_item("shanty")
	UsableBody.hint(pic, "Sheet music: \"What Shall We Do With the Drunken Sailor?\"")
	_record("took:shanty")


func _use_music_stand(pic: PlayerInteractionComponent) -> void:
	var player: Moth = pic.get_parent()
	if JobRun.current and JobRun.current.has("shanty"):
		UsableBody.hint(pic, "Sea shanties, by special request.")
		return
	if not player.take_item("shanty"):
		UsableBody.hint(pic, "Something by Mozart. It's very nice.")
		return
	_record("shanty")
	if is_instance_valid(_quartet):
		_quartet.pitch_scale = 1.12
	if party:
		party.play_shanty()


func _strike_gong(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	Sfx.at(self, "gong", Vector3(-5.2, 1.2, 3.0), 0.0)
	_record("rang_gong")
	if party:
		party.gong(player)


func _eat(pic: PlayerInteractionComponent) -> void:
	Sfx.at(self, "kenney:cardPlace1", pic.get_parent().global_position, -10.0)
	UsableBody.hint(pic, "Delicious. Hoard won't miss one.")
	_record("ate_buffet")


func _lift_skylight(pic: PlayerInteractionComponent) -> void:
	if skylight_open:
		return
	skylight_open = true
	Sfx.at(self, "kenney:metalLatch", _skylight.global_position, -6.0)
	StealthNoise.make(self, _skylight.global_position, 3.0, "door", pic.get_parent())
	UsableBody.hint(pic, "It doesn't even lock. The founder's right below.")
	_record("opened_skylight")
	_skylight.queue_free()


func _toggle_maintenance(_pic: PlayerInteractionComponent) -> void:
	maintenance = not maintenance
	for g in get_tree().get_nodes_in_group("lasers"):
		g.set_switched_on(not maintenance)
	rotunda_cam.set_switched_on(not maintenance)
	Sfx.at(self, "kenney:metalClick", _maint_switch.global_position, -8.0, 1.2)
	_maint_switch.set_action_text("interact", "Switch off exhibit maintenance" if maintenance else "Switch on exhibit maintenance")
	if maintenance:
		_record("maintenance_mode")


## The plinth: take the statue, then leave a toadstool in its place.
func _use_plinth(pic: PlayerInteractionComponent) -> void:
	var player: Moth = pic.get_parent()
	if _treasure_model != null:
		_take_treasure(pic)
		if not player.bag_changed.is_connected(_update_plinth):
			player.bag_changed.connect(_update_plinth.bind(player))
		_update_plinth(player)
		return
	if _toadstool == null and player.take_item("toadstool"):
		_toadstool = Kit.model(treasure_stand, TOADSTOOL, Vector3.ZERO, 0, 3.0)
		Sfx.at(self, "kenney:cloth2", treasure_stand.global_position, -8.0)
		_record("toadstool_on_plinth")
		treasure_stand.set_action_text("interact", "")


func _update_plinth(player: Moth) -> void:
	if _treasure_model != null:
		return
	var can_leave := _toadstool == null and player.has_item("toadstool")
	treasure_stand.set_action_text("interact", "Leave the toadstool" if can_leave else "")


## The statue goes back on its plinth (the player was caught with it).
func return_treasure() -> void:
	if _treasure_model != null:
		return
	if _toadstool != null:
		_toadstool.queue_free()
		_toadstool = null
	super()
	treasure_stand.set_action_text("interact", "Take the founder's statue")


## The party's chatter in the hall (it stops for the toast).
func set_chatter(on: bool) -> void:
	_chatter[1] = 0.5 if on else 0.0
	if is_instance_valid(_murmur):
		_murmur.volume_db = -8.0 if on else -20.0


func chatter_on() -> bool:
	return _chatter[1] > 0.0


## The breaker takes the quartet's lamp and the party's spirits with it.
func set_power(on: bool) -> void:
	var was_off := power_off()
	super(on)
	if not on and not was_off and party:
		party.lights_went_out()


func _physics_process(delta: float) -> void:
	super(delta)
	if not skylight_open:
		return
	var p := get_tree().get_first_node_in_group("moth") as Node3D
	if p == null:
		return
	var at := p.global_position
	if SKYLIGHT.has_point(Vector2(at.x, at.z)) and at.y < TOP - 0.5 and at.y > PLINTH_TOP:
		_record("dropped_through_skylight")


## Who thinks nothing of the player: guests and waiters where they belong,
## and a waiter only while they carry a tray (the head waiter notices).
func expects(person: Person, p: Moth) -> bool:
	if p.disguise == "" or not p.disguise in person.accepts:
		return false
	if p.is_crouching or p.is_sprinting:
		return false
	if not disguise_fits(p.disguise, p.global_position):
		return false
	if party and person == party.pring and p.disguise == "waiter" and not p.has_item("drinks"):
		party.idle_waiter()
		return false
	return true


func add_people(p_run: JobRun) -> Array:
	party = MuseumParty.new()
	party.name = "Party"
	add_child(party)
	return party.setup(self, p_run)


func voice_info() -> Dictionary:
	return MuseumParty.VOICES


func screenshot_views() -> Dictionary:
	return {
		"front": [Vector3(0, 0, 21), 0.0, 6.0],
		"foyer": [Vector3(0, 0, 13), 0.0, 4.0],
		"hall": [Vector3(0, 0, 7), 0.0, 6.0],
		"hall_back": [Vector3(0, 0, -2.5), 180.0, 8.0],
		"balcony": [Vector3(1.5, UP, 9.0), 0.0, -15.0],
		"walkway": [Vector3(-5, UP, 6.5), 0.0, -8.0],
		"rotunda": [Vector3(0, 0, -4.6), 0.0, 8.0],
		"rotunda_up": [Vector3(-5, UP, -12.5), -125.0, -25.0],
		"skylight": [Vector3(0, TOP, -6.6), 0.0, -45.0],
		"pirates": [Vector3(-7, 0, 7), 65.0, -5.0],
		"nature": [Vector3(-7, 0, -5), 40.0, 0.0],
		"castles": [Vector3(7.2, 0, 2.0), -110.0, -5.0],
		"cloakroom": [Vector3(-6.8, 0, 11), 90.0, -5.0],
		"security": [Vector3(13, 0, 12.5), 80.0, -8.0],
		"kitchen": [Vector3(10.8, 0, -11.6), -70.0, -5.0],
		"staff_room": [Vector3(10.6, 0, -6.6), 80.0, -12.0],
		"office": [Vector3(-0.8, UP, 10.6), 140.0, -12.0],
		"yard": [Vector3(13, 0, -22), 180.0, 5.0],
		"garden": [Vector3(-27, 0, 0), -70.0, 3.0],
		"roof": [Vector3(13, UP, 3), 60.0, 5.0],
		"overview": [Vector3(0, 22, 28), 0.0, -40.0],
	}
