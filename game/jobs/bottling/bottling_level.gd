class_name BottlingLevel
extends JobLevel
## Hoard's lemonade bottling plant on the night shift. X runs east, Z south.
##
## The hall (28 x 18 m, 7.5 m high) holds the bottling line: a conveyor that
## comes in from the loading dock through a rubber flap and runs west through
## the washer, the filler, the capper and the labeller to the packing table.
## The clock tower's cog turns on top of the capper as its drive wheel, and
## only comes off with the line stopped. Catwalks at 2.5 m run along the
## north wall, across the line beside the capper and on into the dock; the
## foreman's office sits on a mezzanine in the north-west corner, with the
## stores under it. The break room and the locker room are in the south-west
## corner, the switch house (the main breaker) in the north yard, the loading
## dock with its crane and the truck to the east, and the car park and the
## gate to the south. A skylight in the roof opens over the cross catwalk.
##
## The machines are tools. Three things stop the line: the lever at the
## control panel, the emergency stop on the capper (a dart will do) and the
## foreman's own lever in his office; the main breaker stops everything. A
## stopped line is quiet, and someone comes to restart it: the foreman to
## his lever, else the nearest worker to the control panel. Running, it
## drowns out footsteps near it and carries a crouching rider in from the
## dock. The dock's crane swings a crate over to the catwalk (a step up) or
## drops it (a crash that brings everyone), and the break room's kettle
## brings Rosa and Eddie running for tea.
##
## Routes to the cog:
## 1. Night shift: Rosa's note in the smoking shelter has the staff door
##    code (1904). The locker room has hard hats and vests; dressed, walk the
##    floor, stop the line at the control panel and unbolt the cog from the
##    capper's step while they fuss at the panel. (A worker carrying the cog
##    is no worker, so get out of sight with it.)
## 2. Lights out: pick the switch house's sticky lock in the north yard and
##    pull the main breaker. The plant goes dark and quiet, Platt walks all
##    the way out to the breaker, and the fire door (pickable) lets you in to
##    the cog in the dark.
## 3. Up and over: in the dock, swing the crane so its crate sits by the
##    dock catwalk, climb it, follow the catwalks to Platt's office (the side
##    door's pickable) and stop the line with his lever. He comes back up to
##    restart it; step from the cross catwalk onto the capper and take the
##    cog.
## 4. The skylight: from the roof, lift the skylight and drop the rope to
##    the cross catwalk. Dart the emergency stop on the capper from above,
##    step across onto the capper, take the cog and climb back out without
##    ever touching the floor.
## 5. The conveyor: from the dock, crouch on the belt and ride it in through
##    the flap, hidden in the machines' din. Put the kettle on (or wait for
##    the tea break) so Rosa and Eddie are in the break room, hop off at the
##    capper and hit the emergency stop.
## 6. The crash: drop the crane's crate in the dock. Everyone runs to look,
##    and the line's left to you; stop it at the panel and take the cog.
## Snooze darts (Platt, or whoever minds the panel) and the noisemaker open
## more.

const FACTORY := "res://assets/kenney/factory-kit/"
const CARS := "res://assets/kenney/car-kit/"
const UP := JobLevel.STOREY
const TOP := JobLevel.STOREY * 2.0
const ROOF := JobLevel.STOREY * 3.0
## Factory Kit machines are made for its 0.4 m conveyors; doubled, they fit
## our 0.8 m belt.
const MACHINE_SCALE := 2.0
const BELT_Z := -1.0
const CAPPER := Vector3(0.5, 0, BELT_Z)
## The drive cog sits flat on top of the capper.
const COG_Y := 2.7
const COG_SCALE := 1.5
const KETTLE_TIME := 6.0
## Seconds a stopped line waits before someone comes to restart it.
const RESTART_DELAY := 2.5

const FLOOR := Color(0.42, 0.44, 0.47)
const LINO := Color(0.55, 0.6, 0.5)
const TILE := Color(0.72, 0.74, 0.72)
const CARPET := Color(0.36, 0.33, 0.42)
const TARMAC := Color(0.2, 0.2, 0.22)
const PAVING := Color(0.45, 0.44, 0.42)
const DECK := Color(0.3, 0.32, 0.36)
const RAIL := Color(0.92, 0.72, 0.12)
const FENCE := Color(0.22, 0.3, 0.26)
const WALL := Color(0.8, 0.78, 0.72)
const ROOF_COLOR := Color(0.3, 0.3, 0.33)
const CEILING := Color(0.55, 0.56, 0.58)

const LIGHTS_ON := ["line", "office", "dock", "yard", "gate"]
const CIRCUIT := ["line", "office", "dock", "yard", "break", "lockers", "stores", "switch"]

const HOARD_LETTER := """Platt,

That cog from the clock tower is the finest bit of brass in Kettleford, and now it drives MY bottling line. The town can tell the time by my lemonade from now on.

Keep that line running. If it ever has to stop, YOU stop it, from YOUR lever, and nobody else touches it.

- A. Hoard"""

const SHIFT_ROTA := """NIGHT SHIFT - BOTTLING

Rosa: control panel, filler, packing.
Eddie: loading dock, washer, empties.
Mr Platt: office. Walks the floor.

Tea breaks: when the kettle whistles, and NOT before.
Emergency stop is for EMERGENCIES, Eddie.
Nobody goes in Mr Platt's office."""

const ROSA_NOTE := """Eddie -
The staff door code is 1904. Same as the year on the clock tower. You walk past it every day!
Hard hats in the lockers, not on your head in the canteen.
- Rosa"""

const SWITCH_TAG := """MAIN BREAKER - WHOLE PLANT
Lock sticks. Jiggle it.
If the power goes, Mr Platt has to come all the way out here to put it back, so DON'T lean on it."""

const CRANE_DOCKET := """CRANE: two levers.
Left lever: swings the crate between the truck and the catwalk.
Right lever: lets go of the hook.
Do NOT pull the right lever with a crate in the air!!
- Maintenance"""

const BELT_NOTE := """Eddie,
The flap on the conveyor's torn again. If you MUST ride the belt in from the dock, crouch, or you'll lose your head.
Not that you would ride the belt. Because that's not allowed.
- Platt"""

const CLOCK_CUTTING := """KETTLEFORD GAZETTE

TOWN CLOCK STOPS

The clock tower has stood silent since Mr Augustus Hoard's men took away its last cog "for polishing". Mr Hoard says the cog is "in safe hands" and "doing important work".

Hoard's Lemonade: now bottled faster than ever."""

const FOREMAN_LOG := """LINE LOG

Mon: line stopped. E-stop on the capper. Rosa says she "brushed past it".
Tue: line stopped. E-stop again. Eddie says a moth flew into it.
Wed: kettle whistled, whole floor went for tea. Line ran on its own for 20 min. Nobody noticed.
Thu: Mr Hoard rang. Twice. About the cog."""

var bottling_line: BottlingLine
var crane: BottlingCrane
var cog: UsableBody
var estop: UsableBody
var panel_lever: UsableBody
var office_lever: UsableBody
var kettle: UsableBody
var skylight: UsableBody
var rope: BottlingLadder
var ladders := {}
var platt: BottlingWorker
var rosa: BottlingWorker
var eddie: BottlingWorker
var cap_left := false
var _cog_model: Node3D
var _cap_model: Node3D
var _stopped_t := 0.0
var _restarter: BottlingWorker
var _kettle_t := -1.0
var _kettle_boiled := false
var _floor_box := AABB(Vector3(-14, -1, -12), Vector3(28, 3.4, 18))
var _rooms_box := AABB(Vector3(-14, -1, 0), Vector3(10, 3.4, 6))


func build() -> void:
	circuit = CIRCUIT
	_grounds()
	_hall()
	_rooms()
	_office()
	_catwalks()
	_dock()
	_switch_house()
	_roof()
	_line()
	_furnish()
	_yard()
	_lamps()
	_things()
	_marks()
	house_boxes.append(AABB(Vector3(-14, -0.5, -12), Vector3(28, ROOF + 0.5, 18)))
	house_boxes.append(AABB(Vector3(14, -0.5, -12), Vector3(10, TOP + 0.5, 14)))
	indoor_boxes.append(AABB(Vector3(-12, -0.5, -16), Vector3(4, UP + 0.5, 4)))
	areas["switch_house"] = indoor_boxes[0]
	areas["office"] = AABB(Vector3(-14, UP - 0.2, -12), Vector3(8, UP, 6))
	areas["dock_catwalk"] = AABB(Vector3(14, UP - 0.2, -12), Vector3(10, 2.0, 1.6))
	add_zone("factory_floor", _floor_box, ["worker"])
	add_zone("office", areas["office"], [])
	for room in lights:
		set_lights(room, room in LIGHTS_ON)
	at_way_out.connect(_on_way_out)


# --- The building ----------------------------------------------------------------

