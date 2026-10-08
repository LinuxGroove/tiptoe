class_name HouseDoor
extends UsableBody
## A hinged door. It sits at its hinge and swings 90 degrees. It can be
## locked, opened with a key from the bag, or picked with lockpicks (slowly,
## with ticks people nearby can hear). Opening it makes a noise; crouching
## opens it gently and quietly. People open doors as they walk through.

signal opened(by: Node)
signal closed(by: Node)
signal unlocked(how: String)

const WIDTH := 0.9
const HEIGHT := 2.1
const SWING := 90.0
const OPEN_NOISE := 4.0
const GENTLE_NOISE := 1.2
const PICK_NOISE := 1.8

## Event names use this id: "opened:<id>", "entered_by:<id>".
var id := ""
var is_open := false
var locked := false
## Bag item that unlocks it ("" for none).
var key_item := ""
## Can it be picked with lockpicks? Seconds it takes.
var pickable := false
var pick_time := 6.0
## +1 or -1: which way it swings open.
var swing := 1
var closed_yaw := 0.0
var _tween: Tween
var _pick_left := 0.0
var _picker: Node = null
var _tick := 0.0


static func make(p_id: String, model_path: String) -> HouseDoor:
	var d := HouseDoor.new()
	d.id = p_id
	d.name = "Door_" + p_id
	var m: Node3D = Kit.scene(model_path).instantiate()
	m.name = "Model"
	d.add_child(m)
	# The kit's doors hang from the origin and reach along +Z.
	d.add_box(Vector3(0, HEIGHT * 0.5, WIDTH * 0.5), Vector3(0.08, HEIGHT, WIDTH))
	d.add_action("interact", "Open", d._use)
	d.add_action("interact2", "", d._use2)
	return d


func _ready() -> void:
	closed_yaw = rotation.y
	if is_open:
		rotation.y = _open_yaw()
	_update_text()


func _physics_process(delta: float) -> void:
	if _picker == null:
		return
	var pic: PlayerInteractionComponent = _picker.player_interaction_component
	if pic.interactable != self or _picker.velocity.length() > 1.0:
		_picker = null
		hint(pic, "You stop picking the lock.")
		return
	_pick_left -= delta
	_tick -= delta
	if _tick <= 0.0:
		_tick = randf_range(0.35, 0.7)
		Sfx.at(self, "lockpick_tick_%d" % randi_range(1, 4), _lock_pos(), -6.0)
		StealthNoise.make(self, _lock_pos(), PICK_NOISE, "pick", _picker)
	if _pick_left <= 0.0:
		_picker = null
		locked = false
		Sfx.at(self, "lock_open", _lock_pos(), -4.0)
		hint(pic, "Click. It's open.")
		_record("picked_lock")
		_record("unlocked:" + id)
		unlocked.emit("pick")
		_update_text()


## Opens or closes it for a person (the owners don't sneak).
func person_open(by: Node) -> void:
	if not is_open:
		_set_open(true, by, false)


func person_close(by: Node) -> void:
	if is_open:
		_set_open(false, by, false)


func _use(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if locked:
		if key_item != "" and player.has_item(key_item):
			locked = false
			Sfx.at(self, "kenney:metalLatch", _lock_pos(), -4.0)
			_record("used_key")
			_record("unlocked:" + id)
			unlocked.emit("key")
		else:
			Sfx.at(self, "kenney:beltHandle2", _lock_pos(), -8.0)
			StealthNoise.make(self, _lock_pos(), 2.5, "rattle", player)
			hint(pic, "Locked." + (" It could be picked." if pickable else ""))
			return
	var gentle: bool = player.get("is_crouching") == true
	_set_open(not is_open, player, gentle)


func _use2(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if not locked or not pickable:
		return
	if not player.has_item("lockpicks"):
		hint(pic, "You'd need lockpicks.")
		return
	if _picker:
		return
	_picker = player
	_pick_left = pick_time
	_tick = 0.0
	hint(pic, "Picking the lock... keep still.")


func _set_open(open: bool, by: Node, gentle: bool) -> void:
	is_open = open
	if _tween:
		_tween.kill()
	_tween = create_tween()
	var t := 1.1 if gentle else 0.45
	_tween.tween_property(self, "rotation:y", _open_yaw() if open else closed_yaw, t).set_trans(Tween.TRANS_SINE)
	var vol := -14.0 if gentle else -4.0
	Sfx.at(self, "kenney:doorOpen_1" if open else "kenney:doorClose_4", _lock_pos(), vol)
	if by and by.is_in_group("moth"):
		StealthNoise.make(self, _lock_pos(), GENTLE_NOISE if gentle else OPEN_NOISE, "door", by)
		if open:
			_record("opened:" + id)
	if open:
		opened.emit(by)
	else:
		closed.emit(by)
	_update_text()


func _open_yaw() -> float:
	return closed_yaw + deg_to_rad(SWING) * swing


func _lock_pos() -> Vector3:
	return global_transform * Vector3(0, 1.0, WIDTH * 0.85)


func _update_text() -> void:
	if locked:
		set_action_text("interact", "Try the door")
		set_action_text("interact2", "Pick the lock" if pickable else "")
	else:
		set_action_text("interact", "Close" if is_open else "Open")
		set_action_text("interact2", "")


func _record(event: String) -> void:
	if JobRun.current:
		JobRun.current.record(event)
