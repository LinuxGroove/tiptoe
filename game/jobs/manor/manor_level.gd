class_name ManorLevel
extends JobLevel
## Hoard Manor: a big old house on the hill, two storeys and a cellar on a
## 2 m grid, in walled grounds with gates, a gravel drive, gardens, a
## greenhouse and a kitchen yard. X runs east, Z runs south towards the gates,
## and each storey is 2.5 m (the cellar's floor is at -2.5).
##
## Ground floor: the dining room (west), the grand hall with its staircase and
## the library (east) at the front; the kitchen, the butler's pantry, the
## servants' stair, the back hall (with the cellar door and the garden door),
## the secret stair behind the library's bookcase and the study at the back.
## Upstairs: the guest room, the gallery and Hoard's dressing room at the
## front; Pell's room, the servants' landing, the upper landing and Hoard's
## bedroom at the back. The cellar: the coal store, the wine cellar, and the
## vault behind two laser gates.
##
## Routes to the vault:
##  1. The three pieces: Hoard's diary in the study (in through the library),
##     Pell's note in the butler's pantry, and the safe behind the portrait in
##     Hoard's bedroom (his birthday, from the diary). 73-19-42 at the keypad.
##  2. Hoard's key: he hangs it on his bedside table when he goes to bed and
##     snores. Sneak into the dark bedroom and take it, or put him to sleep
##     early with a snooze dart and lift it off his chain.
##  3. The secret bookcase: in at the open library window past Duke (a treat
##     makes a friend), pull the red book and take the hidden stair straight
##     down to the vault, missing the cellar camera and Pell's locked door.
##  4. Lights out: the fuse box in the kitchen yard kills every light, the
##     cameras, the laser gates and the alarm. Pell and Hattie come out to fix
##     it, and Pell leaves the kitchen door open behind him.
##  5. The coal chute: pry the hatch in the kitchen yard and slide into the
##     coal store; the boiler's roar hides your steps through the wine cellar.
##  6. The guard's look: the spare uniform in the guardhouse gets you past the
##     cameras on the grounds and the guards; ring the bell and Pell lets the
##     night guard in. The guardhouse desk turns the cameras off.
##  7. The butler's look: Pell's spare tailcoat in his room (up the servants'
##     stair). Hoard, the guards and the cellar camera think nothing of a
##     butler, but Pell knows there's only one of him.
##  8. Over the portico: climb the urn onto the portico roof and pry the
##     gallery window, straight into the upstairs.
## In the cellar the first laser gate blinks (dash through), the second has
## a blinking low beam under steady high ones (crawl under when it's off), or
## switch them off in the study, cut the power, or turn the alarm off in the
## pantry so nothing they see matters.

const ManorPersonScript := preload("res://game/jobs/manor/manor_person.gd")

const UP := JobLevel.STOREY
const ROOF := JobLevel.STOREY * 2.0
const CELLAR := -JobLevel.STOREY

const MARBLE := Color(0.84, 0.82, 0.77)
const CARPET_RED := Color(0.5, 0.2, 0.22)
const CARPET_GREEN := Color(0.24, 0.36, 0.3)
const CARPET_BLUE := Color(0.3, 0.34, 0.5)
const WOOD := Color(0.56, 0.41, 0.28)
const WOOD_DARK := Color(0.38, 0.25, 0.16)
const TILE := Color(0.78, 0.79, 0.76)
const STONE := Color(0.56, 0.54, 0.5)
const STONE_DARK := Color(0.4, 0.39, 0.37)
const CONCRETE := Color(0.44, 0.44, 0.43)
const GRAVEL := Color(0.6, 0.56, 0.5)
const GRASS := Color(0.22, 0.38, 0.19)
const HEDGE := Color(0.14, 0.28, 0.14)
const ROAD := Color(0.2, 0.2, 0.22)
const SLATE := Color(0.24, 0.26, 0.31)
const COAL := Color(0.07, 0.07, 0.08)
const BRASS := Color(0.78, 0.62, 0.25)
const STEEL := Color(0.5, 0.52, 0.56)

const PIRATE := "res://assets/kenney/pirate-kit/"
const CASTLE := "res://assets/kenney/castle-kit/"
const GRAVEYARD := "res://assets/kenney/graveyard-kit/"
const ARENA := "res://assets/kenney/mini-arena/"
const PLATFORMER := "res://assets/kenney/platformer-kit/"
const SOLDIER := "res://assets/kenney/mini-arena/character-soldier.glb"

const VAULT_CODE := "731942"
const SAFE_CODE := "0612"

## Lights on when the night starts.
const LIGHTS_ON := ["hall", "dining", "kitchen", "pantry", "back_hall", "servants", "gallery",
	"landing", "anteroom", "vault", "wine", "porch", "drive", "gate", "terrace", "yard", "guardhouse"]
## Everything on the fuse box: the house, the cellar and the grounds' lamps.
const MANOR_CIRCUIT := ["hall", "dining", "library", "study", "kitchen", "pantry", "servants",
	"back_hall", "gallery", "landing", "servants_landing", "pell_room", "guest", "bedroom",
	"dressing", "coal", "wine", "passage", "anteroom", "vault", "porch", "drive", "gate",
	"terrace", "yard", "guardhouse"]
## The rooms of the house itself, for "leave the whole manor dark".
const HOUSE_ROOMS := ["hall", "dining", "library", "study", "kitchen", "pantry", "servants",
	"back_hall", "gallery", "landing", "servants_landing", "pell_room", "guest", "bedroom",
	"dressing", "coal", "wine", "passage", "anteroom", "vault", "porch"]

const OTTOLINE_NOTE := """The last job, love.
Everything Hoard ever took from Kettleford is in the vault under his manor.
There's always another way in: the gates, the garden wall round the west side, the greenhouse, even the coal chute in the kitchen yard.
Bring it all home.
- O."""

const GUARD_ROTA := """NIGHT ROTA
Ogden: the gate, the drive, the front lawn. Mind Duke, he bites when he's woken.
Hattie: the kitchen yard, the gardens, the greenhouse.

NB The fuse box in the kitchen yard trips if you look at it. When it goes, EVERYTHING goes: the lights, the cameras, the vault lasers and the alarm. Hattie, it's on your round. Pell will help, whether you like it or not."""

const SECURITY_INVOICE := """CASTELLAN SECURITY LTD
For Mr A. Hoard, Hoard Manor

3 cameras on the grounds, 1 on the cellar stair.
2 laser gates in front of the vault. Switch: the panel in your study.
1 alarm. Switch: the butler's pantry.
1 vault door, six-digit code. We recommend you split the code and keep the pieces in different places.

TOTAL: more than you'd like."""

const HOARD_DIARY := """Tuesday. Took the school's rocket. Lovely.

Wednesday. Split the vault code in three, as the security man said.
The first part is 73 (that's in here, so it's safe).
Pell has the middle part, God help us.
The last part is in the safe behind my portrait in the bedroom. The safe is my birthday: 0612. Nobody ever remembers my birthday.

Thursday. Pulled the red book in the library and went down to the vault the secret way. Ha! Nobody knows."""

const PANTRY_NOTE := """Pell -
For emergencies ONLY: the middle part of the vault code is 19.
Eat this note.
- A.H.

(I have not eaten it. I am a butler, not a goat. - P.)"""

const SAFE_NOTE := """Vault code, last part: 42.
- A.H."""

const PELL_DUTIES := """PELL - EVENING
Serve dinner. Wash up. Polish the silver. Check the alarm is on.
Lock the back door, the front door and the cellar.
Sir hangs his vault key on the bedside table when he turns in, and snores like a walrus. DO NOT DISTURB.
Duke's biscuits are in the guardhouse."""

const HOARD_LETTER := """Dear Council,
Thank you for your kind letter asking for the town's things back. No.
The trophy, the cog, the ledger, the charter, the statue, the rocket and the rest are perfectly happy in my vault, which is very safe and very much mine.
Yours, richly,
Augustus Hoard"""

var hoard: ManorPerson
var pell: ManorPerson
var dog: Dog
var bookcase: SecretBookcase
var vault_keypad: Keypad
var safe_keypad: Keypad
var alarm_panel: UsableBody
var gate_a: LaserGate
var gate_b_high: LaserGate
var gate_b_low: LaserGate
var _run: JobRun
var _key_pickup: UsableBody
var _key_alarm_done := false
var _snore: AudioStreamPlayer3D
var _painting: UsableBody
var _safe_door: Node3D
var _card_left := false
var _butler_rebuffed := false
var _secret_block: StaticBody3D
var _chute_open := false
var _via_chute_t := -10.0
## Until when the night guard Pell let in is welcome downstairs (run time).
var let_in_until := -1.0


func build() -> void:
	circuit = MANOR_CIRCUIT
	alarm_time = 25.0
	_grounds()
	_boundary()
	_drive_and_gates()
	_guardhouse()
	_gardens()
	_greenhouse()
	_kitchen_yard()
	_ground_floor()
	_upstairs()
	_cellar()
	_stairs_all()
	_portico()
	_roof()
	_furnish_ground()
	_furnish_upstairs()
	_furnish_cellar()
	_lamps()
	_switches()
	_security()
	_things()
	_marks()
	house_boxes.append(AABB(Vector3(-13, CELLAR - 0.5, -8), Vector3(26, ROOF - CELLAR + 0.5, 16)))
	indoor_boxes.append(AABB(Vector3(3, -0.5, 24), Vector3(6, UP + 0.5, 6)))
	indoor_boxes.append(AABB(Vector3(14, -0.5, -25), Vector3(10, 3.0, 8)))
	areas["cellar"] = AABB(Vector3(-13, CELLAR - 0.3, -8), Vector3(26, 2.2, 8))
	areas["secret_stair"] = AABB(Vector3(5, CELLAR + 0.6, -4.8), Vector3(2, 2.6, 3.6))
	areas["bedroom"] = AABB(Vector3(5, UP - 0.2, -8), Vector3(8, 2.4, 8))
	areas["study"] = AABB(Vector3(7, -0.2, -8), Vector3(6, 2.4, 8))
	areas["vault"] = AABB(Vector3(7, CELLAR - 0.2, -4), Vector3(6, 2.4, 4))
	areas["kitchen_yard"] = AABB(Vector3(-21, -0.5, -8), Vector3(8, 3, 13))
	for room in lights:
		set_lights(room, room in LIGHTS_ON)


# --- The grounds -------------------------------------------------------------

func _grounds() -> void:
	var g := Kit.flat(GRASS)
	# Grass all round the house (its own floors fill its footprint).
	Kit.block(self, Vector3(0, -0.06, 19), Vector3(60, 0.1, 22), "grass", g)
	Kit.block(self, Vector3(0, -0.06, -17), Vector3(60, 0.1, 18), "grass", g)
	Kit.block(self, Vector3(-21.5, -0.06, 0), Vector3(17, 0.1, 16), "grass", g)
	Kit.block(self, Vector3(21.5, -0.06, 0), Vector3(17, 0.1, 16), "grass", g)
	# Outside the walls: the lane past the gates and the path round the west.
	Kit.block(self, Vector3(0, -0.06, 33.75), Vector3(73, 0.1, 7.5), "concrete", Kit.flat(ROAD))
	Kit.block(self, Vector3(-33.25, -0.06, -0.5), Vector3(6.5, 0.1, 61), "grass", Kit.flat(Color(0.2, 0.33, 0.18)))
	var hedge := Kit.flat(HEDGE)
	Kit.block(self, Vector3(0, 1.5, 38), Vector3(74, 3.0, 1), "", hedge)
	Kit.block(self, Vector3(-37, 1.5, 6), Vector3(1, 3.0, 64), "", hedge)
	Kit.block(self, Vector3(36.5, 1.5, 34), Vector3(1, 3.0, 8), "", hedge)
	Kit.block(self, Vector3(-33.5, 1.5, -26.5), Vector3(6, 3.0, 1), "", hedge)
	# Trees: only the trunks block.
	for t in [Vector3(-20, 0, 22), Vector3(-25, 0, 12), Vector3(22, 0, 22), Vector3(26, 0, 14),
			Vector3(-26, 0, -22), Vector3(27, 0, -10), Vector3(-12, 0, 26), Vector3(14, 0, 18),
			Vector3(-24, 0, 33.5), Vector3(20, 0, 34.5)]:
		var tree := Kit.boxed(self, Kit.SUBURBAN + "tree-large.glb", t, randf() * 360.0, 6.5)
		var cs: CollisionShape3D = tree.get_child(1)
		cs.shape.size = Vector3(0.45, 4.0, 0.45)
		cs.position = Vector3(0, 2.0, 0)