func _grounds() -> void:
	Kit.block(self, Vector3(6, -0.06, 3), Vector3(68, 0.1, 58), "concrete", Kit.flat(TARMAC))
	# Paths: from the gate to the staff door, and along the hall's south side.
	Kit.block(self, Vector3(0, -0.03, 15), Vector3(3, 0.06, 18), "concrete", Kit.flat(PAVING))
	Kit.block(self, Vector3(-4, -0.03, 7.2), Vector3(20, 0.06, 2.4), "concrete", Kit.flat(PAVING))
	# White lines in the car park.
	for x in [5.0, 8.0, 11.0, 14.0]:
		Kit.block(self, Vector3(x, -0.005, 13), Vector3(0.12, 0.02, 4), "", Kit.flat(Color(0.85, 0.85, 0.8)), false)
	# The road beyond the gate.
	Kit.block(self, Vector3(6, -0.02, 28.5), Vector3(68, 0.04, 5), "", Kit.flat(Color(0.14, 0.14, 0.16)), false)
	# The site fence (too tall to climb), with the gate south and the truck
	# gate east.
	var fence := Kit.flat(FENCE)
	Kit.block(self, Vector3(5, 1.2, -20), Vector3(54, 2.4, 0.08), "", fence)
	Kit.block(self, Vector3(-22, 1.2, 2), Vector3(0.08, 2.4, 44), "", fence)
	Kit.block(self, Vector3(-12, 1.2, 24), Vector3(20, 2.4, 0.08), "", fence)
	Kit.block(self, Vector3(17, 1.2, 24), Vector3(30, 2.4, 0.08), "", fence)
	Kit.block(self, Vector3(32, 1.2, -15), Vector3(0.08, 2.4, 10), "", fence)
	Kit.block(self, Vector3(32, 1.2, 11), Vector3(0.08, 2.4, 26), "", fence)
	var post := Kit.flat(Color(0.3, 0.3, 0.32))
	for p in [Vector3(-2, 1.4, 24), Vector3(2, 1.4, 24), Vector3(32, 1.4, -10), Vector3(32, 1.4, -2)]:
		Kit.block(self, p, Vector3(0.25, 2.8, 0.25), "", post)
	# The gate's leaves, swung open.
	Kit.block(self, Vector3(-2.9, 1.0, 24.9), Vector3(0.06, 2.0, 1.8), "", fence)
	Kit.block(self, Vector3(2.9, 1.0, 24.9), Vector3(0.06, 2.0, 1.8), "", fence)
	# A sign on the fence.
	var sign := Kit.block(self, Vector3(-5.5, 1.6, 24.08), Vector3(3.2, 0.9, 0.05), "", Kit.flat(Color(0.95, 0.85, 0.25)), false)
	sign.name = "Sign"
	var label := Label3D.new()
	label.text = "HOARD'S LEMONADE\nBottling plant"
	label.font_size = 64
	label.pixel_size = 0.004
	label.modulate = Color(0.25, 0.18, 0.05)
	label.position = Vector3(-5.5, 1.6, 24.12)
	add_child(label)


func _hall() -> void:
	floor_rect(0, -14, -12, 14, 0, "concrete", FLOOR, false)
	floor_rect(0, -4, 0, 14, 6, "concrete", FLOOR, false)
	floor_rect(0, -8, 0, -4, 2, "concrete", FLOOR, false)
	# Yellow walkway lines on the floor.
	var paint := Kit.flat(Color(0.85, 0.7, 0.15))
	for z in [-3.2, 1.2]:
		Kit.block(self, Vector3(4, 0.005, z), Vector3(19, 0.012, 0.1), "", paint, false)
	# North wall, with the fire door out to the yard.
	line(0, Vector2(-14, -12), Vector2(1, 0), "WWWWWDWWWWWWWW", [
		{"id": "fire_door", "into": Vector2(-3, -10), "locked": true, "pick": 6.0, "outside": true}])
	line(UP, Vector2(-14, -12), Vector2(1, 0), "WwWwWWWWWWWWWW")
	line(TOP, Vector2(-14, -12), Vector2(1, 0), "WwWwWwWwWwWwWw")
	# West wall, with the break room's window propped open.
	line(0, Vector2(-14, -12), Vector2(0, 1), "WWWWWWWoW", ["break_window"])
	line(UP, Vector2(-14, -12), Vector2(0, 1), "wwwWWWWWW")
	line(TOP, Vector2(-14, -12), Vector2(0, 1), "WwWwWwWwW")
	# South wall: the break room's windows, the staff door and a yard door.
	line(0, Vector2(-14, 6), Vector2(1, 0), "wwWWDWwWwDWwWW", [
		{"id": "staff_door", "into": Vector2(-5, 4), "locked": true, "outside": true},
		{"id": "yard_door", "into": Vector2(5, 4), "locked": true, "pick": 8.0, "outside": true}])
	line(UP, Vector2(-14, 6), Vector2(1, 0), "WWWwWWwWWwWWwW")
	line(TOP, Vector2(-14, 6), Vector2(1, 0), "wWwWwWwWwWwWwW")
	# East wall to the dock: a door, and the conveyor's hatch (built below).
	line(0, Vector2(14, -12), Vector2(0, 1), "WWWDW.WWW", [{"id": "dock_door", "into": Vector2(12, -5)}])
	line(UP, Vector2(14, -12), Vector2(0, 1), "dWWWWWWWW")
	line(TOP, Vector2(14, -12), Vector2(0, 1), "WwWwWwWwW")
	_hatch()


## The conveyor's way through the dock wall: an opening just big enough for
## the belt and a crouching rider, behind rubber flaps.
func _hatch() -> void:
	var wall := Kit.flat(WALL)
	Kit.block(self, Vector3(14, UP * 0.5, -1.85), Vector3(0.24, UP, 0.3), "", wall)
	Kit.block(self, Vector3(14, UP * 0.5, -0.15), Vector3(0.24, UP, 0.3), "", wall)
	Kit.block(self, Vector3(14, 2.0 + (UP - 2.0) * 0.5, -1.0), Vector3(0.24, UP - 2.0, 1.4), "", wall)
	var rubber := Kit.flat(Color(0.12, 0.12, 0.13), 0.5)
	for i in 6:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.02, 1.05, 0.21)
		bm.material = rubber
		mi.mesh = bm
		mi.position = Vector3(14.1, 1.47, -1.58 + i * 0.23)
		mi.rotation.z = 0.08 if i % 2 == 0 else -0.05
		add_child(mi)
	openings.append({"id": "conveyor_flap", "kind": "window", "pos": Vector3(14, 1.3, BELT_Z)})


func _rooms() -> void:
	# The break room (west) and the locker room, under a flat ceiling.
	floor_rect(0, -14, 0, -8, 6, "tile", LINO, false)
	floor_rect(0, -8, 2, -4, 6, "tile", TILE, false)
	floor_rect(UP, -14, 0, -8, 6, "concrete", CEILING)
	floor_rect(UP, -8, 2, -4, 6, "concrete", CEILING)
	line(0, Vector2(-14, 0), Vector2(1, 0), "DWW", [{"id": "break_door", "into": Vector2(-13, 2)}])
	line(0, Vector2(-8, 0), Vector2(0, 1), "WDW", [{"id": "locker_break_door", "into": Vector2(-10, 3)}])
	line(0, Vector2(-8, 2), Vector2(1, 0), "WD", [{"id": "locker_door", "into": Vector2(-5, 4)}])
	line(0, Vector2(-4, 2), Vector2(0, 1), "WW")


func _office() -> void:
	# The mezzanine: the office, the landing in front and the stairs down.
	floor_rect(UP, -14, -12, -6, -6, "carpet", CARPET)
	floor_rect(UP, -10, -6, -6, -4.5, "tile", DECK)
	floor_rect(TOP, -14, -12, -6, -6, "concrete", CEILING)
	line(UP, Vector2(-14, -6), Vector2(1, 0), "wwwD", [{"id": "office_door", "into": Vector2(-7, -8)}])
	line(UP, Vector2(-6, -12), Vector2(0, 1), "Dww", [
		{"id": "office_side", "into": Vector2(-8, -11), "locked": true, "pick": 5.0}])
	var steel := Kit.flat(Color(0.35, 0.38, 0.5))
	for p in [Vector2(-6, -6.15), Vector2(-10, -6.15), Vector2(-6, -9), Vector2(-10, -9), Vector2(-10, -4.6), Vector2(-6.15, -4.6)]:
		Kit.block(self, Vector3(p.x, UP * 0.5 - 0.05, p.y), Vector3(0.25, UP - 0.1, 0.25), "", steel)
	_rail(Vector2(-10, -4.5), Vector2(-6, -4.5))
	_rail(Vector2(-10, -6), Vector2(-10, -4.5))
	# The stairs climb west from the floor to the landing.
	var stairs := StaticBody3D.new()
	stairs.collision_layer = Kit.LAYER_WORLD
	stairs.collision_mask = 0
	var cs := CollisionShape3D.new()
	var wedge := ConvexPolygonShape3D.new()
	var pts := PackedVector3Array()
	for z in [-6.0, -4.5]:
		pts.append_array([Vector3(-0.8, 0, z), Vector3(-6.4, 0, z), Vector3(-6.4, UP, z), Vector3(-6.0, UP, z), Vector3(-0.8, 0.12, z)])
	wedge.points = pts
	cs.shape = wedge
	stairs.add_child(cs)
	add_child(stairs)
	Kit.add_surface(stairs, "tile")
	stairs.add_to_group(Kit.NAV_GROUP)
	var step := Kit.flat(DECK)
	for i in 10:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.52, 0.06, 1.5)
		bm.material = step
		mi.mesh = bm
		mi.position = Vector3(-1.05 - i * 0.5, 0.2 + i * 0.235, -5.25)
		add_child(mi)
	for z in [-6.02, -4.48]:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(5.7, 0.08, 0.06)
		bm.material = Kit.flat(RAIL)
		mi.mesh = bm
		mi.position = Vector3(-3.5, 1.3 + 0.95, z)
		mi.rotation.z = -atan2(UP, 5.4)
		add_child(mi)


