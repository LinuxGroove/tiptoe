class_name Keypad
extends UsableBody
## A keypad by a door, a safe or a cabinet. Using it opens the keypad panel;
## the right code (usually written on a note somewhere) unlocks what it
## guards and records "keypad:<id>". Wrong codes buzz, which people nearby
## can hear.

signal opened

var id := ""
var code := ""
## The door it unlocks, if any.
var door: HouseDoor
## Called once with the right code (for things that aren't doors).
var on_open := Callable()
var solved := false
var _screen: MeshInstance3D


static func make(p_id: String, p_code: String) -> Keypad:
	var k := Keypad.new()
	k.id = p_id
	k.code = p_code
	k.name = "Keypad_" + p_id
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.14, 0.2, 0.04)
	bm.material = Kit.flat(Color(0.2, 0.21, 0.24))
	mi.mesh = bm
	k.add_child(mi)
	k._screen = MeshInstance3D.new()
	var sm := BoxMesh.new()
	sm.size = Vector3(0.1, 0.04, 0.01)
	k._screen.mesh = sm
	k._screen.position = Vector3(0, 0.06, 0.022)
	k.add_child(k._screen)
	k._set_screen(Color(0.9, 0.2, 0.15))
	k.add_box(Vector3.ZERO, Vector3(0.2, 0.26, 0.08))
	k.add_action("interact", "Use the keypad", k._use)
	return k


func _use(pic: PlayerInteractionComponent) -> void:
	if solved:
		UsableBody.hint(pic, "It's already open.")
		return
	var panel := get_tree().get_first_node_in_group("keypad_panel")
	if panel:
		panel.open_for(self, pic.get_parent())


## Tries a code; true if it's right.
func enter(tried: String) -> bool:
	if solved:
		return true
	if tried != code:
		Sfx.at(self, "keypad_wrong", global_position, -6.0)
		StealthNoise.make(self, global_position, 3.0, "beep", get_tree().get_first_node_in_group("moth"))
		return false
	solved = true
	Sfx.at(self, "keypad_ok", global_position, -6.0)
	_set_screen(Color(0.25, 0.95, 0.35))
	if door:
		door.locked = false
		door._update_text()
	if JobRun.current:
		JobRun.current.record("keypad:" + id)
	if on_open.is_valid():
		on_open.call()
	set_action_text("interact", "")
	opened.emit()
	return true


func _set_screen(c: Color) -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.emission_enabled = true
	m.emission = c
	m.emission_energy_multiplier = 1.5
	_screen.material_override = m