## The high wall round the grounds, the iron railings along the lane and the
## low garden wall on the west side (climbable from the path outside).
func _boundary() -> void:
	var stone := Kit.flat(STONE_DARK)
	# North and east: too high to climb.
	Kit.block(self, Vector3(0, 1.6, -26.2), Vector3(60.4, 3.2, 0.4), "", stone)
	Kit.block(self, Vector3(30.2, 1.6, 2), Vector3(0.4, 3.2, 56.4), "", stone)
	# West: high, except the low garden wall between z -20 and -8.
	Kit.block(self, Vector3(-30.2, 1.6, -23), Vector3(0.4, 3.2, 6), "", stone)
	Kit.block(self, Vector3(-30.2, 1.6, 11), Vector3(0.4, 3.2, 38), "", stone)
	for z in range(-19, -8, 2):
		Kit.model(self, GRAVEYARD + "stone-wall.glb", Vector3(-30.2, 0, z), 90, 2.0)
	Kit.block(self, Vector3(-30.2, 0.73, -14), Vector3(0.4, 1.46, 12), "", null)
	# The railings along the lane, either side of the gates and the guardhouse.
	_railings(-30, -5.4)
	_railings(9, 30)


func _railings(x0: float, x1: float) -> void:
	var n := int(round((x1 - x0) / 2.0))
	var step := (x1 - x0) / n
	for i in n:
		Kit.model(self, GRAVEYARD + "iron-fence.glb", Vector3(x0 + step * (i + 0.5), 0.3, 30.15), 0, 2.0)
	Kit.block(self, Vector3((x0 + x1) * 0.5, 0.15, 30), Vector3(x1 - x0, 0.3, 0.5), "", Kit.flat(STONE))
	# Spiked tops: too high to climb.
	Kit.block(self, Vector3((x0 + x1) * 0.5, 1.4, 30), Vector3(x1 - x0, 2.8, 0.4), "", null)


func _drive_and_gates() -> void:
	var gravel := Kit.flat(GRAVEL)
	# The drive from the gates, and the forecourt round the fountain.
	Kit.block(self, Vector3(0, -0.035, 25.75), Vector3(5, 0.07, 8.5), "concrete", gravel)
	Kit.block(self, Vector3(0, -0.035, 15), Vector3(18, 0.07, 14), "concrete", gravel)
	Kit.block(self, Vector3(-4, -0.035, 30.0), Vector3(2.4, 0.07, 1.2), "concrete", gravel)
	# The fountain.
	var basin := StaticBody3D.new()
	basin.collision_layer = Kit.LAYER_WORLD
	basin.position = Vector3(0, 0.3, 15)
	var cs := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 2.2
	cyl.height = 0.6
	cs.shape = cyl
	basin.add_child(cs)
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 2.2
	cm.bottom_radius = 2.3
	cm.height = 0.6
	cm.material = Kit.flat(STONE)
	mi.mesh = cm
	basin.add_child(mi)
	add_child(basin)
	basin.add_to_group(Kit.NAV_GROUP)
	var water := MeshInstance3D.new()
	var wm := CylinderMesh.new()
	wm.top_radius = 2.0
	wm.bottom_radius = 2.0
	wm.height = 0.05
	wm.material = Kit.flat(Color(0.15, 0.25, 0.35), 0.1)
	water.mesh = wm
	water.position = Vector3(0, 0.58, 15)
	add_child(water)
	Kit.model(self, GRAVEYARD + "pillar-square.glb", Vector3(0, 0.6, 15), 0, 1.6)
	Kit.model(self, GRAVEYARD + "urn-round.glb", Vector3(0, 2.4, 15), 0, 2.5)
	# Gate pillars, with lanterns on top.
	for x in [-5.3, -3.0, 3.0]:
		Kit.boxed(self, GRAVEYARD + "pillar-square.glb", Vector3(x, 0, 30), 0, 2.4)
		Kit.model(self, GRAVEYARD + "lantern-candle.glb", Vector3(x, 2.76, 30), 0, 1.6)
	# The main gates, shut and chained (the guards use the side gate).
	for side in [-1.0, 1.0]:
		var leaf := Kit.model(self, GRAVEYARD + "iron-fence-border-gate.glb", Vector3(side * 1.4, 0, 30.2), 0, 1.0)
		leaf.scale = Vector3(2.6, 3.2, 2.0)
	Kit.block(self, Vector3(0, 1.4, 30), Vector3(5.6, 2.8, 0.3), "", null)
	Kit.block(self, Vector3(0, 1.2, 30.0), Vector3(0.3, 0.3, 0.35), "", Kit.flat(Color(0.3, 0.3, 0.32)), false)
	# The side gate: locked, but the lock is old.
	_gate("side_gate", Vector3(-4.15, 0, 30), Vector2(-4, 28), true, 5.0)
	# The lamps along the drive.
	for p in [Vector3(-3.4, 0, 20), Vector3(3.4, 0, 20), Vector3(-3.4, 0, 26.5), Vector3(3.4, 0, 26.5)]:
		Kit.boxed(self, GRAVEYARD + "lightpost-single.glb", p, 90 if p.x < 0 else -90, 2.6)


## An iron gate on hinges, opening north into the grounds.
func _gate(id: String, c: Vector3, into: Vector2, locked: bool, pick: float) -> HouseDoor:
	var d := HouseDoor.make(id, GRAVEYARD + "iron-fence-border-gate.glb")
	var m: Node3D = d.get_node("Model")
	m.rotation.y = -PI * 0.5
	m.scale = Vector3(0.9, 2.7, 1.0)
	m.position = Vector3(-0.33, 0, 0.45)
	var u := Vector3(1, 0, 0)
	d.position = c - u * 0.45
	d.rotation.y = PI * 0.5
	var n := Vector3(u.z, 0, -u.x)
	d.swing = 1 if n.dot(Vector3(into.x, 0, into.y) - c) >= 0.0 else -1
	d.locked = locked
	d.pickable = pick > 0.0
	d.pick_time = pick
	add_child(d)
	doors[id] = d
	return d


## The guardhouse by the gates: a door to the lane and one to the drive, the
## camera desk, the spare uniform and Duke's biscuits.
func _guardhouse() -> void:
	floor_rect(0, 3, 24, 9, 30, "wood", WOOD, false)
	floor_rect(UP, 3, 24, 9, 30, "", SLATE)
	line(0, Vector2(3, 24), Vector2(1, 0), "WDW", [{"id": "guardhouse_door", "into": Vector2(6, 26)}])
	line(0, Vector2(3, 30), Vector2(1, 0), "WDW", [{"id": "lane_door", "into": Vector2(6, 28), "locked": true, "pick": 5.0}])
	line(0, Vector2(3, 24), Vector2(0, 1), "wwW")
	line(0, Vector2(9, 24), Vector2(0, 1), "WWW")
	Kit.furniture(self, "desk", Vector3(7.6, 0, 24.45), 0)
	for x in [7.2, 7.9]:
		Kit.boxed(self, Kit.FURNITURE + "computerScreen.glb", Vector3(x, 0.76, 24.3), 0, Kit.FURNITURE_SCALE, "", false)
	Kit.furniture(self, "chairDesk", Vector3(7.6, 0, 25.3), 180)
	Kit.furniture(self, "coatRackStanding", Vector3(3.6, 0, 29.4), 0)
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(8.6, 0, 28.5), -90)


func _gardens() -> void:
	var stone := Kit.flat(STONE)
	var hedge := Kit.flat(HEDGE)
	# The terrace behind the house, by the garden door.
	Kit.block(self, Vector3(2, -0.03, -10.5), Vector3(16, 0.06, 5), "concrete", stone)
	Kit.block(self, Vector3(2, -0.03, -16.5), Vector3(2, 0.06, 7), "concrete", Kit.flat(GRAVEL))
	for x in [-5.5, 9.5]:
		Kit.boxed(self, GRAVEYARD + "pillar-square.glb", Vector3(x, 0, -12.6), 0, 1.0)
		Kit.model(self, GRAVEYARD + "urn-round.glb", Vector3(x, 1.15, -12.6), 0, 2.0)
	Kit.furniture(self, "bench", Vector3(-2.5, 0, -11.8), 0)
	# The formal garden: low hedges (crouch behind them) round lawns.
	for h in [[Vector3(-6, 0.62, -14), Vector3(10, 1.25, 0.8)], [Vector3(10, 0.62, -14), Vector3(10, 1.25, 0.8)],
			[Vector3(-6, 0.62, -21), Vector3(10, 1.25, 0.8)], [Vector3(10, 0.62, -21), Vector3(10, 1.25, 0.8)],
			[Vector3(-10.6, 0.62, -17.5), Vector3(0.8, 1.25, 7.8)], [Vector3(14.6, 0.62, -12), Vector3(0.8, 1.25, 4)]]:
		Kit.block(self, h[0], h[1], "", hedge)
	for t in [Vector3(-3, 0, -17.5), Vector3(7, 0, -17.5)]:
		Kit.boxed(self, Kit.SUBURBAN + "tree-small.glb", t, 0, 4.0)
	# The west garden behind the low wall: tall hedges make its paths.
	Kit.block(self, Vector3(-22, 1.3, -24.5), Vector3(0.8, 2.6, 3), "", hedge)
	Kit.block(self, Vector3(-18, 1.3, -17), Vector3(8, 2.6, 0.8), "", hedge)
	Kit.block(self, Vector3(-25, 1.3, -11), Vector3(6, 2.6, 0.8), "", hedge)
	for bed in [Vector3(-26, 0.2, -16.5), Vector3(-26, 0.2, -21), Vector3(-17, 0.2, -21.5)]:
		Kit.block(self, bed, Vector3(3, 0.4, 2.2), "grass", Kit.flat(Color(0.3, 0.22, 0.14)))
	Kit.block(self, Vector3(-17, 1.1, -24.2), Vector3(3, 2.2, 2.4), "wood", Kit.flat(WOOD_DARK))
	# Low hedges along the front lawn, either side of the drive.
	for h in [[Vector3(-8.5, 0.62, 23), Vector3(9, 1.25, 0.8)], [Vector3(8.5, 0.62, 21), Vector3(5, 1.25, 0.8)],
			[Vector3(-14, 0.62, 12.5), Vector3(0.8, 1.25, 7)], [Vector3(16, 0.62, 12), Vector3(0.8, 1.25, 6)]]:
		Kit.block(self, h[0], h[1], "", hedge)
	# Duke's kennel on the east lawn.
	Kit.block(self, Vector3(21.4, 0.5, 6), Vector3(1.4, 1.0, 1.2), "wood", Kit.flat(Color(0.55, 0.33, 0.2)))
	var roof := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(1.6, 0.6, 1.4)
	pm.material = Kit.flat(Color(0.5, 0.15, 0.12))
	roof.mesh = pm
	roof.position = Vector3(21.4, 1.3, 6)
	roof.rotation.y = PI * 0.5
	add_child(roof)
	var bowl := MeshInstance3D.new()
	var bc := CylinderMesh.new()
	bc.top_radius = 0.18
	bc.bottom_radius = 0.15
	bc.height = 0.1
	bc.material = Kit.flat(Color(0.7, 0.2, 0.2))
	bowl.mesh = bc
	bowl.position = Vector3(20.4, 0.05, 7.1)
	add_child(bowl)