func _catwalks() -> void:
	# Along the north wall, from the office's side door to the dock.
	_deck(-6, -12, 14, -10.5)
	_rail(Vector2(-6, -10.5), Vector2(1.8, -10.5))
	_rail(Vector2(3.3, -10.5), Vector2(11.6, -10.5))
	_rail(Vector2(12.4, -10.5), Vector2(14, -10.5))
	# Across the line, beside the capper (a gap in the rail to step across).
	_deck(1.8, -10.5, 3.3, 4.5)
	_rail(Vector2(1.8, -10.5), Vector2(1.8, -2.2))
	_rail(Vector2(1.8, 0.2), Vector2(1.8, 4.5))
	_rail(Vector2(3.3, -10.5), Vector2(3.3, 4.5))
	_rail(Vector2(1.8, 4.5), Vector2(2.15, 4.5))
	_rail(Vector2(2.95, 4.5), Vector2(3.3, 4.5))
	# In the dock, with a gap where the crane can set a crate down.
	_deck(14, -12, 23.7, -10.5)
	_rail(Vector2(14, -10.5), Vector2(18.1, -10.5))
	_rail(Vector2(19.9, -10.5), Vector2(23.7, -10.5))
	_rail(Vector2(23.7, -12), Vector2(23.7, -10.5))
	# Ladders up from the hall floor (people don't use them).
	_ladder("north", Vector3(12, 0, -10.42), Vector3(12, 0, -9.7), Vector3(12, UP, -11.2))
	_ladder("south", Vector3(2.55, 0, 4.58), Vector3(2.55, 0, 5.25), Vector3(2.55, UP, 3.9))


func _ladder(id: String, base: Vector3, bottom: Vector3, top: Vector3) -> BottlingLadder:
	var l := BottlingLadder.make(id, base, bottom, top)
	add_child(l)
	ladders[id] = l
	return l


## A catwalk's grated deck at the catwalk height, from (x0, z0) to (x1, z1).
func _deck(x0: float, z0: float, x1: float, z1: float) -> void:
	var size := Vector3(x1 - x0, 0.08, z1 - z0)
	Kit.block(self, Vector3((x0 + x1) * 0.5, UP - 0.04, (z0 + z1) * 0.5), size, "tile", Kit.flat(DECK, 0.6))
	# Steel girders under the long edges (something to climb up onto).
	var steel := Kit.flat(Color(0.35, 0.38, 0.5))
	var girder := 0.5
	if size.x > size.z:
		for z in [z0 + 0.08, z1 - 0.08]:
			Kit.block(self, Vector3((x0 + x1) * 0.5, UP - 0.08 - girder * 0.5, z), Vector3(size.x, girder, 0.16), "", steel, false)
	else:
		for x in [x0 + 0.08, x1 - 0.08]:
			Kit.block(self, Vector3(x, UP - 0.08 - girder * 0.5, (z0 + z1) * 0.5), Vector3(0.16, girder, size.z), "", steel, false)


## A railing along a catwalk edge from `a` to `b` (x, z): yellow bars to look
## at, and a panel that stops bodies but not sight, light or sound.
func _rail(a: Vector2, b: Vector2) -> void:
	var mid := (a + b) * 0.5
	var length := a.distance_to(b)
	var along_x := absf(b.x - a.x) > absf(b.y - a.y)
	var size := Vector3(length, 1.0, 0.05) if along_x else Vector3(0.05, 1.0, length)
	var body := StaticBody3D.new()
	body.name = "Rail"
	body.position = Vector3(mid.x, UP + 0.5, mid.y)
	body.collision_layer = Kit.LAYER_GLASS
	body.collision_mask = 0
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	body.add_child(cs)
	add_child(body)
	var yellow := Kit.flat(RAIL)
	for h in [0.5, 1.0]:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(length, 0.05, 0.05) if along_x else Vector3(0.05, 0.05, length)
		bm.material = yellow
		mi.mesh = bm
		mi.position = Vector3(mid.x, UP + h, mid.y)
		add_child(mi)
	var n := maxi(1, int(length / 1.5))
	for i in n + 1:
		var p := a.lerp(b, float(i) / n)
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.05, 1.0, 0.05)
		bm.material = yellow
		mi.mesh = bm
		mi.position = Vector3(p.x, UP + 0.5, p.y)
		add_child(mi)


func _dock() -> void:
	floor_rect(0, 14, -12, 24, 2, "concrete", FLOOR.darkened(0.1), false)
	floor_rect(TOP, 14, -12, 24, 2, "concrete", ROOF_COLOR)
	line(0, Vector2(14, -12), Vector2(1, 0), "WWWWW")
	line(UP, Vector2(14, -12), Vector2(1, 0), "WwWwW")
	# The shutter's rolled up over the truck.
	line(0, Vector2(24, -12), Vector2(0, 1), "WW..WWW")
	line(UP, Vector2(24, -12), Vector2(0, 1), "WW..WWW")
	Kit.block(self, Vector3(24, 4.2, -6), Vector3(0.3, 1.6, 4.0), "", Kit.flat(Color(0.55, 0.57, 0.6)))
	openings.append({"id": "shutter", "kind": "door", "pos": Vector3(24, 1.5, -6)})
	line(0, Vector2(14, 2), Vector2(1, 0), "WWDWW", [
		{"id": "dock_side", "into": Vector2(19, 0), "locked": true, "pick": 5.0, "outside": true}])
	line(UP, Vector2(14, 2), Vector2(1, 0), "WWWWW")
	# The crane swings its crate from the truck (east) to the catwalk (north).
	crane = BottlingCrane.make(deg_to_rad(-90.0), 0.0)
	crane.position = Vector3(19, 0, -6.6)
	add_child(crane)
	crane.add_controls(self, Vector3(16.6, 0, -8.6), 90.0)
	crane.catwalk_box = AABB(Vector3(14, UP - 0.2, -12), Vector3(10, 2.0, 1.6))
	crane.crashed.connect(_on_crash)
	# The forklift, parked.
	_forklift(Vector3(16.4, 0, -3.6), 0.0)
	# The truck backed up to the shutter.
	Kit.boxed(self, CARS + "truck.glb", Vector3(28.4, 0, -6), 90.0, 2.0)


## A forklift made of blocks (the kits don't have one).
func _forklift(at: Vector3, yaw: float) -> void:
	var body := Kit.block(self, at + Vector3(0, 0.6, 0), Vector3(1.1, 1.2, 1.7), "", null)
	body.name = "Forklift"
	body.rotation.y = deg_to_rad(yaw)
	var yellow := Kit.flat(Color(0.95, 0.72, 0.1))
	var dark := Kit.flat(Color(0.18, 0.18, 0.2))
	var parts := [
		[Vector3(0, -0.15, 0.1), Vector3(1.1, 0.9, 1.4), yellow],
		[Vector3(0, 0.55, 0.45), Vector3(0.9, 0.5, 0.5), yellow],
		[Vector3(-0.42, 1.1, 0.1), Vector3(0.06, 1.2, 0.06), dark],
		[Vector3(0.42, 1.1, 0.1), Vector3(0.06, 1.2, 0.06), dark],
		[Vector3(0, 1.7, 0.1), Vector3(0.9, 0.06, 1.0), dark],
		[Vector3(-0.3, 0.6, -0.8), Vector3(0.08, 2.4, 0.1), dark],
		[Vector3(0.3, 0.6, -0.8), Vector3(0.08, 2.4, 0.1), dark],
		[Vector3(-0.3, -0.55, -1.35), Vector3(0.12, 0.05, 1.0), dark],
		[Vector3(0.3, -0.55, -1.35), Vector3(0.12, 0.05, 1.0), dark],
	]
	for p in parts:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = p[1]
		bm.material = p[2]
		mi.mesh = bm
		mi.position = p[0]
		body.add_child(mi)
	for w in [Vector3(-0.58, -0.35, 0.55), Vector3(0.58, -0.35, 0.55), Vector3(-0.58, -0.35, -0.4), Vector3(0.58, -0.35, -0.4)]:
		var mi := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.25
		cm.bottom_radius = 0.25
		cm.height = 0.2
		cm.material = dark
		mi.mesh = cm
		mi.position = w
		mi.rotation.z = PI * 0.5
		body.add_child(mi)


