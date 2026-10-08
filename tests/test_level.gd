extends JobLevel
## A bare room for testing the shared pieces: a lit and a dark half, a
## guard, a camera, a keypad door, lasers, a hiding spot, a fuse box, a
## stock room zone and a noisy machine corner. X runs east, Z south.

const FLOOR := Color(0.5, 0.5, 0.5)

var guard: Person
var cam: SecurityCamera
var pad: Keypad
var gate: LaserGate
var spot: HideSpot


func build() -> void:
	circuit = ["hall"]
	floor_rect(0, -15, -15, 15, 15, "concrete", FLOOR, false)
	# A wall across the north with a keypad door into a back room.
	line(0, Vector2(-15, -6), Vector2(1, 0), "WWWWWWDWWWWWWWW", [{"id": "back_door", "locked": true, "into": Vector2(-1, -8)}])
	house_boxes = [AABB(Vector3(-15, -1, -15), Vector3(30, 4, 30))]
	lamp("hall", Vector3(6, 2.6, 4), true, 1.6, 7.0)
	pad = keypad("back", "4071", Vector3(0.3, 1.3, -5.85), 0, "back_door")
	cam = camera("hall", Vector3(-8, 2.4, -5.9), 0, {"sweep": 10.0, "pitch": 15.0})
	gate = lasers("corridor", Vector3(10, 0, 0), Vector3(10, 0, 4), [0.35, 0.9])
	spot = hide_spot("wardrobe", "Hide in the wardrobe", Vector3(-12, 0, 8), 90)
	fuse_box(Vector3(12, 1.2, 12))
	add_zone("stock_room", AABB(Vector3(-15, -1, -15), Vector3(30, 4, 9)), [])
	add_masking(AABB(Vector3(8, -1, 8), Vector3(7, 4, 7)), 0.8)
	add_start("start", Vector3(0, 0, 12), 0)
	points = {"post": Vector3(-4, 0, 6), "fuse_box": Vector3(12, 0, 11)}


func add_people(p_run: JobRun) -> Array:
	guard = Person.new()
	guard.setup("Guard", "male-a", self, p_run, [{"at": "post", "face": Vector3(0, 0, 1), "time": 999.0}], "low", {
		"answers_alarm": true, "fixes_power": true, "accepts": ["staff"],
	})
	guard.position = points["post"]
	add_child(guard)
	return [guard]
