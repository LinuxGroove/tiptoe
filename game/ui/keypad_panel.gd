class_name KeypadPanel
extends PanelContainer
## The keypad up close: type a code with the buttons or the number keys,
## Enter to try it, Escape (or Back) to step away.

var keypad: Keypad
var player: Node
var _display: Label
var _typed := ""


func _init() -> void:
	name = "KeypadPanel"
	visible = false
	add_to_group("keypad_panel")
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme_type_variation = "DarkPanel"
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	add_child(col)
	_display = Label.new()
	_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_display.add_theme_font_size_override("font_size", 36)
	_display.custom_minimum_size = Vector2(240, 0)
	col.add_child(_display)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	col.add_child(grid)
	for k in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "Clear", "0", "Enter"]:
		var b := Button.new()
		b.text = k
		# Wide enough for Clear and Enter, so the columns match.
		b.custom_minimum_size = Vector2(136, 56)
		b.pressed.connect(_press.bind(k))
		grid.add_child(b)
	var back := Button.new()
	back.text = "Step away"
	back.pressed.connect(close)
	col.add_child(back)


func open_for(p_keypad: Keypad, p_player: Node) -> void:
	keypad = p_keypad
	player = p_player
	_typed = ""
	_show("")
	visible = true
	reset_size()
	position = (get_parent_area_size() - size) * 0.5
	if player and player.has_method("_on_pause_movement"):
		player.is_showing_ui = true
		player._on_pause_movement()
	LGUi.focus_first(self)


func close() -> void:
	if not visible:
		return
	visible = false
	var f := get_viewport().gui_get_focus_owner()
	if f:
		f.release_focus()
	if player and player.has_method("_on_resume_movement"):
		player.is_showing_ui = false
		player._on_resume_movement()


## Presses a key ("0"-"9", "Clear", "Enter").
func _press(k: String) -> void:
	if keypad == null:
		return
	match k:
		"Clear":
			_typed = ""
			_show("")
		"Enter":
			if keypad.enter(_typed):
				_show("OPEN")
				close()
			else:
				_typed = ""
				_show("WRONG")
		_:
			if _typed.length() < 6:
				_typed += k
				Sfx.at(keypad, "keypad_beep", keypad.global_position, -10.0, 0.9 + 0.05 * int(k))
				_show(_typed)


func _show(text: String) -> void:
	_display.text = text if text != "" else "- - - -"


# _input, ahead of the buttons, so Enter tries the code rather than pressing
# whichever button has focus.
func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("menu"):
		get_viewport().set_input_as_handled()
		close()
	elif event is InputEventKey and event.pressed and not event.echo:
		var kc: int = event.keycode
		if kc >= KEY_0 and kc <= KEY_9:
			_press(str(kc - KEY_0))
			get_viewport().set_input_as_handled()
		elif kc >= KEY_KP_0 and kc <= KEY_KP_9:
			_press(str(kc - KEY_KP_0))
			get_viewport().set_input_as_handled()
		elif kc in [KEY_ENTER, KEY_KP_ENTER]:
			_press("Enter")
			get_viewport().set_input_as_handled()
		elif kc == KEY_BACKSPACE:
			_press("Clear")
			get_viewport().set_input_as_handled()