func _switch_house() -> void:
	floor_rect(0, -12, -16, -8, -12, "concrete", FLOOR, false)
	floor_rect(UP, -12, -16, -8, -12, "concrete", ROOF_COLOR)
	line(0, Vector2(-12, -16), Vector2(1, 0), "DW", [
		{"id": "switch_door", "into": Vector2(-11, -14), "locked": true, "pick": 4.0}])
	line(0, Vector2(-12, -16), Vector2(0, 1), "WW")
	line(0, Vector2(-8, -16), Vector2(0, 1), "WW")
	fuse_box(Vector3(-10, 1.2, -12.12), 180.0)


func _roof() -> void:
	# The hall's flat roof, with a hole for the skylight over the catwalk.
	floor_rect(ROOF, -14, -12, 14, -6, "concrete", ROOF_COLOR)
	floor_rect(ROOF, -14, -4, 14, 6, "concrete", ROOF_COLOR)
	floor_rect(ROOF, -14, -6, 1.5, -4, "concrete", ROOF_COLOR)
	floor_rect(ROOF, 3.5, -6, 14, -4, "concrete", ROOF_COLOR)
	line(ROOF, Vector2(-14, -12), Vector2(1, 0), "--------------")
	line(ROOF, Vector2(-14, 6), Vector2(1, 0), "--------------")
	line(ROOF, Vector2(-14, -12), Vector2(0, 1), "---------")
	line(ROOF, Vector2(14, -12), Vector2(0, 1), "---------")
	# The skylight's curb.
	var curb := Kit.flat(Color(0.5, 0.5, 0.52))
	Kit.block(self, Vector3(2.5, ROOF + 0.15, -6.1), Vector3(2.4, 0.3, 0.2), "", curb)
	Kit.block(self, Vector3(2.5, ROOF + 0.15, -3.9), Vector3(2.4, 0.3, 0.2), "", curb)
	Kit.block(self, Vector3(1.4, ROOF + 0.15, -5), Vector3(0.2, 0.3, 2.4), "", curb)
	Kit.block(self, Vector3(3.6, ROOF + 0.15, -5), Vector3(0.2, 0.3, 2.4), "", curb)
	openings.append({"id": "skylight", "kind": "window", "pos": Vector3(2.5, ROOF, -5)})


# --- The line ----------------------------------------------------------------------

func _line() -> void:
	bottling_line = BottlingLine.new()
	bottling_line.name = "Line"
	bottling_line.level = self
	bottling_line.hatch_x = 14.0
	add_child(bottling_line)
	bottling_line.lay_belt(22.0, -10.0, BELT_Z)
	_machine("machine-window.glb", Vector3(10, 0, BELT_Z))
	_machine("machine-connection-pipe.glb", Vector3(6, 0, BELT_Z))
	_machine("machine-fortified.glb", CAPPER)
	_machine("machine.glb", Vector3(-4, 0, BELT_Z))
	var scanner := Kit.solid(self, FACTORY + "scanner-high.glb", Vector3(-7.2, 0, BELT_Z), 0.0, Vector3.ONE * MACHINE_SCALE)
	scanner.name = "Scanner"
	for x in [10.0, 6.0, CAPPER.x, -4.0]:
		bottling_line.add_hum(Vector3(x, 1.2, BELT_Z), "machine_hum_loop", -10.0)
	for x in [18.0, 2.0, -8.0]:
		bottling_line.add_hum(Vector3(x, 1.0, BELT_Z), "conveyor_loop", -12.0)
	# The din drowns out footsteps near the line, and some way off.
	bottling_line.add_mask(AABB(Vector3(-12, -1, -4.5), Vector3(26, 4.5, 7.5)), 0.75)
	bottling_line.add_mask(AABB(Vector3(-14, -1, -12), Vector3(28, ROOF, 18)), 0.4)
	bottling_line.add_mask(AABB(Vector3(14, -1, -3.5), Vector3(10, 3.5, 5)), 0.5)
	# Robot arms by the filler and the labeller.
	for p in [Vector3(7.8, 0, -3.6), Vector3(-2.2, 0, 1.6)]:
		var arm := Kit.boxed(self, FACTORY + "robot-arm-a.glb", p, 0.0, 1.2)
		var joint := arm.find_child("element-a", true, false) as Node3D
		if joint:
			bottling_line.add_spinner(joint, 0.7)
	# Syrup tanks feed the filler.
	for p in [Vector3(7, 0, -7.6), Vector3(10.2, 0, -7.6)]:
		Kit.boxed(self, FACTORY + "hopper-high-round.glb", p, 0.0, 2.0, "concrete")
	var pipe := Kit.flat(Color(0.33, 0.36, 0.55))
	Kit.block(self, Vector3(6, 3.4, -5.0), Vector3(0.3, 0.3, 4.0), "", pipe, false)
	Kit.block(self, Vector3(6, 2.95, -3.1), Vector3(0.3, 0.9, 0.3), "", pipe, false)
	# The capper's step, the bottle caps and the emergency stop.
	Kit.block(self, CAPPER + Vector3(0, 0.6, -2.1), Vector3(1.0, 1.2, 0.9), "concrete", Kit.flat(Color(0.35, 0.38, 0.5)))
	var stripe := MeshInstance3D.new()
	var sm := BoxMesh.new()
	sm.size = Vector3(1.02, 0.08, 0.92)
	sm.material = Kit.flat(RAIL)
	stripe.mesh = sm
	stripe.position = CAPPER + Vector3(0, 1.17, -2.1)
	add_child(stripe)
	Kit.boxed(self, FACTORY + "hopper-round.glb", CAPPER + Vector3(-1.3, 0, 2.3), 0.0, 0.9)
	_cog()
	_estop()
	_panel()


func _machine(model: String, at: Vector3) -> StaticBody3D:
	var m := Kit.solid(self, FACTORY + model, at, 0.0, Vector3.ONE * MACHINE_SCALE, "concrete")
	m.name = model.get_basename().to_pascal_case()
	return m


func _cog() -> void:
	cog = UsableBody.new()
	cog.name = "DriveCog"
	cog.position = CAPPER + Vector3(0, COG_Y, 0)
	_cog_model = Kit.scene(FACTORY + "cog-a.glb").instantiate()
	_cog_model.scale = Vector3.ONE * COG_SCALE
	_cog_model.position = Vector3(0, 0.15 * COG_SCALE + 0.05, 0)
	cog.add_child(_cog_model)
	# The shaft it turns on.
	var shaft := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.12
	cm.bottom_radius = 0.12
	cm.height = 0.5
	cm.material = Kit.flat(Color(0.3, 0.3, 0.33))
	shaft.mesh = cm
	shaft.position = Vector3(0, 0.1, 0)
	cog.add_child(shaft)
	cog.add_box(Vector3(0, 0.22, 0), Vector3(1.5, 0.4, 1.5))
	cog.add_action("interact", "Unbolt the cog", _take_cog)
	add_child(cog)
	treasure_stand = cog
	bottling_line.cog_model = _cog_model
	bottling_line.add_spinner(_cog_model, 1.4)


func _estop() -> void:
	estop = UsableBody.new()
	estop.name = "EmergencyStop"
	estop.position = CAPPER + Vector3(-0.4, 1.25, 1.66)
	var box := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.3, 0.3, 0.12)
	bm.material = Kit.flat(RAIL)
	box.mesh = bm
	estop.add_child(box)
	var knob := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.1
	cm.bottom_radius = 0.1
	cm.height = 0.1
	cm.material = Kit.flat(Color(0.85, 0.1, 0.08))
	knob.mesh = cm
	knob.rotation.x = PI * 0.5
	knob.position = Vector3(0, 0, 0.1)
	estop.add_child(knob)
	estop.add_box(Vector3(0, 0, 0.05), Vector3(0.34, 0.34, 0.22))
	estop.add_action("interact", "Hit the emergency stop", _hit_estop)
	estop.set_meta("dartable", true)
	add_child(estop)
	bottling_line.changed.connect(_on_line_changed)


func _panel() -> void:
	Kit.boxed(self, FACTORY + "screen-panel-wide.glb", Vector3(-12.6, 0, -4.0), 90.0, 1.6, "concrete")
	var pedestal := Kit.flat(Color(0.35, 0.38, 0.5))
	Kit.block(self, Vector3(-12.2, 0.45, -2.7), Vector3(0.5, 0.9, 0.5), "", pedestal)
	panel_lever = _lever("PanelLever", Vector3(-12.2, 0.9, -2.7), 90.0, "Stop the line", _pull_panel)
	Kit.block(self, Vector3(-8.2, UP + 0.45, -11.4), Vector3(0.5, 0.9, 0.5), "", pedestal)
	office_lever = _lever("OfficeLever", Vector3(-8.2, UP + 0.9, -11.4), 0.0, "Stop the line", _pull_office)