## The greenhouse in the north-east corner: glass on a frame, tables of
## Hoard's prize marrows, and a gardener's cupboard.
func _greenhouse() -> void:
	floor_rect(0, 14, -25, 24, -17, "tile", Color(0.5, 0.48, 0.44), false)
	var frame := Kit.flat(Color(0.9, 0.9, 0.86))
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.7, 0.85, 0.9, 0.22)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# Panes: [centre, size]. The door is a gap in the south side, x 18 to 20.
	var panes := [
		[Vector3(19, 1.3, -25), Vector3(10, 2.6, 0.05)],
		[Vector3(14, 1.3, -21), Vector3(0.05, 2.6, 8)],
		[Vector3(24, 1.3, -21), Vector3(0.05, 2.6, 8)],
		[Vector3(16, 1.3, -17), Vector3(4, 2.6, 0.05)],
		[Vector3(22, 1.3, -17), Vector3(4, 2.6, 0.05)],
		[Vector3(19, 2.62, -21), Vector3(10, 0.05, 8)],
	]
	for p in panes:
		var body := StaticBody3D.new()
		body.collision_layer = Kit.LAYER_GLASS
		body.collision_mask = 0
		body.position = p[0]
		var cs := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = p[1]
		cs.shape = box
		body.add_child(cs)
		var m := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = p[1]
		bm.material = glass
		m.mesh = bm
		body.add_child(m)
		add_child(body)
		body.add_to_group(Kit.NAV_GROUP)
	for x in [14, 16, 18, 20, 22, 24]:
		for z in [-25, -17]:
			Kit.block(self, Vector3(x, 1.3, z), Vector3(0.1, 2.6, 0.1), "", frame, false)
	for z in [-23, -21, -19]:
		for x in [14, 24]:
			Kit.block(self, Vector3(x, 1.3, z), Vector3(0.1, 2.6, 0.1), "", frame, false)
	# Potting tables down both sides.
	for t in [Vector3(15.0, 0.4, -21), Vector3(23.0, 0.4, -21)]:
		Kit.block(self, t, Vector3(1.4, 0.8, 6), "wood", Kit.flat(WOOD))
		for dz in [-2.2, -0.8, 0.6, 2.0]:
			Kit.model(self, Kit.FURNITURE + "plantSmall%d.glb" % (1 + int(absf(dz)) % 3), t + Vector3(-0.2, 0.4, dz), randf() * 360, 2.0)


func _kitchen_yard() -> void:
	var wall := Kit.flat(Color(0.6, 0.55, 0.48))
	Kit.block(self, Vector3(-17, -0.03, -1.5), Vector3(8, 0.06, 13), "concrete", Kit.flat(CONCRETE))
	Kit.block(self, Vector3(-21.1, 1.1, -1.5), Vector3(0.3, 2.2, 13.4), "", wall)
	Kit.block(self, Vector3(-17, 1.1, 5.1), Vector3(8.4, 2.2, 0.3), "", wall)
	Kit.block(self, Vector3(-14.5, 1.1, -8.1), Vector3(3, 2.2, 0.3), "", wall)
	# Bins, a coal heap by the hatch, and a washing line.
	for b in [Vector3(-20.4, 0.55, 3.8), Vector3(-19.5, 0.55, 3.8)]:
		Kit.block(self, b, Vector3(0.7, 1.1, 0.8), "concrete", Kit.flat(Color(0.2, 0.32, 0.24)))
	for p in [Vector3(-20.6, 1.0, -6), Vector3(-20.6, 1.0, 0)]:
		Kit.block(self, p, Vector3(0.08, 2.0, 0.08), "", Kit.flat(Color(0.3, 0.3, 0.3)), false)
	Kit.block(self, Vector3(-20.6, 1.95, -3), Vector3(0.02, 0.02, 6), "", Kit.flat(Color(0.9, 0.9, 0.9)), false)
	Kit.block(self, Vector3(-20.6, 1.6, -4.2), Vector3(0.05, 0.7, 0.9), "", Kit.flat(Color(0.85, 0.85, 0.95)), false)
	Kit.block(self, Vector3(-20.6, 1.65, -2.4), Vector3(0.05, 0.6, 0.7), "", Kit.flat(Color(0.7, 0.3, 0.3)), false)


# --- The house -----------------------------------------------------------------

func _ground_floor() -> void:
	# Front rooms (no cellar under them) and back rooms (over the cellar).
	floor_rect(0, -13, 0, -5, 8, "wood", WOOD, false)
	floor_rect(0, -5, 0, 5, 8, "tile", MARBLE, false)
	floor_rect(0, 5, 0, 13, 8, "carpet", CARPET_GREEN, false)
	floor_rect(0, -13, -8, -7, 0, "tile", TILE)
	floor_rect(0, -7, -8, -3, -4, "tile", TILE)
	floor_rect(0, -7, -4, -3, 0, "wood", WOOD_DARK)
	floor_rect(0, -3, -2.4, -1, -2, "wood", WOOD_DARK)
	floor_rect(0, -3, -2, 5, 0, "tile", MARBLE)
	floor_rect(0, -1, -8, 5, -2, "tile", MARBLE)
	floor_rect(0, 5, -0.8, 7, 0, "wood", WOOD_DARK)
	floor_rect(0, 7, -8, 13, 0, "carpet", CARPET_RED)
	# Outside walls.
	line(0, Vector2(-13, 8), Vector2(1, 0), "wWwWwWDWwWwWw", [
		{"id": "front_door", "into": Vector2(0, 6), "locked": true, "pick": 8.0, "outside": true}])
	line(0, Vector2(-13, -8), Vector2(1, 0), "wWwWwWwDwWwWp", [
		{"id": "garden_door", "into": Vector2(2, -6), "locked": true, "pick": 6.0, "outside": true}, "study_window"])
	line(0, Vector2(-13, -8), Vector2(0, 1), "wDwWWwwW", [
		{"id": "kitchen_door", "into": Vector2(-11, -5), "pick": 4.0, "outside": true}])
	line(0, Vector2(13, -8), Vector2(0, 1), "WwwWWowW", ["library_window"])
	# Inside walls.
	line(0, Vector2(-13, 0), Vector2(1, 0), "WDWWDddWWdWDW", [
		{"id": "dining_kitchen", "into": Vector2(-10, 2)},
		{"id": "baize_door", "into": Vector2(-4, -2)},
		{"id": "study_door", "into": Vector2(10, -2), "locked": true, "pick": 6.0}])
	line(0, Vector2(-5, 0), Vector2(0, 1), "WDWW", [{"id": "dining_door", "into": Vector2(-7, 3)}])
	line(0, Vector2(5, 0), Vector2(0, 1), "WWWD", [{"id": "library_door", "into": Vector2(7, 7)}])
	line(0, Vector2(-7, -8), Vector2(0, 1), "WDWd", [{"id": "pantry_door", "into": Vector2(-5, -6)}])
	line(0, Vector2(-7, -4), Vector2(1, 0), "WW")
	line(0, Vector2(-3, -8), Vector2(0, 1), "WWWd")
	line(0, Vector2(-1, -8), Vector2(0, 1), "WWW")
	line(0, Vector2(-3, -2), Vector2(1, 0), "D", [{"id": "cellar_door", "into": Vector2(-2, -1), "pick": 5.0}])
	line(0, Vector2(5, -8), Vector2(0, 1), "WWWW")
	line(0, Vector2(7, -8), Vector2(0, 1), "WWWW")


func _upstairs() -> void:
	floor_rect(UP, -13, -8, -7, 0, "wood", WOOD)
	floor_rect(UP, -7, -8, -3, -4, "wood", WOOD)
	floor_rect(UP, -7, -2.6, -3, 0, "wood", WOOD)
	floor_rect(UP, -7, -4, -6.6, -2.6, "wood", WOOD)
	floor_rect(UP, -3, -8, 5, 0, "carpet", CARPET_RED)
	floor_rect(UP, 5, -8, 13, 0, "carpet", CARPET_BLUE)
	floor_rect(UP, -13, 0, -5, 8, "carpet", CARPET_GREEN)
	floor_rect(UP, -5, 0, 2, 8, "wood", WOOD)
	floor_rect(UP, 2, 0, 5, 2.1, "wood", WOOD)
	floor_rect(UP, 2, 5.6, 5, 8, "wood", WOOD)
	floor_rect(UP, 5, 0, 13, 8, "tile", TILE)
	line(UP, Vector2(-13, 8), Vector2(1, 0), "wWwWwWpWwWwWw", ["gallery_window"])
	line(UP, Vector2(-13, -8), Vector2(1, 0), "wWwWwwWwWWwWw")
	line(UP, Vector2(-13, -8), Vector2(0, 1), "WwwWWwwW")
	line(UP, Vector2(13, -8), Vector2(0, 1), "WwwWWwwW")
	line(UP, Vector2(-13, 0), Vector2(1, 0), "WWWWddWdWWWDW", [{"id": "dressing_door", "into": Vector2(10, 2)}])
	line(UP, Vector2(-7, -8), Vector2(0, 1), "WWWD", [{"id": "pell_door", "into": Vector2(-9, -1)}])
	line(UP, Vector2(-3, -8), Vector2(0, 1), "WWWd")
	line(UP, Vector2(5, -8), Vector2(0, 1), "WWWD", [{"id": "bedroom_door", "into": Vector2(7, -1), "locked": true, "pick": 5.0}])
	line(UP, Vector2(-5, 0), Vector2(0, 1), "DWWW", [{"id": "guest_door", "into": Vector2(-7, 1)}])
	line(UP, Vector2(5, 0), Vector2(0, 1), "WWWD", [{"id": "gallery_dressing", "into": Vector2(7, 7)}])
	# Railings round the stairwells.
	_rail(Vector3(2, UP, 2.1), Vector3(2, UP, 5.6))
	_rail(Vector3(2, UP, 5.6), Vector3(5, UP, 5.6))
	_rail(Vector3(-6.6, UP, -2.6), Vector3(-3, UP, -2.6))
	_rail(Vector3(-6.6, UP, -4), Vector3(-3, UP, -4))


func _cellar() -> void:
	floor_rect(CELLAR, -13, -8, -7, 0, "concrete", Color(0.3, 0.29, 0.28), false)
	floor_rect(CELLAR, -7, -8, 7, 0, "concrete", CONCRETE, false)
	floor_rect(CELLAR, 7, -8, 13, -4, "tile", Color(0.62, 0.62, 0.64), false)
	floor_rect(CELLAR, 7, -4, 13, 0, "tile", Color(0.7, 0.66, 0.55), false)
	line(CELLAR, Vector2(-13, -8), Vector2(1, 0), "WWWWWWWWWWWWW")
	line(CELLAR, Vector2(-13, 0), Vector2(1, 0), "WWWWWWWWWWWWW")
	line(CELLAR, Vector2(-13, -8), Vector2(0, 1), "WWWW")
	line(CELLAR, Vector2(13, -8), Vector2(0, 1), "WWWW")
	line(CELLAR, Vector2(-7, -8), Vector2(0, 1), "WWDW", [{"id": "coal_door", "into": Vector2(-9, -3)}])
	line(CELLAR, Vector2(5, -8), Vector2(0, 1), "dWWW")
	line(CELLAR, Vector2(7, -8), Vector2(0, 1), "dWWW")
	line(CELLAR, Vector2(7, -4), Vector2(1, 0), "WDW", [
		{"id": "vault_door", "into": Vector2(10, -2), "locked": true, "key": "hoard_key",
			"people_open": false, "key_verb": "Use Hoard's key", "model": "door-rotate-square-d.glb"}])
	# The vault door's steel face and wheel.
	var vd: HouseDoor = doors["vault_door"]
	var plate := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.12, 2.1, 0.9)
	bm.material = Kit.flat(STEEL, 0.4)
	plate.mesh = bm
	plate.position = Vector3(0, 1.05, 0.45)
	vd.add_child(plate)
	for side in [-1.0, 1.0]:
		var wheel := MeshInstance3D.new()
		var tm := TorusMesh.new()
		tm.inner_radius = 0.16
		tm.outer_radius = 0.22
		tm.material = Kit.flat(BRASS, 0.3)
		wheel.mesh = tm
		wheel.rotation.z = PI * 0.5
		wheel.position = Vector3(side * 0.09, 1.1, 0.45)
		vd.add_child(wheel)
	vd.opened.connect(_on_vault_opened)


