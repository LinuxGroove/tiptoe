extends UsableBody
## The roof hatch over the market's stock room, padlocked on the roof side.
## Lockpicks open the padlock (slowly, with ticks people below can hear),
## then the lid swings up: climb down the ladder into the stock room, or just
## drop through. From below, the ladder climbs back up once the hatch is open.
## The body sits on the lid's hinge (its north edge); the lid reaches south.

const PICK_TIME := 5.0
const PICK_NOISE := 2.0
const SIZE := 1.0

var level: JobLevel
var locked := true
var is_open := false
## Where the player lands at the foot of the ladder, and stands on the roof.
var below := Vector3.ZERO
var above := Vector3.ZERO
var _picker: Node = null
var _pick_left := 0.0
var _tick := 0.0


static func make(p_level: JobLevel, hinge: Vector3) -> UsableBody:
	var h: UsableBody = load("res://game/jobs/market/market_hatch.gd").new()
	h.level = p_level
	h.name = "RoofHatch"
	h.position = hinge
	h.collision_layer = Kit.LAYER_WORLD | Kit.LAYER_INTERACT
	var lid := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(SIZE, 0.08, SIZE)
	bm.material = Kit.flat(Color(0.42, 0.44, 0.46), 0.6)
	lid.mesh = bm
	lid.position = Vector3(0, 0.04, SIZE * 0.5)
	h.add_child(lid)
	var lock := MeshInstance3D.new()
	var lm := BoxMesh.new()
	lm.size = Vector3(0.1, 0.12, 0.05)
	lm.material = Kit.flat(Color(0.75, 0.6, 0.25), 0.4)
	lock.mesh = lm
	lock.name = "Padlock"
	lock.position = Vector3(0, 0.1, SIZE - 0.06)
	h.add_child(lock)
	h.add_box(Vector3(0, 0.04, SIZE * 0.5), Vector3(SIZE, 0.1, SIZE))
	h.add_action("interact", "Pick the padlock", h._use)
	return h


func _physics_process(delta: float) -> void:
	_update_text()
	if _picker == null:
		return
	var pic: PlayerInteractionComponent = _picker.player_interaction_component
	if pic.interactable != self or _picker.velocity.length() > 1.0:
		_picker = null
		hint(pic, "You stop picking the padlock.")
		return
	_pick_left -= delta
	_tick -= delta
	if _tick <= 0.0:
		_tick = randf_range(0.35, 0.7)
		Sfx.at(self, "lockpick_tick_%d" % randi_range(1, 4), _lock_pos(), -6.0)
		StealthNoise.make(self, _lock_pos(), PICK_NOISE, "pick", _picker)
	if _pick_left <= 0.0:
		_picker = null
		unlock()
		hint(pic, "Click. The padlock's off.")


## The padlock comes off (picked, or in tests).
func unlock() -> void:
	if not locked:
		return
	locked = false
	Sfx.at(self, "lock_open", _lock_pos(), -4.0)
	var lock := get_node_or_null("Padlock")
	if lock:
		lock.queue_free()
	_record("picked_lock")
	_record("unlocked:roof_hatch")


## Swings the lid up and over.
func open() -> void:
	if is_open or locked:
		return
	is_open = true
	Sfx.at(self, "hatch_creak", global_position, -4.0)
	StealthNoise.make(self, global_position + Vector3(0, -1.0, 0.5), 4.0, "door", get_tree().get_first_node_in_group("moth"))
	var t := create_tween()
	t.tween_property(self, "rotation:x", deg_to_rad(-100.0), 0.6).set_trans(Tween.TRANS_SINE)
	_record("opened:roof_hatch")


## Down the ladder into the stock room, or up it onto the roof.
func climb(player: Node, up: bool) -> void:
	if not is_open:
		return
	var to := above if up else below
	player.global_position = to + Vector3(0, 0.9, 0)
	player.velocity = Vector3.ZERO
	StealthNoise.make(self, below + Vector3(0, 0.2, 0), 3.0, "climb", player)
	Sfx.at(self, "kenney:cloth2", global_position, -8.0)
	_record("climbed_hatch_up" if up else "climbed_hatch_down")


func _use(pic: PlayerInteractionComponent) -> void:
	var player: Node = pic.get_parent()
	if _from_below(player):
		if is_open:
			climb(player, true)
		else:
			hint(pic, "It's padlocked on the roof side.")
		return
	if locked:
		if not player.has_item("lockpicks"):
			hint(pic, "Padlocked. Lockpicks would do it.")
			return
		if _picker:
			return
		_picker = player
		_pick_left = PICK_TIME
		_tick = 0.0
		hint(pic, "Picking the padlock... keep still.")
		return
	if not is_open:
		open()
		return
	climb(player, false)


func _from_below(player: Node) -> bool:
	return player.global_position.y < level.global_position.y + JobLevel.STOREY


func _update_text() -> void:
	var p := get_tree().get_first_node_in_group("moth") as Node3D
	if p == null or p.global_position.distance_to(global_position) > 4.0:
		return
	var text := ""
	if _from_below(p):
		text = "Climb up to the roof" if is_open else "Try the hatch"
	elif locked:
		text = "Pick the padlock"
	elif not is_open:
		text = "Open the hatch"
	else:
		text = "Climb down the ladder"
	if action("interact").interaction_text != text:
		set_action_text("interact", text)


func _lock_pos() -> Vector3:
	return global_transform * Vector3(0, 0.1, SIZE - 0.06)


func _record(event: String) -> void:
	if JobRun.current:
		JobRun.current.record(event)