func _lever(n: String, pos: Vector3, yaw: float, verb: String, on_use: Callable) -> UsableBody:
	var u := UsableBody.new()
	u.name = n
	u.position = pos
	u.rotation.y = deg_to_rad(yaw)
	var m: Node3D = Kit.scene(FACTORY + "lever-double.glb").instantiate()
	m.scale = Vector3.ONE * 0.9
	u.add_child(m)
	u.add_box(Vector3(0, 0.18, 0), Vector3(0.5, 0.36, 0.5))
	u.add_action("interact", verb, on_use)
	u.set_meta("dartable", true)
	add_child(u)
	return u


# --- Furniture and dressing --------------------------------------------------------

func _furnish() -> void:
	# Packing at the west end of the belt.
	Kit.block(self, Vector3(-11.2, 0.45, BELT_Z), Vector3(1.2, 0.9, 1.6), "wood", Kit.flat(Color(0.55, 0.42, 0.28)))
	for p in [Vector3(-12.6, 0, -7.4), Vector3(-12.6, 0.55, -7.4), Vector3(-8.6, 0, -7.0)]:
		Kit.boxed(self, FACTORY + "box-large.glb", p, 90.0, 1.0)
	# Stores under the office: racking and boxes.
	var rack := Kit.flat(Color(0.35, 0.38, 0.5))
	for x in [-13.2, -11.2]:
		Kit.block(self, Vector3(x, 1.1, -11.2), Vector3(1.6, 2.2, 1.0), "", rack)
	Kit.boxed(self, FACTORY + "box-wide.glb", Vector3(-8.5, 0, -11.2), 0.0, 1.6)
	Kit.boxed(self, FACTORY + "box-small.glb", Vector3(-8.2, 0, -9.6), 30.0, 1.6)
	# Warning posts and cones by the line.
	for p in [Vector3(-1.2, 0, 2.7), Vector3(12.6, 0, 1.8), Vector3(4.2, 0, -4.4)]:
		Kit.boxed(self, FACTORY + "warning-traffic.glb", p, 0.0, 1.2)
	for p in [Vector3(13.3, 0, 0.6), Vector3(13.3, 0, -2.6)]:
		Kit.boxed(self, FACTORY + "cone.glb", p, 0.0, 1.6)
	# Break room: a table, a sofa, the counter with the kettle and a fridge.
	Kit.furniture(self, "table", Vector3(-11, 0, 3.0), 0)
	for c in [[Vector3(-11.8, 0, 3.0), 90], [Vector3(-10.2, 0, 3.0), -90], [Vector3(-11, 0, 2.2), 0]]:
		Kit.furniture(self, "chair", c[0], c[1])
	Kit.furniture(self, "loungeSofa", Vector3(-12.2, 0, 5.4), 180)
	Kit.furniture(self, "kitchenCabinet", Vector3(-9.3, 0, 5.55), 180)
	Kit.furniture(self, "kitchenSink", Vector3(-8.45, 0, 5.55), 180)
	Kit.furniture(self, "kitchenFridgeSmall", Vector3(-9.0, 0, 0.35), 0)
	Kit.furniture(self, "radio", Vector3(-9.6, 0.9, 5.7), 180, false)
	Kit.furniture(self, "trashcan", Vector3(-13.5, 0, 0.6), 0)
	# Lockers and a bench.
	for i in 3:
		Kit.furniture(self, "bookcaseClosedDoors", Vector3(-7.6 + i * 0.82, 0, 5.72), 180)
	Kit.furniture(self, "bench", Vector3(-6.0, 0, 3.7), 0)
	# Hard hats on hooks.
	for z in [2.8, 3.5]:
		Kit.model(self, Kit.PROTOTYPE + "hat-hard.glb", Vector3(-4.25, 1.6, z), -90.0, 1.4)
	# The office: desk, chair, screens, filing and the foreman's lever.
	Kit.furniture(self, "desk", Vector3(-11.5, UP, -11.4), 0)
	Kit.furniture(self, "chairDesk", Vector3(-11.5, UP, -10.5), 180)
	Kit.furniture(self, "computerScreen", Vector3(-11.9, UP + 0.76, -11.5), 0, false)
	Kit.furniture(self, "bookcaseClosed", Vector3(-13.6, UP, -8.5), 90)
	Kit.furniture(self, "coatRackStanding", Vector3(-13.5, UP, -6.6), 0)
	Kit.boxed(self, FACTORY + "screen-flat.glb", Vector3(-9.2, UP, -11.5), 0.0, 1.0)
	# The dock: crates, empties by the belt's loading end.
	Kit.boxed(self, FACTORY + "box-large.glb", Vector3(22.9, 0, 1.0), 90.0, 1.8)
	Kit.boxed(self, FACTORY + "box-large.glb", Vector3(22.9, 0.99, 1.0), 80.0, 1.8)
	Kit.boxed(self, FACTORY + "box-wide.glb", Vector3(23.2, 0, -2.7), 0.0, 1.4)
	Kit.boxed(self, FACTORY + "box-small.glb", Vector3(15.2, 0, -10.0), 0.0, 1.4)
	# North yard: the switch house's neighbours, pallets and bins.
	Kit.boxed(self, FACTORY + "box-long.glb", Vector3(-17, 0, -15), 90.0, 1.6)
	Kit.boxed(self, FACTORY + "box-large.glb", Vector3(16, 0, -16), 20.0, 1.6)


func _yard() -> void:
	# The foreman's car, and a smoking shelter by the staff door.
	Kit.boxed(self, CARS + "sedan.glb", Vector3(9.5, 0, 13), 0.0, 1.5)
	var shelter := Kit.flat(Color(0.4, 0.44, 0.5))
	Kit.block(self, Vector3(-11.5, 2.3, 11), Vector3(3.2, 0.1, 2.0), "", shelter)
	for p in [Vector3(-13, 1.15, 10.1), Vector3(-10, 1.15, 10.1)]:
		Kit.block(self, p, Vector3(0.1, 2.3, 0.1), "", shelter)
	Kit.block(self, Vector3(-11.5, 1.2, 10.05), Vector3(3.2, 1.6, 0.06), "", Kit.flat(Color(0.6, 0.7, 0.75)))
	Kit.furniture(self, "bench", Vector3(-11.5, 0, 10.6), 0)
	Kit.furniture(self, "trashcan", Vector3(-9.6, 0, 10.8), 0)
	# Bins and pallets down the west side.
	for p in [Vector3(-16.5, 0, 3.5), Vector3(-16.5, 0, -2)]:
		Kit.block(self, p + Vector3(0, 0.6, 0), Vector3(1.4, 1.2, 1.0), "concrete", Kit.flat(Color(0.2, 0.35, 0.25)))
	Kit.boxed(self, FACTORY + "box-wide.glb", Vector3(-16.6, 0, -7), 0.0, 1.8)


# --- Lights --------------------------------------------------------------------------

func _lamps() -> void:
	# Work lamps hang over the line.
	for x in [-8.0, 0.0, 8.0]:
		lamp("line", Vector3(x, 5.6, BELT_Z + 0.5), true, 1.5, 8.0, Color(1.0, 0.95, 0.85))
	lamp("stores", Vector3(-10, UP, -9), false, 1.0, 5.0)
	lamp("office", Vector3(-10, TOP, -9), true, 1.1, 6.0)
	lamp("break", Vector3(-11, UP, 3), false, 1.1, 5.0)
	lamp("lockers", Vector3(-6, UP, 4), false, 0.9, 4.0)
	lamp("dock", Vector3(19, TOP, -4), true, 1.3, 8.0, Color(0.9, 0.95, 1.0))
	lamp("switch", Vector3(-10, UP, -14), false, 0.9, 4.0)
	# A floodlight over the staff door, and the street lamp at the gate.
	var flood := SpotLight3D.new()
	flood.position = Vector3(-5, 4.2, 6.6)
	flood.rotation = Vector3(deg_to_rad(-65), 0, 0)
	flood.light_color = Color(1.0, 0.9, 0.7)
	flood.spot_range = 9.0
	flood.spot_angle = 50.0
	flood.light_energy = 1.6
	flood.shadow_enabled = true
	flood.add_to_group("stealth_lights")
	add_child(flood)
	lights["yard"] = [flood]
	Kit.block(self, Vector3(4, 2.0, 25.4), Vector3(0.15, 4.0, 0.15), "", Kit.flat(Color(0.2, 0.2, 0.2)), false)
	var street := SpotLight3D.new()
	street.position = Vector3(4, 4.0, 25.4)
	street.rotation.x = -PI * 0.5
	street.light_color = Color(1.0, 0.8, 0.5)
	street.spot_range = 9.0
	street.spot_angle = 60.0
	street.light_energy = 2.0
	street.shadow_enabled = true
	street.add_to_group("stealth_lights")
	add_child(street)
	lights["gate"] = [street]
	light_switch(["line"], Vector3(-9.5, 1.3, -0.12), Vector3(0, 0, -1))
	light_switch(["break"], Vector3(-11.8, 1.3, 0.12), Vector3(0, 0, 1))
	light_switch(["lockers"], Vector3(-4.12, 1.3, 2.6), Vector3(-1, 0, 0))
	light_switch(["office"], Vector3(-8.3, UP + 1.3, -6.12), Vector3(0, 0, -1))
	light_switch(["stores"], Vector3(-6.18, 1.3, -6.6), Vector3(1, 0, 0))
	light_switch(["dock"], Vector3(14.14, 1.3, -3.6), Vector3(1, 0, 0))
	light_switch(["switch"], Vector3(-11.5, 1.3, -15.88), Vector3(0, 0, 1))