## Every flight of stairs: the grand stair in the hall, the servants' stair,
## the cellar stair from the back hall and the secret stair from the library.
func _stairs_all() -> void:
	_stairs(Vector3(3.5, 0, 6.6), Vector3(3.5, UP, 2.1), 2.8, "carpet", CARPET_RED)
	_stairs(Vector3(-3.2, 0, -3.3), Vector3(-6.6, UP, -3.3), 1.4, "wood", WOOD_DARK)
	_stairs(Vector3(-2, CELLAR, -6.9), Vector3(-2, 0, -2.4), 1.8, "wood", WOOD_DARK)
	_stairs(Vector3(6, CELLAR, -5.3), Vector3(6, 0, -0.8), 1.8, "concrete", STONE_DARK)
	# Banisters on the grand stair.
	for x in [2.15, 4.85]:
		var post := Kit.block(self, Vector3(x, 0.55, 6.5), Vector3(0.14, 1.1, 0.14), "", Kit.flat(WOOD_DARK), false)
		post.collision_layer = 0
	var rail := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.08, 0.08, 5.2)
	bm.material = Kit.flat(WOOD_DARK)
	rail.mesh = bm
	rail.position = Vector3(2.15, UP * 0.5 + 0.95, 4.35)
	rail.rotation.x = atan2(UP, 4.5)
	add_child(rail)


## A straight flight of stairs: `bottom` and `top` are the middle of its
## lowest and highest edges. Steps to look at, over a ramp to walk on.
func _stairs(bottom: Vector3, top: Vector3, width: float, surface: String, color: Color) -> void:
	var span := top - bottom
	var rise := span.y
	var length := Vector2(span.x, span.z).length()
	var body := StaticBody3D.new()
	body.collision_layer = Kit.LAYER_WORLD
	body.collision_mask = 0
	body.position = bottom
	body.rotation.y = atan2(span.x, span.z)
	add_child(body)
	var steps := int(round(rise / 0.2))
	var d := length / steps
	var mat := Kit.flat(color)
	for i in steps:
		var h := rise * (i + 0.6) / steps
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(width, h, d)
		bm.material = mat
		mi.mesh = bm
		mi.position = Vector3(0, h * 0.5, d * (i + 0.5))
		body.add_child(mi)
	var cs := CollisionShape3D.new()
	var wedge := ConvexPolygonShape3D.new()
	var pts := PackedVector3Array()
	for x in [-width * 0.5, width * 0.5]:
		pts.append_array([Vector3(x, 0, -0.05), Vector3(x, 0.08, -0.05), Vector3(x, rise, length), Vector3(x, 0, length)])
	wedge.points = pts
	cs.shape = wedge
	body.add_child(cs)
	Kit.add_surface(body, surface)
	body.add_to_group(Kit.NAV_GROUP)


## A banister along a stairwell's edge (axis-aligned), on the floor at `a`.
func _rail(a: Vector3, b: Vector3) -> void:
	var size := Vector3(maxf(absf(b.x - a.x), 0.08), 1.0, maxf(absf(b.z - a.z), 0.08))
	Kit.block(self, (a + b) * 0.5 + Vector3(0, 0.5, 0), size, "", Kit.flat(WOOD_DARK))


## The portico over the front door: columns and a flat roof you can climb
## onto from the urn beside it, up to the gallery window.
func _portico() -> void:
	for x in [-2.3, 2.3]:
		var col := Kit.boxed(self, Kit.BUILDING + "column.glb", Vector3(x, 0, 10.2), 0, 1.0)
		col.scale = Vector3(1.0, 2.15 / 2.4, 1.0)
	Kit.block(self, Vector3(0, 2.4, 9.4), Vector3(5.8, 0.5, 2.8), "concrete", Kit.flat(STONE))
	# The urn on its plinth: a leg up to the portico.
	Kit.block(self, Vector3(3.7, 0.75, 10.3), Vector3(0.8, 1.5, 0.8), "concrete", Kit.flat(STONE))
	Kit.model(self, GRAVEYARD + "urn-round.glb", Vector3(3.85, 1.5, 10.45), 0, 1.6)
	# The front steps.
	Kit.block(self, Vector3(0, -0.02, 9.4), Vector3(4.4, 0.04, 2.8), "concrete", Kit.flat(STONE))


func _roof() -> void:
	floor_rect(ROOF, -13, -8, 13, 8, "", SLATE)
	var roof := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(16.8, 3.4, 26.8)
	pm.material = Kit.flat(SLATE)
	roof.mesh = pm
	roof.position = Vector3(0, ROOF + 1.7, 0)
	roof.rotation.y = PI * 0.5
	add_child(roof)
	for c in [Vector3(-9, ROOF + 2.6, -2), Vector3(9, ROOF + 2.6, 2)]:
		Kit.block(self, c, Vector3(1.4, 2.4, 1.0), "", Kit.flat(Color(0.5, 0.3, 0.24)), false)
	# The guardhouse's roof.
	var gh := MeshInstance3D.new()
	var gp := PrismMesh.new()
	gp.size = Vector3(6.6, 1.2, 6.6)
	gp.material = Kit.flat(SLATE)
	gh.mesh = gp
	gh.position = Vector3(6, UP + 0.6, 27)
	add_child(gh)


# --- Furniture ---------------------------------------------------------------------

func _furnish_ground() -> void:
	# The grand hall: the stair on the east side, a cupboard, banners, a rug.
	Kit.furniture(self, "rugRectangle", Vector3(-1.6, 0, 6.2), 90, false)
	Kit.furniture(self, "tableRound", Vector3(-1.2, 0, 3.0), 0)
	Kit.furniture(self, "pottedPlant", Vector3(-1.2, 0.72, 3.0), 0, false)
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(-4.7, 0, 6.6), 90)
	Kit.furniture(self, "coatRackStanding", Vector3(-4.4, 0, 7.6), 0)
	for p in [Vector3(-4.93, 0.25, 2.2), Vector3(1.6, 0.25, 7.93)]:
		Kit.model(self, CASTLE + "flag-banner-long.glb", p, 0 if p.x < -4 else 90, 1.0)
	Kit.furniture(self, "pottedPlant", Vector3(-4.4, 0, 0.6), 0)
	# The dining room: one long table, Hoard at its head (east end).
	for x in [-10.6, -8.9]:
		Kit.furniture(self, "tableCloth", Vector3(x, 0, 4), 0)
	for x in [-11.2, -10.0, -8.8]:
		Kit.furniture(self, "chairCushion", Vector3(x, 0, 3.15), 0)
		Kit.furniture(self, "chairCushion", Vector3(x, 0, 4.85), 180)
	Kit.furniture(self, "chairCushion", Vector3(-7.5, 0, 4.0), -90)
	Kit.furniture(self, "kitchenCabinet", Vector3(-11.2, 0, 0.5), 0)
	Kit.furniture(self, "kitchenCabinet", Vector3(-8.6, 0, 0.5), 0)
	Kit.furniture(self, "pottedPlant", Vector3(-12.4, 0, 7.4), 0)
	Kit.furniture(self, "rugRectangle", Vector3(-11.6, 0, 5.2), 90, false)
	for x in [-10.6, -8.9]:
		Kit.model(self, Kit.FOOD + "plate.glb", Vector3(x, 0.68, 4), 0, 0.35)
	Kit.model(self, Kit.FOOD + "cake.glb", Vector3(-9.7, 0.68, 4), 0, 0.6)
	# The library: shelves on every wall, Hoard's armchair, a reading table.
	for z in [1.0, 2.0, 4.0, 5.0]:
		Kit.furniture(self, "bookcaseOpen", Vector3(5.4, 0, z), 90)
	Kit.furniture(self, "bookcaseOpen", Vector3(8.8, 0, 0.3), 0)
	Kit.furniture(self, "bookcaseClosedWide", Vector3(11.8, 0, 0.3), 0)
	Kit.furniture(self, "bookcaseClosedWide", Vector3(10.4, 0, 7.6), 180)
	Kit.furniture(self, "loungeChair", Vector3(9.2, 0, 4.0), 180)
	Kit.furniture(self, "sideTable", Vector3(10.4, 0, 4.1), 180)
	Kit.furniture(self, "lampRoundFloor", Vector3(8.2, 0, 4.4), 0)
	Kit.furniture(self, "table", Vector3(11.4, 0, 5.6), 90)
	Kit.furniture(self, "rugRounded", Vector3(8.2, 0, 5.4), 0, false)
	# The kitchen.
	Kit.furniture(self, "kitchenStove", Vector3(-12.55, 0, -7.0), 90)
	Kit.furniture(self, "kitchenCabinet", Vector3(-12.55, 0, -6.1), 90)
	Kit.furniture(self, "kitchenSink", Vector3(-10.0, 0, -7.55), 0)
	Kit.furniture(self, "kitchenCabinet", Vector3(-10.9, 0, -7.55), 0)
	Kit.furniture(self, "kitchenCabinet", Vector3(-9.1, 0, -7.55), 0)
	Kit.furniture(self, "kitchenFridgeLarge", Vector3(-7.6, 0, -7.4), 0)
	Kit.furniture(self, "table", Vector3(-10.2, 0, -3.2), 0)
	for x in [-10.7, -9.7]:
		Kit.furniture(self, "chair", Vector3(x, 0, -4.0), 0)
	Kit.furniture(self, "trashcan", Vector3(-12.5, 0, -0.6), 0)
	# The butler's pantry: shelves of silver.
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(-6.6, 0, -6.8), 90)
	Kit.furniture(self, "kitchenCabinet", Vector3(-4.0, 0, -7.55), 0)
	Kit.furniture(self, "kitchenCabinet", Vector3(-4.9, 0, -7.55), 0)
	for x in [-5.2, -4.4, -3.8]:
		Kit.model(self, Kit.FOOD + "plate.glb", Vector3(x, 0.92, -7.55), 0, 0.3)
	# The servants' hall: coats by the stair.
	Kit.furniture(self, "coatRackStanding", Vector3(-6.5, 0, -0.5), 0)
	# The back hall: a bench, a clock and a portrait.
	Kit.furniture(self, "bench", Vector3(3.6, 0, -7.4), 0)
	Kit.block(self, Vector3(4.6, 1.0, -2.6), Vector3(0.5, 2.0, 0.4), "wood", Kit.flat(WOOD_DARK))
	_painting_on_wall(Vector3(1.5, 1.6, -0.06), 180, Color(0.35, 0.15, 0.12))
	# The study: Hoard's desk, shelves, a safe-looking cabinet.
	Kit.furniture(self, "desk", Vector3(10, 0, -6.6), 180)
	Kit.furniture(self, "chairDesk", Vector3(10, 0, -7.4), 0)
	Kit.furniture(self, "bookcaseClosedWide", Vector3(7.5, 0, -4.0), 90)
	Kit.furniture(self, "bookcaseOpen", Vector3(12.6, 0, -2.4), -90)
	Kit.furniture(self, "loungeChair", Vector3(11.4, 0, -1.2), 200)
	Kit.furniture(self, "rugRectangle", Vector3(9, 0, -3), 0, false)
	Kit.furniture(self, "lampSquareTable", Vector3(9.4, 0.76, -6.4), 0, false)


