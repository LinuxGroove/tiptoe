class_name LabsDoors
extends Node
## The labs' sliding doors: they open without a card from the inside (a push
## button), slide shut on their own a few seconds after everyone's through,
## and lock again behind them if they need a card. Following someone through
## before it shuts records "tailgated". A door's lock can be released for
## good (the server room's door controller), and a door can sound the alarm
## when it's opened from inside (the fire exit).

## Seconds a sliding door stays open once nobody's in it.
const OPEN_TIME := 4.0
const CLEAR := 1.6

var level: JobLevel
## door id -> {door, inside (Vector3), relock, held, alarm, open_t, by, side}
var _doors := {}


func _init(p_level: JobLevel) -> void:
	level = p_level
	name = "LabsDoors"


## Takes charge of door `id`: `inside` is a point in the room it opens from
## freely. `relock`: lock it again once it shuts (doors that need a card).
## `alarm`: opening it from inside raises the alarm (a fire exit).
func manage(id: String, inside: Vector3, relock := true, alarm := false) -> void:
	var d: HouseDoor = level.doors[id]
	_doors[id] = {"door": d, "inside": inside, "relock": relock, "held": false, "alarm": alarm,
		"open_t": 0.0, "by": null, "side": 0.0}
	d.action("interact").on_use = _use.bind(id)
	d.opened.connect(_on_opened.bind(id))
	d.closed.connect(_on_closed.bind(id))


## Releases a door's lock for good (it still slides shut, unlocked).
func release(id: String) -> void:
	var e: Dictionary = _doors[id]
	e.held = true
	var d: HouseDoor = e.door
	d.locked = false
	d._update_text()


func is_held(id: String) -> bool:
	return _doors.has(id) and _doors[id].held


func _use(pic: PlayerInteractionComponent, id: String) -> void:
	var e: Dictionary = _doors[id]
	var d: HouseDoor = e.door
	var p: Node3D = pic.get_parent()
	if d.locked and _side(d, p.global_position) == _side(d, e.inside):
		# The push button on the inside.
		d.locked = false
		if e.alarm:
			level.raise_alarm(d.global_position, "fire_exit")
	d._use(pic)


func _on_opened(by: Node, id: String) -> void:
	_doors[id].by = by
	_doors[id].open_t = 0.0


func _on_closed(_by: Node, id: String) -> void:
	var e: Dictionary = _doors[id]
	var d: HouseDoor = e.door
	if e.relock and not e.held and d.key_item != "":
		d.locked = true
		d._update_text()


func _physics_process(delta: float) -> void:
	var p := get_tree().get_first_node_in_group("moth") as Moth
	for id in _doors:
		var e: Dictionary = _doors[id]
		var d: HouseDoor = e.door
		var c := Person._door_center(d)
		if p:
			var side := _side(d, p.global_position)
			var near := Vector2(p.global_position.x - c.x, p.global_position.z - c.z).length() < 1.5 and absf(p.global_position.y - c.y) < 1.5
			if near and e.side != 0.0 and side != e.side and d.is_open and e.by is Person:
				_record("tailgated")
			e.side = side if near else 0.0
		if not d.is_open or not d.slide:
			continue
		if _someone_near(c, p):
			e.open_t = 0.0
			continue
		e.open_t += delta
		if e.open_t > OPEN_TIME:
			d.person_close(level)


func _someone_near(c: Vector3, p: Node3D) -> bool:
	if p and p.global_position.distance_to(c) < CLEAR:
		return true
	for o in get_tree().get_nodes_in_group("people"):
		if (o as Node3D).global_position.distance_to(c - Vector3(0, 1.0, 0)) < CLEAR:
			return true
	return false


## Which side of the door's wall `at` is on (+1 or -1).
static func _side(d: HouseDoor, at: Vector3) -> float:
	var n := Basis(Vector3.UP, d.closed_yaw) * Vector3(1, 0, 0)
	return signf(n.dot(at - d.global_position)) if n.dot(at - d.global_position) != 0.0 else 1.0


func _record(event: String) -> void:
	if JobRun.current:
		JobRun.current.record(event)