# --- Things to use ---------------------------------------------------------------------

func _things() -> void:
	note("hoard_letter", "A letter on the foreman's desk", HOARD_LETTER, Vector3(-11.1, UP + 0.77, -11.3), -10.0, Vector3(0.22, 0.01, 0.3))
	note("foreman_log", "The line log", FOREMAN_LOG, Vector3(-13.88, UP + 1.5, -10.0), 90.0)
	note("shift_rota", "The shift rota", SHIFT_ROTA, Vector3(-10.5, 1.5, 0.13), 0.0, Vector3(0.3, 0.4, 0.01))
	note("clock_cutting", "A newspaper cutting", CLOCK_CUTTING, Vector3(-10.0, 1.5, 0.13), 0.0, Vector3(0.24, 0.3, 0.01))
	note("rosa_note", "A note in the smoking shelter", ROSA_NOTE, Vector3(-11.0, 1.4, 10.1), 0.0)
	note("switch_tag", "A tag on the switch house door", SWITCH_TAG, Vector3(-9.0, 1.3, -16.13), 180.0)
	note("crane_docket", "A docket on the crane's controls", CRANE_DOCKET, Vector3(16.6, 1.12, -8.6), 90.0, Vector3(0.2, 0.01, 0.26))
	note("belt_note", "A note by the conveyor", BELT_NOTE, Vector3(22.9, 1.1, -1.0), 0.0, Vector3(0.2, 0.01, 0.26))
	Kit.block(self, Vector3(22.9, 0.5, -1.0), Vector3(0.12, 1.0, 0.12), "", Kit.flat(Color(0.3, 0.3, 0.33)), false)
	# The staff door's keypad: the code's on Rosa's note.
	keypad("staff", "1904", Vector3(-3.7, 1.3, 6.14), 0.0, "staff_door")
	# Hard hat and vest on the locker room bench.
	disguise_pickup("worker", "Put on the hard hat and vest", Kit.PROTOTYPE + "hat-hard.glb", Vector3(-6.0, 0.95, 3.7), 1.4, 20.0,
		"Hard hat and hi-vis. You look like you work here.")
	# The kettle.
	kettle = UsableBody.new()
	kettle.name = "Kettle"
	kettle.position = Vector3(-9.3, 0.92, 5.5)
	var pot := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.09
	cm.bottom_radius = 0.12
	cm.height = 0.24
	cm.material = Kit.flat(Color(0.8, 0.82, 0.85), 0.3)
	pot.mesh = cm
	pot.position = Vector3(0, 0.12, 0)
	kettle.add_child(pot)
	kettle.add_box(Vector3(0, 0.12, 0), Vector3(0.3, 0.3, 0.3))
	kettle.add_action("interact", "Put the kettle on", _use_kettle)
	add_child(kettle)
	Kit.model(self, Kit.FOOD + "mug.glb", Vector3(-9.0, 0.92, 5.5), 30.0, 0.5)
	# A bottle cap from the capper's hopper.
	var caps := UsableBody.new()
	caps.name = "BottleCaps"
	caps.position = CAPPER + Vector3(-1.3, 0.95, 2.3)
	for i in 5:
		var c := _bottle_cap_mesh()
		c.position = Vector3(randf_range(-0.3, 0.3), 0.02 * i, randf_range(-0.3, 0.3))
		caps.add_child(c)
	caps.add_box(Vector3(0, 0.05, 0), Vector3(0.9, 0.2, 0.9))
	caps.add_action("interact", "Take a bottle cap", _take_cap)
	add_child(caps)
	# The skylight, and the rope the Moth brought.
	skylight = UsableBody.new()
	skylight.name = "Skylight"
	skylight.position = Vector3(2.5, ROOF + 0.3, -5)
	var glass := MeshInstance3D.new()
	var gm := BoxMesh.new()
	gm.size = Vector3(2.0, 0.05, 2.0)
	var gmat := StandardMaterial3D.new()
	gmat.albedo_color = Color(0.6, 0.75, 0.85, 0.4)
	gmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gm.material = gmat
	glass.mesh = gm
	skylight.add_child(glass)
	skylight.add_box(Vector3.ZERO, Vector3(2.0, 0.1, 2.0))
	skylight.collision_layer = Kit.LAYER_GLASS | Kit.LAYER_INTERACT
	skylight.add_action("interact", "Lift the skylight", _open_skylight)
	add_child(skylight)
	rope = BottlingLadder.make("skylight", Vector3(2.55, UP, -5.0), Vector3(2.55, UP, -4.6), Vector3(2.55, ROOF, -6.7), Color(), true)
	add_child(rope)
	rope.set_usable(false)
	# Hiding: a locker, an empty crate in the dock, the stores' big box.
	hide_spot("locker", "Hide in a locker", Vector3(-5.14, 0, 5.5), 180.0, Vector3(0, 1.4, 0), Vector3(0.8, 2.0, 0.6))
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(-5.14, 0, 5.72), 180)
	hide_spot("crate", "Hide in the empty crate", Vector3(15.4, 0, 0.9), 90.0, Vector3(0, 0.8, 0), Vector3(1.6, 1.1, 1.6))
	Kit.boxed(self, FACTORY + "box-large.glb", Vector3(15.4, 0, 0.9), 90.0, 1.6)
	hide_spot("stores_box", "Hide in the big crate", Vector3(-13.0, 0, -8.6), 90.0, Vector3(0, 0.8, 0), Vector3(1.6, 1.1, 1.6))
	Kit.boxed(self, FACTORY + "box-large.glb", Vector3(-13.0, 0, -8.6), 0.0, 1.6)


func _bottle_cap_mesh() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.07
	cm.bottom_radius = 0.075
	cm.height = 0.03
	cm.radial_segments = 12
	cm.material = Kit.flat(Color(0.85, 0.15, 0.1), 0.4)
	mi.mesh = cm
	return mi


func _marks() -> void:
	add_start("gate", Vector3(0, 0, 26.5), 0)
	add_start("dock", Vector3(34, 0, -6), 90)
	add_start("skylight", Vector3(4.6, ROOF, -6.9), 100)
	points = {
		"desk": Vector3(-11.5, UP, -10.0), "office_window": Vector3(-10.5, UP, -6.8),
		"office_lever": Vector3(-8.2, UP, -10.5), "landing": Vector3(-8, UP, -5.2),
		"stairs_foot": Vector3(0.2, 0, -5.25), "panel": Vector3(-11.4, 0, -4.0),
		"packing": Vector3(-12.4, 0, BELT_Z), "filler": Vector3(6, 0, 1.4),
		"capper": Vector3(1.2, 0, 1.5), "washer": Vector3(10, 0, 1.4),
		"walkway": Vector3(4, 0, 3.6), "loading": Vector3(23.0, 0, BELT_Z),
		"dock": Vector3(19.5, 0, -3.4), "dock_crates": Vector3(22.0, 0, -2.8),
		"tea_rosa": Vector3(-11.75, 0, 3.0), "tea_eddie": Vector3(-10.25, 0, 3.0),
		"sofa": Vector3(-12.2, 0, 5.1), "lockers": Vector3(-6, 0, 4.6),
		"fuse_box": Vector3(-10, 0, -13.0), "north_yard": Vector3(-3, 0, -14.5),
	}


# --- Using things ----------------------------------------------------------------------