func _furnish_upstairs() -> void:
	# Pell's room: a narrow bed, a desk and his spare tailcoat.
	Kit.furniture(self, "bedSingle", Vector3(-12.4, UP, -6.6), 90)
	Kit.furniture(self, "desk", Vector3(-9.0, UP, -7.5), 0)
	Kit.furniture(self, "chair", Vector3(-9.0, UP, -6.8), 180)
	Kit.furniture(self, "coatRackStanding", Vector3(-7.6, UP, -4.4), 0)
	Kit.furniture(self, "loungeChair", Vector3(-10.4, UP, -1.4), 180)
	Kit.furniture(self, "rugSquare", Vector3(-11, UP, -4), 0, false)
	# The servants' landing: linen and boxes.
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(-6.6, UP, -7.0), 90)
	Kit.furniture(self, "cardboardBoxClosed", Vector3(-3.6, UP, -7.5), 15)
	# The upper landing: a window seat, a portrait and the linen cupboard.
	Kit.furniture(self, "benchCushion", Vector3(0, UP, -7.5), 0)
	Kit.furniture(self, "pottedPlant", Vector3(4.4, UP, -7.4), 0)
	_painting_on_wall(Vector3(-2.93, UP + 1.6, -5.0), 90, Color(0.2, 0.3, 0.45))
	# The guest room, all dust sheets.
	Kit.furniture(self, "bedDouble", Vector3(-11.8, UP, 4.0), 90)
	Kit.furniture(self, "sideTable", Vector3(-12.6, UP, 2.4), 90)
	Kit.furniture(self, "loungeChair", Vector3(-7.0, UP, 6.6), 200)
	# The gallery: portraits of Hoard, banners, and a bust of him.
	for z in [1.5, 4.0, 6.5]:
		_painting_on_wall(Vector3(-4.93, UP + 1.5, z), 90, Color(0.4 + z * 0.03, 0.25, 0.2))
	for x in [-3.0, 3.0]:
		Kit.model(self, CASTLE + "flag-banner-long.glb", Vector3(x, UP + 0.25, 7.93), 90, 1.0)
	Kit.boxed(self, GRAVEYARD + "pillar-square.glb", Vector3(-2.5, UP, 4.5), 0, 1.0)
	Kit.model(self, ARENA + "statue.glb", Vector3(-2.5, UP + 1.15, 4.5), 0, 0.7)
	Kit.furniture(self, "benchCushion", Vector3(0, UP, 2.6), 0)
	Kit.furniture(self, "rugRectangle", Vector3(-1.4, UP, 4.6), 90, false)
	# Hoard's bedroom: the big bed against the east wall.
	Kit.furniture(self, "bedDouble", Vector3(11.8, UP, -4.5), -90)
	Kit.furniture(self, "sideTable", Vector3(12.6, UP, -2.9), -90)
	Kit.furniture(self, "sideTable", Vector3(12.6, UP, -6.1), -90)
	Kit.furniture(self, "lampRoundTable", Vector3(12.6, UP + 0.76, -6.1), 0, false)
	Kit.furniture(self, "rugRounded", Vector3(9.4, UP, -4.5), 0, false)
	Kit.furniture(self, "loungeChairRelax", Vector3(6.4, UP, -6.6), 135)
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(5.4, UP, -4.0), 90)
	# The dressing room: a bath, mirrors and a wardrobe.
	Kit.furniture(self, "bathtub", Vector3(11.6, UP, 6.6), 0)
	Kit.furniture(self, "bathroomSink", Vector3(12.6, UP + 0.8, 3.0), -90, false)
	Kit.furniture(self, "bookcaseClosedDoors", Vector3(5.4, UP, 2.4), 90)
	Kit.furniture(self, "rugRectangle", Vector3(8.2, UP, 5.0), 0, false)


func _furnish_cellar() -> void:
	# The coal store: the heap under the chute, sacks and the boiler.
	Kit.block(self, Vector3(-12.1, CELLAR + 0.35, -3), Vector3(1.6, 0.7, 2.4), "concrete", Kit.flat(COAL))
	Kit.block(self, Vector3(-9.5, CELLAR + 1.0, -7.2), Vector3(2.2, 2.0, 1.4), "concrete", Kit.flat(Color(0.25, 0.22, 0.2)))
	Kit.block(self, Vector3(-9.5, CELLAR + 2.2, -7.2), Vector3(0.3, 0.6, 0.3), "", Kit.flat(Color(0.2, 0.2, 0.2)), false)
	# The wine cellar: racks of bottles, barrels and crates.
	for x in [-5.5, -4.2]:
		for z in [-7.4, -0.6]:
			Kit.boxed(self, PIRATE + "crate-bottles.glb", Vector3(x, CELLAR, z), 0, 1.0)
	for z in [-6.0, -4.5, -3.0, -1.5]:
		_wine_rack(Vector3(1.0, CELLAR, z))
		_wine_rack(Vector3(3.8, CELLAR, z))
	for p in [Vector3(-6.3, CELLAR, -0.9), Vector3(-6.3, CELLAR, -1.9)]:
		Kit.boxed(self, PIRATE + "barrel.glb", p, randf() * 90, 0.65)
	Kit.boxed(self, PIRATE + "crate.glb", Vector3(-0.4, CELLAR, -0.7), 10, 0.9)
	# The vault: shelves of everything Hoard took, and a sign.
	for x in [7.6, 12.4]:
		Kit.furniture(self, "bookcaseOpen", Vector3(x, CELLAR, -1.0), 90 if x < 10 else -90)
		Kit.furniture(self, "bookcaseOpen", Vector3(x, CELLAR, -2.2), 90 if x < 10 else -90)
	for p in [Vector3(7.7, CELLAR + 0.85, -1.0), Vector3(12.3, CELLAR + 0.85, -2.2), Vector3(7.7, CELLAR + 1.3, -2.2)]:
		Kit.model(self, PLATFORMER + "coin-gold.glb", p, 90, 0.6)
	Kit.model(self, ARENA + "statue.glb", Vector3(8.0, CELLAR, -3.4), 30, 0.6)
	Kit.model(self, Kit.FURNITURE + "books.glb", Vector3(12.3, CELLAR + 1.3, -1.0), 0, 2.0)
	var sign := Label3D.new()
	sign.text = "PROPERTY OF A. HOARD\n(ALL OF IT)"
	sign.font_size = 48
	sign.pixel_size = 0.004
	sign.modulate = Color(0.95, 0.85, 0.5)
	sign.position = Vector3(10, CELLAR + 1.9, -0.08)
	sign.rotation.y = PI
	add_child(sign)


func _wine_rack(at: Vector3) -> void:
	Kit.block(self, at + Vector3(0, 0.9, 0), Vector3(2.0, 1.8, 0.45), "wood", Kit.flat(WOOD_DARK))
	for i in 4:
		Kit.model(self, PIRATE + "bottle-large.glb", at + Vector3(-0.75 + i * 0.5, 1.8, 0), 0, 0.5)


## A framed painting flat on a wall, facing along `yaw` (0 faces south).
func _painting_on_wall(pos: Vector3, yaw: float, color: Color) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation.y = deg_to_rad(yaw)
	var frame := MeshInstance3D.new()
	var fm := BoxMesh.new()
	fm.size = Vector3(1.0, 0.8, 0.05)
	fm.material = Kit.flat(BRASS, 0.4)
	frame.mesh = fm
	n.add_child(frame)
	var canvas := MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(0.85, 0.65, 0.02)
	cm.material = Kit.flat(color)
	canvas.mesh = cm
	canvas.position = Vector3(0, 0, 0.025)
	n.add_child(canvas)
	add_child(n)
	return n


# --- Lights ----------------------------------------------------------------------

func _lamps() -> void:
	lamp("hall", Vector3(-1.5, UP, 4), true, 1.4, 7.0)
	lamp("dining", Vector3(-9.5, UP, 4), true, 1.3, 6.5)
	lamp("library", Vector3(9, UP, 4), false, 1.1, 6.5)
	lamp("study", Vector3(10, UP, -4), false, 1.1, 6.0)
	lamp("kitchen", Vector3(-10, UP, -4), true, 1.2, 6.0, Color(0.95, 0.95, 1.0))
	lamp("pantry", Vector3(-5, UP, -6), true, 0.9, 4.0)
	lamp("servants", Vector3(-5, UP, -1.2), true, 0.7, 4.0)
	lamp("back_hall", Vector3(2, UP, -4), true, 1.0, 6.0)
	lamp("gallery", Vector3(-1, ROOF, 4), true, 1.1, 6.5)
	lamp("landing", Vector3(1, ROOF, -4), true, 0.9, 5.5)
	lamp("servants_landing", Vector3(-5, ROOF, -6), false, 0.7, 4.0)
	lamp("pell_room", Vector3(-10, ROOF, -4), false, 0.9, 5.0)
	lamp("guest", Vector3(-9, ROOF, 4), false, 0.9, 5.5)
	lamp("bedroom", Vector3(9, ROOF, -4), false, 1.0, 6.0)
	lamp("dressing", Vector3(9, ROOF, 4), false, 1.0, 6.0)
	lamp("coal", Vector3(-10, 0, -4), false, 0.6, 4.5, Color(1.0, 0.8, 0.55))
	lamp("wine", Vector3(-3.5, 0, -4.5), true, 0.6, 5.0, Color(1.0, 0.8, 0.55))
	lamp("wine", Vector3(2.4, 0, -4), true, 0.5, 4.5, Color(1.0, 0.8, 0.55))
	lamp("passage", Vector3(6, 0, -6.6), false, 0.4, 3.0, Color(1.0, 0.8, 0.55))
	lamp("anteroom", Vector3(10, 0, -6), true, 1.2, 5.5, Color(0.85, 0.9, 1.0))
	lamp("vault", Vector3(10, 0, -2), true, 1.0, 4.5, Color(1.0, 0.9, 0.6))
	lamp("guardhouse", Vector3(6, UP, 27), true, 1.0, 5.0, Color(0.9, 0.95, 1.0))
	# Quieter rooms cast no shadows, to keep the night cheap.
	for room in ["servants", "pantry", "servants_landing", "pell_room", "guest", "dressing", "coal", "passage", "vault", "guardhouse"]:
		for l in lights[room]:
			l.shadow_enabled = false
	for l in lights["wine"]:
		l.shadow_enabled = false
	# Outside: the porch lanterns, the drive's lamp posts, the gate lanterns,
	# the terrace and the kitchen yard.
	for x in [-1.6, 1.6]:
		Kit.model(self, Kit.FURNITURE + "lampWall.glb", Vector3(x, 2.0, 8.12), 0, Kit.FURNITURE_SCALE)
	_outdoor_light("porch", Vector3(0, 2.0, 8.9), 6.0, 1.3, Color(1.0, 0.85, 0.6), true)
	for p in [Vector3(-3.4, 0, 20), Vector3(3.4, 0, 20), Vector3(-3.4, 0, 26.5), Vector3(3.4, 0, 26.5)]:
		_outdoor_light("drive", p + Vector3(0, 3.0, 0), 7.0, 1.4, Color(1.0, 0.82, 0.55), p.z < 21)
	for x in [-5.3, -3.0, 3.0]:
		_outdoor_light("gate", Vector3(x, 3.1, 30), 5.0, 0.9, Color(1.0, 0.75, 0.45), x == -3.0)
	Kit.model(self, Kit.FURNITURE + "lampWall.glb", Vector3(2.0, 2.4, -8.12), 180, Kit.FURNITURE_SCALE)
	_outdoor_light("terrace", Vector3(2.0, 2.4, -8.7), 7.0, 1.2, Color(1.0, 0.85, 0.6), true)
	Kit.model(self, Kit.FURNITURE + "lampWall.glb", Vector3(-13.12, 2.2, -4.0), -90, Kit.FURNITURE_SCALE)
	_outdoor_light("yard", Vector3(-13.6, 2.2, -4.0), 6.0, 1.0, Color(1.0, 0.9, 0.7), true)


func _outdoor_light(room: String, pos: Vector3, reach: float, energy: float, color: Color, shadow: bool) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.position = pos
	l.light_color = color
	l.omni_range = reach
	l.omni_attenuation = 1.2
	l.light_energy = energy
	l.shadow_enabled = shadow
	l.add_to_group("stealth_lights")
	add_child(l)
	if not lights.has(room):
		lights[room] = []
	lights[room].append(l)
	return l


func _switches() -> void:
	light_switch(["hall", "porch"], Vector3(-1.4, 1.3, 7.93), Vector3(0, 0, -1))
	light_switch(["dining"], Vector3(-5.1, 1.3, 2.2), Vector3(-1, 0, 0))
	light_switch(["library"], Vector3(5.1, 1.3, 6.2), Vector3(1, 0, 0))
	light_switch(["study"], Vector3(9.2, 1.3, -0.07), Vector3(0, 0, -1))
	light_switch(["kitchen"], Vector3(-7.1, 1.3, -2.2), Vector3(-1, 0, 0))
	light_switch(["pantry"], Vector3(-6.9, 1.3, -4.4), Vector3(1, 0, 0))
	light_switch(["servants"], Vector3(-6.9, 1.3, -1.9), Vector3(1, 0, 0))
	light_switch(["back_hall"], Vector3(-0.9, 1.3, -2.6), Vector3(1, 0, 0))
	light_switch(["gallery"], Vector3(-4.9, UP + 1.3, 2.2), Vector3(1, 0, 0))
	light_switch(["landing"], Vector3(-2.9, UP + 1.3, -2.2), Vector3(1, 0, 0))
	light_switch(["servants_landing"], Vector3(-6.9, UP + 1.3, -2.2), Vector3(1, 0, 0))
	light_switch(["pell_room"], Vector3(-7.1, UP + 1.3, -2.2), Vector3(-1, 0, 0))
	light_switch(["guest"], Vector3(-5.1, UP + 1.3, 2.2), Vector3(-1, 0, 0))
	light_switch(["bedroom"], Vector3(5.1, UP + 1.3, -2.2), Vector3(1, 0, 0))
	light_switch(["dressing"], Vector3(9.2, UP + 1.3, 0.07), Vector3(0, 0, 1))
	light_switch(["coal"], Vector3(-7.1, CELLAR + 1.3, -1.6), Vector3(-1, 0, 0))
	light_switch(["wine"], Vector3(-0.5, CELLAR + 1.3, -7.93), Vector3(0, 0, 1))
	light_switch(["passage"], Vector3(5.1, CELLAR + 1.3, -5.2), Vector3(1, 0, 0))
	light_switch(["anteroom", "vault"], Vector3(7.1, CELLAR + 1.3, -5.2), Vector3(1, 0, 0))
	light_switch(["guardhouse"], Vector3(4.6, 1.3, 24.07), Vector3(0, 0, 1))
	light_switch(["terrace"], Vector3(1.2, 1.3, -7.93), Vector3(0, 0, 1))
	light_switch(["yard"], Vector3(-12.93, 1.3, -4.1), Vector3(1, 0, 0))


# --- Security --------------------------------------------------------------------

func _security() -> void:
	fuse_box(Vector3(-13.12, 1.2, -1.2), -90)
	alarm_panel = alarm_switch(Vector3(-3.07, 1.4, -5.6), -90)
	group_switch("lasers", "Switch off the laser gates", "Switch on the laser gates", Vector3(7.07, 1.3, -6.0), 90)
	group_switch("cameras", "Switch off the cameras", "Switch on the cameras", Vector3(6.9, 1.3, 24.07), 0)
	var outside := {"accepts": ["guard"]}
	camera("gate", Vector3(2.92, 2.3, 29.0), -115, outside.merged({"sweep": 45.0, "pitch": 18.0}))
	camera("drive", Vector3(10.0, 3.4, 8.12), -40, outside.merged({"sweep": 35.0, "pitch": 15.0}))
	camera("terrace", Vector3(-2.0, 2.3, -8.12), 180, outside.merged({"sweep": 40.0, "pitch": 15.0}))
	camera("cellar", Vector3(-2.0, CELLAR + 2.25, -7.92), 0, {"sweep": 15.0, "pitch": -5.0, "period": 10.0, "accepts": ["butler"]})
	vault_keypad = keypad("vault", VAULT_CODE, Vector3(8.6, CELLAR + 1.3, -4.07), 180, "vault_door")
	gate_a = lasers("ante", Vector3(8.4, CELLAR, -7.9), Vector3(8.4, CELLAR, -4.1), [0.35, 0.9, 1.45], 5.0)
	gate_b_high = lasers("vault_high", Vector3(7.1, CELLAR, -5.0), Vector3(12.9, CELLAR, -5.0), [1.0, 1.5])
	gate_b_low = lasers("vault_low", Vector3(7.1, CELLAR, -5.12), Vector3(12.9, CELLAR, -5.12), [0.3], 4.0)
	add_zone("vault", AABB(Vector3(7, CELLAR - 0.5, -8), Vector3(6, 2.4, 8)), [])
	add_zone("house", AABB(Vector3(-13, CELLAR - 0.5, -8), Vector3(26, ROOF - CELLAR + 0.5, 16)), ["butler"])
	for box in [AABB(Vector3(-30, -1, 8), Vector3(60, 5, 22)), AABB(Vector3(-30, -1, -26), Vector3(60, 5, 18)),
			AABB(Vector3(-30, -1, -8), Vector3(17, 5, 16)), AABB(Vector3(13, -1, -8), Vector3(17, 5, 16))]:
		add_zone("grounds", box, ["guard"])
	# The boiler's roar in the coal store.
	add_masking(AABB(Vector3(-13, CELLAR - 0.5, -8), Vector3(6, 2.6, 8)), 0.6)
	var boiler := Sfx.on(self, "machine_hum_loop", -12.0)
	boiler.position = Vector3(-9.5, CELLAR + 1.0, -7.0)


# --- Things to use ------------------------------------------------------------------

func _things() -> void:
	# Notes.
	note("ottoline_note", "A note from Ottoline", OTTOLINE_NOTE, Vector3(-5.3, 1.3, 30.44), 0)
	note("guard_rota", "Guard rota", GUARD_ROTA, Vector3(8.93, 1.4, 26.5), -90)
	note("security_invoice", "An invoice", SECURITY_INVOICE, Vector3(9.6, 0.77, -6.5), 0, Vector3(0.22, 0.02, 0.3))
	note("hoard_diary", "Hoard's diary", HOARD_DIARY, Vector3(10.1, 0.79, -6.5), 0, Vector3(0.24, 0.05, 0.3))
	note("pantry_note", "A note in the silver drawer", PANTRY_NOTE, Vector3(-4.45, 0.92, -7.45), 0, Vector3(0.22, 0.02, 0.28))
	note("pell_duties", "Pell's duties", PELL_DUTIES, Vector3(-7.07, 1.4, -3.4), -90)
	note("hoard_letter", "A letter, unsent", HOARD_LETTER, Vector3(11.4, 0.68, 5.4), 0, Vector3(0.22, 0.02, 0.3))
	# The thank-you cards on the study desk, and Duke's biscuits in the guardhouse.
	pickup("thank_you_card", "Take a thank-you card", Kit.FURNITURE + "books.glb", Vector3(10.5, 0.77, -6.6), 1.2, 0)
	pickup("treats", "Take Duke's biscuits", Kit.FOOD + "cookie.glb", Vector3(8.1, 0.77, 24.6), 0.6, 0)
	# Disguises: the night guard's spare uniform and Pell's spare tailcoat.
	disguise_pickup("guard", "Put on the spare uniform", Kit.PROTOTYPE + "hat-cap.glb", Vector3(5.2, 0.78, 29.3), 1.2, 0,
		"Night guard. Look bored, keep walking.")
	Kit.block(self, Vector3(5.2, 0.38, 29.3), Vector3(0.8, 0.76, 0.6), "wood", Kit.flat(WOOD))
	disguise_pickup("butler", "Put on Pell's spare tailcoat", Kit.FOOD + "plate.glb", Vector3(-8.4, UP + 0.77, -7.5), 0.35, 0,
		"A tailcoat and a silver tray. Very proper. Keep away from Pell.")
	# The doorbell.
	var bell := UsableBody.new()
	bell.name = "Doorbell"
	bell.position = Vector3(1.0, 1.3, 8.1)
	bell.add_child(Kit.scene(Kit.PROPS + "doorbell.glb").instantiate())
	bell.add_box(Vector3(0, 0, 0.03), Vector3(0.15, 0.2, 0.08))
	bell.add_action("interact", "Ring the bell", _ring_bell)
	add_child(bell)
	# Hiding spots.
	_hide("hall", "Hide in the coat cupboard", Vector3(-4.45, 0, 6.6), 90)
	hide_spot("library_curtains", "Hide behind the curtains", Vector3(12.55, 0, 5.0), -90, Vector3(0, 1.4, 0), Vector3(0.9, 2.2, 0.5))
	hide_spot("pantry", "Hide in the silver cupboard", Vector3(-6.35, 0, -6.8), 90)
	hide_spot("linen", "Hide in the linen cupboard", Vector3(-6.35, UP, -7.0), 90)
	hide_spot("bedroom", "Hide in the wardrobe", Vector3(5.65, UP, -4.0), 90)
	hide_spot("dressing", "Hide in the wardrobe", Vector3(5.65, UP, 2.4), 90)
	hide_spot("guest", "Hide under the bed", Vector3(-11.8, UP, 2.6), 0, Vector3(0, 0.3, -0.6), Vector3(1.6, 0.7, 0.8))
	hide_spot("barrels", "Hide behind the barrels", Vector3(-5.8, CELLAR, -1.4), 90, Vector3(0, 1.0, 0), Vector3(1.8, 1.6, 0.8))
	hide_spot("guardhouse", "Hide in the locker", Vector3(8.35, 0, 28.5), -90)
	hide_spot("greenhouse", "Hide under the potting table", Vector3(23.0, 0, -21), -90, Vector3(0, 0.5, 0), Vector3(5.0, 0.8, 1.2))
	# The secret bookcase, its red book, and the lever on the far side.
	bookcase = SecretBookcase.make("library")
	bookcase.position = Vector3(6, 0, 0.3)
	add_child(bookcase)
	# People don't know about it: the doorway is shut to them when the
	# navigation is baked, and to everyone while the bookcase is closed.
	_secret_block = Kit.block(self, Vector3(6, 1.1, 0), Vector3(0.9, 2.2, 0.12), "", null)
	var book := UsableBody.new()
	book.name = "RedBook"
	book.position = Vector3(5.66, 1.12, 1.0)
	book.rotation.y = PI * 0.5
	var bm := MeshInstance3D.new()
	var bb := BoxMesh.new()
	bb.size = Vector3(0.06, 0.3, 0.22)
	bb.material = Kit.flat(Color(0.75, 0.08, 0.06))
	bm.mesh = bb
	book.add_child(bm)
	book.add_box(Vector3.ZERO, Vector3(0.15, 0.35, 0.28))
	book.add_action("interact", "Pull the red book", _pull_book)
	add_child(book)
	var lever := UsableBody.new()
	lever.name = "SecretLever"
	lever.position = Vector3(6.88, 1.2, -0.4)
	var lm := MeshInstance3D.new()
	var lb := BoxMesh.new()
	lb.size = Vector3(0.06, 0.4, 0.06)
	lb.material = Kit.flat(BRASS)
	lm.mesh = lb
	lever.add_child(lm)
	lever.add_box(Vector3.ZERO, Vector3(0.2, 0.45, 0.2))
	lever.add_action("interact", "Pull the lever", _pull_book)
	add_child(lever)
	# The portrait in Hoard's bedroom, with the safe behind it.
	_bedroom_safe()
	# The coal hatch in the kitchen yard, and the chute's mouth in the cellar.
	Kit.block(self, Vector3(-13.6, 0.05, -3), Vector3(1.0, 0.1, 0.9), "", Kit.flat(Color(0.18, 0.18, 0.2)), false)
	var hatch := UsableBody.new()
	hatch.name = "CoalHatch"
	hatch.position = Vector3(-13.6, 0.15, -3)
	hatch.collision_layer = Kit.LAYER_INTERACT
	hatch.add_box(Vector3.ZERO, Vector3(1.0, 0.3, 0.9))
	hatch.add_action("interact", "Pry the coal hatch open", _use_hatch)
	add_child(hatch)
	var mouth := UsableBody.new()
	mouth.name = "ChuteMouth"
	mouth.position = Vector3(-12.85, CELLAR + 1.4, -3)
	var mm := MeshInstance3D.new()
	var mb := BoxMesh.new()
	mb.size = Vector3(0.2, 0.8, 0.9)
	mb.material = Kit.flat(COAL)
	mm.mesh = mb
	mouth.add_child(mm)
	mouth.add_box(Vector3.ZERO, Vector3(0.3, 0.8, 0.9))
	mouth.add_action("interact", "Climb up the coal chute", _climb_chute)
	add_child(mouth)
	openings.append({"id": "coal_chute", "kind": "chute", "pos": Vector3(-13, -0.8, -3)})
	# The town's treasures, on a table at the back of the vault.
	Kit.furniture(self, "table", Vector3(10, CELLAR, -1.0), 0)
	treasure("vault", "Take the town's treasures", PIRATE + "chest.glb", Vector3(10, CELLAR + 0.66, -1.0), 0.42, 180, Vector3(1.4, 0.6, 0.8))
	treasure_stand.action("interact").on_use = _use_vault_table