func _take_cog(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if not bottling_line.has_cog:
		if not cap_left and player.take_item("bottle_cap"):
			_cap_model = _bottle_cap_mesh()
			_cap_model.scale = Vector3.ONE * 2.0
			_cap_model.position = Vector3(0, 0.37, 0)
			cog.add_child(_cap_model)
			cap_left = true
			_record("cap_on_drive")
			Sfx.at(self, "kenney:metalClick", cog.global_position, -8.0)
		_update_cog_text(player)
		return
	if bottling_line.running:
		UsableBody.hint(pic, "It's spinning. Stop the line first.")
		return
	bottling_line.has_cog = false
	_cog_model.visible = false
	player.add_item("cog")
	Sfx.at(self, "kenney:metalLatch", cog.global_position, -4.0, 0.8)
	Sfx.at(self, "caper_done", cog.global_position, -6.0)
	StealthNoise.make(self, cog.global_position, 3.0, "pick", player)
	UsableBody.hint(pic, "The clock tower's cog. Heavy, and still warm.")
	_record("took_treasure")
	if not player.bag_changed.is_connected(_update_cog_text):
		player.bag_changed.connect(_update_cog_text.bind(player))
	_update_cog_text(player)


## Once the cog's gone, the drive offers to take a bottle cap.
func _update_cog_text(player: Node) -> void:
	if bottling_line.has_cog:
		cog.set_action_text("interact", "Unbolt the cog")
		return
	var can_leave: bool = not cap_left and player.has_item("bottle_cap")
	cog.set_action_text("interact", "Leave the bottle cap" if can_leave else "")


func _take_cap(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if player.has_item("bottle_cap") or cap_left:
		UsableBody.hint(pic, "One's plenty.")
		return
	player.add_item("bottle_cap")
	Sfx.at(self, "kenney:metalClick", pic.get_parent().global_position, -12.0, 1.6)
	_record("took:bottle_cap")


func _hit_estop(pic: PlayerInteractionComponent) -> void:
	if not bottling_line.running:
		return
	var player: Node3D = pic.get_parent()
	bottling_line.set_running(false, "estop")
	Sfx.at(self, "kenney:metalClick", estop.global_position, -2.0, 0.7)
	if player.global_position.distance_to(estop.global_position) > 3.0:
		_record("estop_darted")


func _pull_panel(pic: PlayerInteractionComponent) -> void:
	_pull(pic, panel_lever, "lever")


func _pull_office(pic: PlayerInteractionComponent) -> void:
	_pull(pic, office_lever, "office")


func _pull(pic: PlayerInteractionComponent, lever: UsableBody, by: String) -> void:
	if power_off():
		UsableBody.hint(pic, "Nothing happens. The power's off.")
		return
	_flip(lever)
	bottling_line.set_running(not bottling_line.running, by)


func _flip(lever: UsableBody) -> void:
	var handle := lever.find_child("handle", true, false) as Node3D
	if handle:
		var t := handle.create_tween()
		t.tween_property(handle, "rotation:x", 0.0 if bottling_line.running else 0.7, 0.25)
	Sfx.at(self, "kenney:metalClick", lever.global_position, -6.0, 0.8)


func _on_line_changed(running: bool) -> void:
	var verb := "Stop the line" if running else "Start the line"
	panel_lever.set_action_text("interact", verb)
	office_lever.set_action_text("interact", verb)
	estop.set_action_text("interact", "Hit the emergency stop" if running else "")
	for lever in [panel_lever, office_lever]:
		var handle := lever.find_child("handle", true, false) as Node3D
		if handle:
			handle.rotation.x = 0.0 if running else 0.7
	if running:
		_stopped_t = 0.0
		_restarter = null


func _use_kettle(pic: PlayerInteractionComponent) -> void:
	if _kettle_boiled:
		_record("had_tea")
		UsableBody.hint(pic, "A proper cup of tea. Lovely.")
		Sfx.at(self, "kenney:cardPlace1", kettle.global_position, -10.0)
		kettle.set_action_text("interact", "")
		return
	if _kettle_t >= 0.0:
		return
	_kettle_t = 0.0
	Sfx.at(self, "kenney:metalClick", kettle.global_position, -10.0, 1.4)
	kettle.set_action_text("interact", "")
	_record("kettle_on")


## The kettle whistles: Rosa and Eddie down tools for a cup.
func kettle_whistles() -> void:
	_kettle_boiled = true
	_kettle_t = -1.0
	Sfx.at(self, "kettle_whistle", kettle.global_position + Vector3(0, 0.3, 0), 0.0)
	kettle.set_action_text("interact", "Make a cup of tea")
	var went := false
	for w in [rosa, eddie]:
		if w == null or not is_instance_valid(w):
			continue
		var seat := "tea_rosa" if w == rosa else "tea_eddie"
		var face := Vector3(1, 0, 0) if w == rosa else Vector3(-1, 0, 0)
		if w.send("tea", seat, 25.0, w.extra_lines[0], Callable(), "sit", face):
			went = true
	if went:
		_record("tea_lure")
	if platt != null and platt.is_free() and platt.global_position.distance_to(kettle.global_position) < 15.0:
		platt.say(platt.extra_lines[0])


func _open_skylight(pic: PlayerInteractionComponent) -> void:
	Sfx.at(self, "kenney:metalLatch", skylight.global_position, -6.0, 1.2)
	StealthNoise.make(self, skylight.global_position, 3.0, "door", pic.get_parent())
	skylight.rotation.z = deg_to_rad(70.0)
	skylight.position += Vector3(-0.9, 0.9, 0)
	skylight.collision_layer = 0
	skylight.set_action_text("interact", "")
	rope.set_usable(true)
	UsableBody.hint(pic, "You tie off your rope and let it fall.")
	_record("opened_skylight")


# --- Who comes to restart the line -------------------------------------------------------

func _physics_process(delta: float) -> void:
	super(delta)
	var p := get_tree().get_first_node_in_group("moth") as Moth
	if p != null and JobRun.current != null:
		var feet := p.feet_position()
		if feet.y < 0.35 and p.is_on_floor() and p.hiding == null:
			_record("touched_floor")
		if p.disguise == "worker" and _floor_box.has_point(p.global_position) and not _rooms_box.has_point(p.global_position):
			_record("worker_on_floor")
	if _kettle_t >= 0.0:
		_kettle_t += delta
		if _kettle_t >= KETTLE_TIME:
			kettle_whistles()
	_restart_check(delta)


## A stopped line (not the power) gets someone along to restart it: Platt
## to his own lever if that's what stopped it, else whoever's nearest the
## control panel.
func _restart_check(delta: float) -> void:
	if bottling_line.running or bottling_line.stopped_by in ["power", ""] or platt == null or power_off():
		return
	_stopped_t += delta
	if _stopped_t < RESTART_DELAY:
		return
	if _restarter != null and is_instance_valid(_restarter) and _restarter.errand == "restart":
		return
	_restarter = null
	var who: BottlingWorker
	var point := "panel"
	var text := ""
	if bottling_line.stopped_by == "office":
		who = platt
		point = "office_lever"
		text = "Who's been at my lever?"
	else:
		var best := INF
		for w in [rosa, eddie, platt]:
			if w == null or not w.is_free():
				continue
			var d: float = w.global_position.distance_to(points["panel"])
			if d < best:
				best = d
				who = w
		if who != null:
			text = who.extra_lines[1]
	if who == null or not who.is_free():
		return
	var face := Vector3(0, 0, -1) if point == "office_lever" else Vector3(-1, 0, 0)
	if who.send("restart", point, 4.0, text, _restart_by, "interact-right", face):
		_restarter = who
		if who != platt:
			_record("worker_checked_line")


## Someone at a lever tries to get the line going again.
func _restart_by(who: BottlingWorker) -> void:
	_restarter = null
	if bottling_line.running:
		return
	if not bottling_line.has_cog:
		_cog_missing(who)
		return
	_flip(office_lever if bottling_line.stopped_by == "office" else panel_lever)
	bottling_line.set_running(true, who.name.to_lower())
	who.say(who.extra_lines[2])


## The line won't start: the drive cog's gone, and the alarm goes up.
func _cog_missing(who: BottlingWorker) -> void:
	bottling_line.jam()
	who.say("The drive cog's gone! We've been robbed!")
	_record("cog_missed")
	raise_alarm(cog.global_position, "cog")
	_stopped_t = -20.0


func _on_crash(at: Vector3) -> void:
	for w in [platt, rosa, eddie]:
		if w == null or w.is_asleep() or w.state == Person.State.CHASE:
			continue
		if w.global_position.distance_to(at) < BottlingCrane.CRASH_RADIUS + 10.0:
			w.errand = ""
			w._curious(at, 0.9, w.extra_lines[3])


## The power off stops the line; when Platt puts it back the line starts
## again, or doesn't, if the cog's gone.
func set_power(on: bool) -> void:
	var was_off := power_off()
	super(on)
	if bottling_line == null:
		return
	if not on and not was_off:
		if bottling_line.running:
			bottling_line.set_running(false, "power")
	elif on and was_off and bottling_line.stopped_by == "power":
		if bottling_line.has_cog:
			bottling_line.set_running(true, "power")
		elif platt != null:
			_cog_missing(platt)


## A plant worker belongs on the floor, but not with the drive cog under
## their arm.
func expects(person: Person, p: Moth) -> bool:
	if p.has_item("cog"):
		return false
	return super(person, p)


## Caught with the cog: it goes back on the capper (and the cap comes off).
func return_treasure() -> void:
	if bottling_line.has_cog:
		return
	bottling_line.has_cog = true
	_cog_model.visible = true
	if _cap_model:
		_cap_model.queue_free()
		_cap_model = null
		cap_left = false
	_update_cog_text(null)


func _on_way_out(id: String) -> void:
	var p := get_tree().get_first_node_in_group("moth") as Moth
	if p and p.has_item("cog"):
		_record("left_by:" + id)


# --- People ---------------------------------------------------------------------------------

func voice_info() -> Dictionary:
	return {
		"bottling_foreman": {"who": "Mr Platt, the night foreman: a gruff, fussy Northern English man in his fifties, proud of his line", "kokoro": "bm_lewis", "speed": 1.0},
		"bottling_rosa": {"who": "Rosa, a line worker: quick, sensible and dry, in her thirties, fond of her tea", "kokoro": "af_nicole", "speed": 1.05},
		"bottling_eddie": {"who": "Eddie, a line worker: young, cheerful and a bit dozy", "kokoro": "am_eric", "speed": 1.0},
	}


func screenshot_views() -> Dictionary:
	return {
		"gate": [Vector3(0, 0, 21), 0.0, 3.0],
		"yard": [Vector3(-8, 0, 16), -20.0, 5.0],
		"staff_door": [Vector3(-3, 0, 10), 20.0, 0.0],
		"north_yard": [Vector3(4, 0, -18), 120.0, 0.0],
		"switch_house": [Vector3(-10, 0, -15.2), 180.0, 0.0],
		"floor_east": [Vector3(12, 0, 4.5), 50.0, 5.0],
		"floor_west": [Vector3(-3, 0, 4.5), -45.0, 5.0],
		"capper": [Vector3(3.5, 0, 3), 37.0, 10.0],
		"line": [Vector3(12.5, 0, 2.0), 75.0, 0.0],
		"catwalk": [Vector3(2.55, UP, -8), 180.0, -20.0],
		"catwalk_cog": [Vector3(2.4, UP, -3.5), 150.0, -35.0],
		"north_catwalk": [Vector3(-4, UP, -11.2), -90.0, -15.0],
		"office": [Vector3(-7.5, UP, -7), 60.0, -10.0],
		"office_view": [Vector3(-10.5, UP, -8.4), 180.0, -20.0],
		"stairs": [Vector3(2, 0, -3.8), 70.0, 10.0],
		"break": [Vector3(-9.0, 0, 1.0), 140.0, -10.0],
		"lockers": [Vector3(-4.8, 0, 2.8), 120.0, -10.0],
		"dock": [Vector3(15, 0, -0.5), -60.0, 5.0],
		"crane": [Vector3(15.2, 0, -10), -125.0, 15.0],
		"dock_catwalk": [Vector3(15, UP, -11.2), -90.0, -10.0],
		"truck": [Vector3(30, 0, 2), 10.0, 0.0],
		"hatch": [Vector3(18, 0, -2.8), 75.0, 0.0],
		"roof": [Vector3(8, ROOF, -2), 61.0, -15.0],
		"belt_ride": [Vector3(19.5, BottlingLine.BELT_TOP, BELT_Z), 90.0, -10.0],
	}


func add_people(p_run: JobRun) -> Array:
	platt = BottlingWorker.new()
	platt.setup("Platt", "male-d", self, p_run, [
		{"at": "desk", "face": Vector3(0, 0, -1), "clip": "phone-call", "time": 24.0, "room": "office", "say": "Yes, Mr Hoard. Ticking along nicely, Mr Hoard."},
		{"at": "office_window", "face": Vector3(0, 0, 1), "clip": "look-around", "time": 14.0},
		{"at": "stairs_foot", "time": 1.0},
		{"at": "panel", "face": Vector3(-1, 0, 0), "time": 8.0, "say": "Keep it moving, Rosa."},
		{"at": "capper", "face": Vector3(0, 0, -1), "clip": "look-around", "time": 10.0, "room": "line", "say": "Lovely bit of brass, that."},
		{"at": "dock", "face": Vector3(1, 0, 0), "time": 9.0, "room": "dock", "say": "Mind those crates, Eddie."},
		{"at": "washer", "face": Vector3(0, 0, -1), "time": 4.0},
		{"at": "office_lever", "face": Vector3(0, 0, -1), "time": 6.0, "say": "Nobody touches my lever."},
		{"at": "desk", "face": Vector3(0, 0, -1), "time": 20.0, "room": "office"},
	], "bottling_foreman", {
		"mumble": "low", "fixes_power": true, "answers_alarm": true, "accepts": ["worker"],
		"lines": {
			"curious": ["Hm? Who's that?", "What's that racket?"],
			"seen": ["Who's down there?"],
			"spotted": ["Oi! You're not on my shift!", "Burglar! On my floor!"],
			"others": ["What's going on down there?"],
			"lost": ["Come out, I know you're here!"],
			"give_up": ["Nobody. Back to work.", "Must be the pipes."],
			"catch": ["Out! And stay out!"],
			"power_out": ["Not the fuses again!"],
			"power_fixed": ["Power's back. Get that line moving!"],
			"alarm": ["Who's been at my line?"],
			"bark": ["What's that racket?"],
			"wake": ["Wha...? I was checking my eyelids."],
		},
		"extra_lines": ["Tea? On my shift?", "Who stopped my line?", "There. Back to work, all of you.",
			"What was that crash?!", "Who's been at my lever?", "The drive cog's gone! We've been robbed!"],
	})
	platt.position = points["desk"]
	add_child(platt)
	platt.dress(Color(0.95, 0.95, 0.95), false)
	rosa = BottlingWorker.new()
	rosa.line_worker = true
	rosa.setup("Rosa", "female-f", self, p_run, [
		{"at": "panel", "face": Vector3(-1, 0, 0), "clip": "interact-right", "time": 26.0, "room": "line", "say": "Filler's running hot again."},
		{"at": "packing", "face": Vector3(1, 0, 0), "clip": "holding-both", "time": 18.0},
		{"at": "filler", "face": Vector3(0, 0, -1), "clip": "interact-left", "time": 12.0},
		{"at": "capper", "face": Vector3(0, 0, -1), "clip": "look-around", "time": 8.0},
		{"at": "tea_rosa", "face": Vector3(1, 0, 0), "clip": "sit", "time": 25.0, "room": "break", "leave_dark": true, "say": "Kettle on, Eddie?"},
	], "bottling_rosa", {
		"mumble": "high", "answers_alarm": true, "accepts": ["worker"],
		"lines": {
			"curious": ["Eddie? Is that you?", "Hello?"],
			"seen": ["Who's there?"],
			"spotted": ["Hey! Stop!", "Mr Platt! Burglar!"],
			"others": ["What's happening?"],
			"lost": ["Where'd they go?"],
			"give_up": ["Just the machines.", "I need a cup of tea."],
			"catch": ["Got you! Off you go."],
			"alarm": ["That's the alarm!"],
			"bark": ["What was that?"],
			"wake": ["Oh! I must have nodded off."],
		},
		"extra_lines": ["Ooh, kettle's on!", "Line's stopped. I'll see to it.", "There she goes.",
			"What on earth was that?", "The drive cog's gone! We've been robbed!"],
	})
	rosa.position = points["panel"]
	add_child(rosa)
	rosa.dress()
	eddie = BottlingWorker.new()
	eddie.line_worker = true
	eddie.setup("Eddie", "male-e", self, p_run, [
		{"at": "loading", "face": Vector3(-1, 0, 0), "clip": "interact-right", "time": 28.0, "room": "dock", "say": "Empties on. Empties on."},
		{"at": "washer", "face": Vector3(0, 0, -1), "clip": "look-around", "time": 10.0},
		{"at": "dock_crates", "face": Vector3(1, 0, 0), "clip": "holding-both", "time": 14.0},
		{"at": "sofa", "face": Vector3(0, 0, -1), "clip": "sit", "time": 30.0, "room": "break", "leave_dark": true, "say": "Just resting my eyes."},
		{"at": "dock", "face": Vector3(1, 0, 0), "clip": "look-around", "time": 8.0},
	], "bottling_eddie", {
		"mumble": "low", "answers_alarm": true, "accepts": ["worker"],
		"lines": {
			"curious": ["Wassat?", "Rosa?"],
			"seen": ["Er... hello?"],
			"spotted": ["Oi! Who are you?", "Burglar! Rosa!"],
			"others": ["What's up?"],
			"lost": ["They were just here..."],
			"give_up": ["Probably a rat.", "Nothing. Nice."],
			"catch": ["Got you! Sorry. Out you go."],
			"alarm": ["Alarm! Alarm!"],
			"bark": ["What was that?"],
			"wake": ["Wha...? I wasn't asleep."],
		},
		"extra_lines": ["Tea! Lovely.", "Line's stopped! ...I'll do it then.", "And we're off.",
			"Was that the crane?!", "The drive cog's gone! We've been robbed!"],
	})
	eddie.position = points["loading"]
	add_child(eddie)
	eddie.dress()
	return [platt, rosa, eddie]