func _hide(spot: String, verb: String, pos: Vector3, yaw: float) -> HideSpot:
	var h := hide_spot(spot, verb, pos, yaw)
	h.action("interact").on_use = _hide_and_record.bind(h, spot)
	return h


func _hide_and_record(pic: PlayerInteractionComponent, h: HideSpot, spot: String) -> void:
	h._use(pic)
	_record("hid:" + spot)


func _bedroom_safe() -> void:
	# The safe in the north wall: a dark recess with a steel door.
	var at := Vector3(10, UP + 1.5, -7.95)
	var back := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.6, 0.5, 0.02)
	bm.material = Kit.flat(Color(0.12, 0.12, 0.14))
	back.mesh = bm
	back.position = at + Vector3(0, 0, 0.06)
	add_child(back)
	_safe_door = Node3D.new()
	_safe_door.position = at + Vector3(-0.3, 0, 0.09)
	var dm := MeshInstance3D.new()
	var db := BoxMesh.new()
	db.size = Vector3(0.6, 0.5, 0.04)
	db.material = Kit.flat(STEEL, 0.4)
	dm.mesh = db
	dm.position = Vector3(0.3, 0, 0)
	_safe_door.add_child(dm)
	add_child(_safe_door)
	safe_keypad = keypad("safe", SAFE_CODE, at + Vector3(0.12, 0, 0.13), 0)
	safe_keypad.on_open = _open_safe
	# The portrait of Hoard over it, which swings aside.
	_painting = UsableBody.new()
	_painting.name = "Portrait"
	_painting.position = at + Vector3(-0.55, 0, 0.16)
	var art := _painting_on_wall(Vector3.ZERO, 0, Color(0.55, 0.3, 0.2))
	art.get_parent().remove_child(art)
	art.position = Vector3(0.55, 0, 0)
	art.scale = Vector3(1.1, 1.1, 1.0)
	_painting.add_child(art)
	_painting.add_box(Vector3(0.55, 0, 0), Vector3(1.1, 0.9, 0.08))
	_painting.add_action("interact", "Look behind the portrait", _swing_portrait)
	add_child(_painting)


func _marks() -> void:
	add_start("gates", Vector3(-7, 0, 33), 0)
	add_start("garden_wall", Vector3(-33.5, 0, -14), -90)
	add_start("greenhouse", Vector3(17.5, 0, -22.5), 180)
	add_start("coal_chute", Vector3(-15.2, 0, -3), -90)
	points = {
		# The house.
		"dining_seat": Vector3(-7.5, 0, 4.85), "sideboard": Vector3(-10, 0, 1.4),
		"kitchen": Vector3(-10, 0, -6.6), "kitchen_door_in": Vector3(-11.6, 0, -5),
		"pantry": Vector3(-4.6, 0, -6.6), "front_door_in": Vector3(0, 0, 6.6), "front_step": Vector3(0, 0, 9.6),
		"hall": Vector3(-2.4, 0, 4.5), "cellar_top": Vector3(-2, 0, -1.0), "back_hall": Vector3(2, 0, -4),
		"library_chair": Vector3(9.2, 0, 5.0), "library": Vector3(7.6, 0, 2.4), "study": Vector3(10, 0, -4),
		"vault_gloat": Vector3(10.5, CELLAR, -6.0), "wine": Vector3(1, CELLAR, -7.0),
		"bedroom": Vector3(8.6, UP, -3), "bed_side": Vector3(10.2, UP, -4.5), "bedroom_window": Vector3(8, UP, -7.2),
		"pell_room": Vector3(-10.4, UP, -2.6), "gallery": Vector3(0, UP, 4), "landing": Vector3(1, UP, -4),
		# The grounds.
		"gatehouse": Vector3(6.6, 0, 26.6), "gate_in": Vector3(-4, 0, 27.8), "drive_mid": Vector3(1.4, 0, 23),
		"turning_circle": Vector3(5.2, 0, 13.5), "east_lawn": Vector3(18.5, 0, 9.5), "library_side": Vector3(16, 0, 1),
		"east_garden": Vector3(18, 0, -11.5), "kitchen_yard": Vector3(-17, 0, -2), "fuse_box": Vector3(-14.0, 0, -1.2),
		"west_garden": Vector3(-21, 0, -13.5), "terrace": Vector3(2, 0, -11.4), "greenhouse": Vector3(19, 0, -15.2),
		"dog_bed": Vector3(20.2, 0, 6.0),
	}


# --- People ----------------------------------------------------------------------

func voice_info() -> Dictionary:
	return {
		"hoard": {"who": "Augustus Hoard: a pompous, oily rich man in his sixties, pleased with himself", "kokoro": "am_onyx", "speed": 0.95},
		"manor_pell": {"who": "Pell, Hoard's butler: a dry, weary, very proper old manservant", "kokoro": "am_fenrir", "speed": 0.95},
		"manor_guard_a": {"who": "Ogden, a night guard at the manor: big, slow, friendly and easily bored", "kokoro": "am_adam", "speed": 1.0},
		"manor_guard_b": {"who": "Hattie, a night guard at the manor: brisk, chatty and a little nosy", "kokoro": "af_kore", "speed": 1.05},
	}


func add_people(p_run: JobRun) -> Array:
	_run = p_run
	_run.event_recorded.connect(_on_event)
	hoard = ManorPersonScript.new()
	hoard.has_key = true
	hoard.setup("Hoard", "male-d", self, p_run, [
		{"at": "dining_seat", "face": Vector3(-1, 0, 0), "clip": "sit", "sit": Vector3(0, 0, -0.85), "time": 45.0, "room": "dining", "say": "Pell! More pudding!"},
		{"at": "library_chair", "face": Vector3(0, 0, -1), "clip": "sit", "sit": Vector3(0, 0, -0.8), "time": 40.0, "room": "library", "say": "Other people's books. My favourite kind."},
		{"at": "vault_gloat", "face": Vector3(0, 0, 1), "clip": "look-around", "time": 14.0, "room": "anteroom", "say": "Hello, my lovelies. All mine."},
		{"at": "bedroom", "time": 8.0, "room": "bedroom", "leave_dark": true, "say": "Bedtime for the richest man in Kettleford."},
		{"at": "bed_side", "face": Vector3(1, 0, 0), "clip": "sleep", "sit": Vector3(1.4, 0.45, 0), "time": 80.0, "do": "key_off"},
		{"at": "bedroom_window", "face": Vector3(0, 0, -1), "clip": "look-around", "time": 8.0, "room": "bedroom", "do": "key_on", "say": "Can't sleep. A midnight snack, I think."},
	], "hoard", {
		"mumble": "low", "accepts": ["butler", "guard"],
		"lines": {
			"curious": ["Who's there?", "Pell? Is that you?", "What was that?"],
			"seen": ["Who's there?"],
			"spotted": ["A burglar! In MY house!", "Guards! Guards!", "Stop, thief!"],
			"others": ["What's all this racket?"],
			"lost": ["Come out! I know you're here!", "Where did they go?"],
			"give_up": ["Hmph. Nerves.", "Pell's been at the brandy again."],
			"catch": ["Got you! Out! OUT!"],
			"bark": ["Duke! Hush!"],
			"wake": ["Wha...? I was resting my eyes."],
		},
		"extra_lines": ["My key! Where's my key? PELL!"],
	})
	hoard.position = points["dining_seat"]
	add_child(hoard)
	hoard.said.connect(_on_hoard_said)
	_snore = Sfx.on(hoard, "snore_loop", -10.0, false)
	pell = ManorPersonScript.new()
	pell.setup("Pell", "male-a", self, p_run, [
		{"at": "sideboard", "face": Vector3(0, 0, 1), "time": 30.0, "room": "dining", "say": "More gravy, sir?"},
		{"at": "kitchen", "face": Vector3(0, 0, -1), "time": 20.0, "room": "kitchen", "say": "Washing up. Again."},
		{"at": "pantry", "face": Vector3(0, 0, -1), "time": 18.0, "room": "pantry", "do": "check_alarm", "say": "Silver polished. Alarm on."},
		{"at": "kitchen_door_in", "time": 4.0, "do": "lock_kitchen", "say": "Back door, locked."},
		{"at": "front_door_in", "face": Vector3(0, 0, 1), "time": 4.0, "do": "lock_front", "say": "Front door, locked."},
		{"at": "library", "time": 10.0, "room": "library", "say": "Someone has moved the poetry."},
		{"at": "cellar_top", "time": 4.0, "do": "lock_cellar", "say": "Cellar, locked."},
		{"at": "pell_room", "clip": "sit", "face": Vector3(0, 0, -1), "sit": Vector3(0, 0, 1.0), "time": 35.0, "room": "pell_room", "leave_dark": true, "say": "Feet up. Five minutes."},
	], "manor_pell", {
		"mumble": "low", "accepts": ["guard"], "answers_door": true, "answers_alarm": true, "fixes_power": true,
		"lines": {
			"curious": ["Hm?", "Is someone there?", "Sir?"],
			"seen": ["And who might you be?"],
			"spotted": ["Intruder! Guards!", "I think not. Stop right there."],
			"others": ["What is it now?"],
			"lost": ["I'll find you. I find everything in this house."],
			"give_up": ["Mice. Very large mice.", "Nothing. As usual."],
			"catch": ["This way out, if you please."],
			"door": ["Coming.", "At this hour?"],
			"door_nobody": ["Nobody. How tiresome.", "Hello? ...Hm."],
			"power_out": ["Not the fuse again.", "Oh, splendid."],
			"power_fixed": ["Light. You're welcome, everyone."],
			"alarm": ["The alarm! Coming, sir!"],
			"bark": ["Duke, really."],
			"wake": ["I was merely resting my eyes."],
		},
		"extra_lines": ["Who turned the alarm off?", "Night shift? Come in. Wipe your boots.", "There is only one butler here, and it is me."],
	})
	pell.position = points["sideboard"]
	add_child(pell)
	var ogden := _guard("Ogden", "manor_guard_a", "low", [
		{"at": "gatehouse", "face": Vector3(0, 0, -1), "time": 16.0, "room": "guardhouse", "say": "Gate's quiet."},
		{"at": "gate_in", "face": Vector3(0, 0, 1), "time": 6.0},
		{"at": "drive_mid", "time": 2.0},
		{"at": "turning_circle", "clip": "look-around", "time": 9.0, "do": "overheard_key", "say": "Pell says Hoard leaves his vault key on the bedside table. Then snores."},
		{"at": "east_lawn", "time": 8.0, "say": "Good boy, Duke. Stay."},
		{"at": "library_side", "clip": "look-around", "time": 6.0},
		{"at": "turning_circle", "time": 2.0},
	], {
		"curious": ["Who goes there?", "Hello?", "Duke, was that you?"],
		"seen": ["Oi. Who's that?"],
		"spotted": ["Stop right there!", "Intruder! Over here!"],
		"others": ["What's up?"],
		"lost": ["Lost them.", "Come on out, I won't bite."],
		"give_up": ["Probably a fox.", "Seeing things again."],
		"catch": ["Got you. Off you go."],
		"alarm": ["Alarm! On my way!"],
		"bark": ["What's Duke barking at?"],
		"wake": ["Huh? Was I asleep? Don't tell Hoard."],
	}, false)
	ogden.position = points["gatehouse"]
	var hattie := _guard("Hattie", "manor_guard_b", "high", [
		{"at": "kitchen_yard", "time": 12.0, "say": "Bins. Thrilling."},
		{"at": "west_garden", "clip": "look-around", "time": 8.0},
		{"at": "terrace", "face": Vector3(0, 0, -1), "clip": "look-around", "time": 10.0, "say": "Lovely night for it. For what, though?"},
		{"at": "greenhouse", "time": 8.0, "say": "Hoard's prize marrows. Don't touch."},
		{"at": "east_garden", "time": 5.0},
		{"at": "terrace", "time": 3.0},
	], {
		"curious": ["Who's there?", "Hello-o?", "Ogden, is that you?"],
		"seen": ["Hang on. Who's that?"],
		"spotted": ["Oi! Stop!", "Intruder! Ogden!"],
		"others": ["What's going on?"],
		"lost": ["Where did you go?", "I saw you!"],
		"give_up": ["Hedgehog. Definitely a hedgehog.", "Must be the wind."],
		"catch": ["Gotcha! Out you go."],
		"power_out": ["Fuse again! I'm on it."],
		"power_fixed": ["And there was light!"],
		"alarm": ["Alarm! Coming!"],
		"bark": ["Duke! What is it?"],
		"wake": ["Ow. Who threw that?"],
	}, true)
	hattie.position = points["kitchen_yard"]
	dog = Dog.new()
	dog.setup(self, p_run, points["dog_bed"])
	dog.name = "Duke"
	dog.position = points["dog_bed"]
	add_child(dog)
	return [hoard, pell, ogden, hattie, dog]


func _guard(p_name: String, p_voice: String, p_mumble: String, p_routine: Array, p_lines: Dictionary, fixes: bool) -> ManorPerson:
	var g: ManorPerson = ManorPersonScript.new()
	g.setup(p_name, SOLDIER, self, _run, p_routine, p_voice, {
		"mumble": p_mumble, "accepts": ["guard", "butler"], "answers_alarm": true, "fixes_power": fixes,
		"torch": true, "lines": p_lines,
	})
	# The soldier is a little taller than the Mini Characters.
	g.rig.model.scale *= 0.85
	add_child(g)
	return g


## A person arrived at a routine step that asks for something (`"do"`).
func on_step(person: Person, what: String) -> void:
	match what:
		"key_off":
			if hoard.has_key:
				hoard.has_key = false
				_key_pickup = pickup("hoard_key", "Take Hoard's key", PLATFORMER + "key.glb", Vector3(12.6, UP + 0.8, -2.9), 1.0, 90)
			if is_instance_valid(_snore):
				_snore.play()
		"key_on":
			if is_instance_valid(_snore):
				_snore.stop()
			if is_instance_valid(_key_pickup) and not _key_pickup.is_queued_for_deletion():
				_key_pickup.queue_free()
				_key_pickup = null
				hoard.has_key = true
			elif not hoard.has_key and not _key_alarm_done:
				_key_alarm_done = true
				person.say("My key! Where's my key? PELL!")
				_record("hoard_missed_key")
				raise_alarm(person.global_position, "key")
		"check_alarm":
			if not alarm_armed:
				alarm_armed = true
				alarm_panel.set_action_text("interact", "Turn off the alarm")
				person.say("Who turned the alarm off?")
		"lock_kitchen":
			_lock(person, "kitchen_door")
		"lock_front":
			_lock(person, "front_door")
		"lock_cellar":
			_lock(person, "cellar_door")
		"overheard_key":
			var p := get_tree().get_first_node_in_group("moth") as Node3D
			if p and p.global_position.distance_to(person.global_position) < 11.0 and absf(p.global_position.y - person.global_position.y) < 2.0:
				_record("heard:key_bedside")


func _lock(person: Person, door_id: String) -> void:
	var d: HouseDoor = doors.get(door_id)
	if d == null:
		return
	if d.is_open:
		d.person_close(person)
	d.locked = true
	d._update_text()


func _on_hoard_said(_person: Person, text: String) -> void:
	if text == "Who's there?":
		_record("hoard_whos_there")


func _on_event(event: String) -> void:
	if event.begins_with("read:") and _run.has("read:hoard_diary") and _run.has("read:pantry_note") and _run.has("read:safe_note"):
		_record("found_whole_code")
	elif event == "escaped":
		# Judged as the player gets away (before the escape capers are).
		var dark := true
		for room in HOUSE_ROOMS:
			if lights_on(room):
				dark = false
		if dark:
			_record("manor_dark")


# --- What the things do -------------------------------------------------------------

func _ring_bell(pic: PlayerInteractionComponent) -> void:
	var at := Vector3(1.0, 1.3, 8.1)
	Sfx.at(self, "doorbell", at, 0.0)
	StealthNoise.make(self, at, 40.0, "bell", pic.get_parent())
	_record("doorbell_rung")


func _pull_book(pic: PlayerInteractionComponent) -> void:
	Sfx.at(self, "kenney:bookPlace1", pic.get_parent().global_position, -6.0, 0.8)
	bookcase.toggle(pic.get_parent())
	_secret_block.get_child(0).set_deferred("disabled", bookcase.is_open)


func _swing_portrait(pic: PlayerInteractionComponent) -> void:
	var t := _painting.create_tween()
	t.tween_property(_painting, "rotation:y", deg_to_rad(-100), 0.8).set_trans(Tween.TRANS_SINE)
	Sfx.at(self, "kenney:stoneDrag4", _painting.global_position, -10.0, 1.4)
	_painting.set_action_text("interact", "")
	_painting.collision_layer = 0
	UsableBody.hint(pic, "A safe, of course. Hoard's birthday, perhaps?")
	_record("found_safe")


func _open_safe() -> void:
	var t := _safe_door.create_tween()
	t.tween_property(_safe_door, "rotation:y", deg_to_rad(-110), 0.7).set_trans(Tween.TRANS_SINE)
	Sfx.at(self, "safe_open", _safe_door.global_position, -4.0)
	note("safe_note", "A slip of paper", SAFE_NOTE, Vector3(10, UP + 1.38, -7.88), 0, Vector3(0.2, 0.02, 0.14))
	_record("opened_safe")


func _use_hatch(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if not _chute_open:
		if not player.has_item("pry_bar"):
			UsableBody.hint(pic, "Padlocked. A pry bar would do it.")
			return
		_chute_open = true
		Sfx.at(self, "kenney:metalClick", Vector3(-13.6, 0.2, -3), 0.0, 0.7)
		StealthNoise.make(self, Vector3(-13.6, 0.2, -3), 6.0, "pry", player)
		_record("pried:coal_hatch")
		var hatch := get_node("CoalHatch") as UsableBody
		hatch.set_action_text("interact", "Slide down the coal chute")
		return
	_via_chute_t = _now()
	player.global_position = Vector3(-11.6, CELLAR + 0.95, -1.4)
	player.velocity = Vector3.ZERO
	Sfx.at(self, "kenney:rockHit2", Vector3(-12, CELLAR + 0.5, -3), -4.0, 0.8)
	StealthNoise.make(self, Vector3(-12, CELLAR + 0.5, -3), 4.0, "climb", player)
	_record("coal_chute_down")


func _climb_chute(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if not _chute_open:
		UsableBody.hint(pic, "The hatch at the top is padlocked shut.")
		return
	_via_chute_t = _now()
	player.global_position = Vector3(-14.6, 0.95, -3)
	player.velocity = Vector3.ZERO
	Sfx.at(self, "kenney:rockHit2", Vector3(-13.6, 0.3, -3), -6.0, 1.1)
	StealthNoise.make(self, Vector3(-12, CELLAR + 0.5, -3), 4.0, "climb", player)
	_record("coal_chute_up")


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


## Going in or out by the coal chute counts as the chute, not the nearest door.
func nearest_opening(at: Vector3) -> Dictionary:
	if _now() - _via_chute_t < 1.5:
		for o in openings:
			if o.id == "coal_chute":
				return o
	return super(at)


func _use_vault_table(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if _treasure_model != null:
		_take_treasure(pic)
		_update_vault_table(player)
		if not player.bag_changed.is_connected(_update_vault_table):
			player.bag_changed.connect(_update_vault_table.bind(player))
		return
	if not _card_left and player.take_item("thank_you_card"):
		_card_left = true
		var card := MeshInstance3D.new()
		var cm := BoxMesh.new()
		cm.size = Vector3(0.18, 0.13, 0.01)
		cm.material = Kit.flat(Color(0.97, 0.95, 0.88))
		card.mesh = cm
		card.position = Vector3(0, 0.07, 0)
		card.rotation.x = deg_to_rad(-15)
		treasure_stand.add_child(card)
		var words := Label3D.new()
		words.text = "Thank you!\n- the Moth"
		words.font_size = 18
		words.pixel_size = 0.002
		words.modulate = Color(0.3, 0.2, 0.5)
		words.position = Vector3(0, 0, 0.006)
		card.add_child(words)
		Sfx.at(self, "kenney:cardPlace1", treasure_stand.global_position, -6.0)
		_record("left_card")
		treasure_stand.set_action_text("interact", "")


func _update_vault_table(player: Node) -> void:
	if _treasure_model != null:
		return
	var can: bool = not _card_left and player.has_item("thank_you_card")
	treasure_stand.set_action_text("interact", "Leave the thank-you card" if can else "")


func _on_vault_opened(by: Node) -> void:
	if by == null or not by.is_in_group("moth"):
		return
	_record("vault_open")
	if by.get("disguise") == "butler":
		_record("vault_open_as_butler")


func return_treasure() -> void:
	super()
	treasure_stand.set_action_text("interact", "Take the town's treasures")


## The night guard Pell let in is welcome on the ground floor for a while;
## otherwise disguises work as usual (Pell knows there's only one butler).
func expects(person: Person, p: Moth) -> bool:
	if p.disguise == "guard" and in_house(p.global_position) and _run != null and _run.time < let_in_until:
		return p.global_position.y > -0.5 and p.global_position.y < UP and not p.is_crouching
	return super(person, p)


## Pell at the front door: the night guard gets let in; a second butler
## doesn't.
func at_front_door(person: Person, p: Moth) -> bool:
	if p.disguise == "guard":
		person.say("Night shift? Come in. Wipe your boots.")
		_record("let_in_as_guard")
		let_in_until = (_run.time if _run else 0.0) + 45.0
		person.wait_at("hall", 10.0)
		return true
	if p.disguise == "butler" and not _butler_rebuffed:
		_butler_rebuffed = true
		person.say("There is only one butler here, and it is me.")
		person.hold(2.0)
		return true
	return false


func screenshot_views() -> Dictionary:
	return {
		"lane": [Vector3(-7, 0, 34), 0.0, 4.0],
		"drive": [Vector3(1, 0, 27), 0.0, 3.0],
		"front": [Vector3(4, 0, 17), -10.0, 8.0],
		"portico": [Vector3(0, 2.65, 10), 0.0, 0.0],
		"hall": [Vector3(-3.5, 0, 7.2), -40.0, 0.0],
		"hall_stair": [Vector3(3.5, UP, 1.4), 180.0, -20.0],
		"dining": [Vector3(-5.8, 0, 7.2), 50.0, -10.0],
		"library": [Vector3(11.5, 0, 6.8), 40.0, -5.0],
		"secret": [Vector3(7.5, 0, 2.5), 60.0, 0.0],
		"study": [Vector3(8, 0, -1), -20.0, -10.0],
		"kitchen": [Vector3(-7.8, 0, -1.2), 33.0, -10.0],
		"pantry": [Vector3(-3.6, 0, -4.6), 38.0, -10.0],
		"back_hall": [Vector3(3.8, 0, -0.8), 43.0, -5.0],
		"gallery": [Vector3(-4, UP, 7.4), -52.0, -5.0],
		"bedroom": [Vector3(6, UP, -0.8), -55.0, -10.0],
		"pell_room": [Vector3(-7.6, UP, -0.6), 38.0, -10.0],
		"wine": [Vector3(-6, CELLAR, -0.8), -62.0, -5.0],
		"cellar_stair": [Vector3(-2, CELLAR, -7.6), 180.0, 15.0],
		"anteroom": [Vector3(7.6, CELLAR, -7.4), -120.0, -5.0],
		"vault": [Vector3(10, CELLAR, -3.6), 180.0, -15.0],
		"coal": [Vector3(-8, CELLAR, -0.8), 51.0, -10.0],
		"yard": [Vector3(-19.5, 0, -7), -128.0, 0.0],
		"terrace": [Vector3(2, 0, -18), 180.0, 5.0],
		"greenhouse_out": [Vector3(12, 0, -12), -38.0, 0.0],
		"guardhouse": [Vector3(4, 0, 25), -110.0, -10.0],
		"kennel": [Vector3(16, 0, 8), -100.0, -10.0],
	}
