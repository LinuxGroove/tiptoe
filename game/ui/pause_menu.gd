class_name TiptoePause
extends Control
## The pause menu during a job. Cogito's player opens it with the menu button
## and listens for `resume`, so it keeps Cogito's pause menu's names.

signal resume
signal give_up
signal quit_to_title

var _col: VBoxContainer
var _panel: PanelContainer


func _init() -> void:
	name = "PauseMenu"
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	_panel = PanelContainer.new()
	_panel.theme_type_variation = "DarkPanel"
	center.add_child(_panel)
	_col = VBoxContainer.new()
	_col.add_theme_constant_override("separation", 10)
	_panel.add_child(_col)
	_col.add_child(LGUi.label("Paused", "HeaderMedium"))
	_col.add_child(LGUi.button("Carry on", close_pause_menu, 440))
	_col.add_child(LGCycler.make("Leads", SettingsPanel.ON_OFF, LGSettings.get_value("play", "leads"), _set_play.bind("leads"), 440))
	_col.add_child(LGCycler.make("Noise rings", SettingsPanel.ON_OFF, LGSettings.get_value("play", "noise_rings"), _set_play.bind("noise_rings"), 440))
	_col.add_child(LGCycler.make("Invert look", SettingsPanel.ON_OFF, LGSettings.get_value("play", "invert_look"), _set_play.bind("invert_look"), 440))
	_col.add_child(LGCycler.make("Hold to crouch", [[false, "On"], [true, "Off"]], LGSettings.get_value("play", "toggle_crouch"), _set_play.bind("toggle_crouch"), 440))
	var quit := LGUi.button("Call it a night", _give_up, 440)
	quit.theme_type_variation = "DangerButton"
	_col.add_child(quit)
	_col.add_child(LGUi.button("Back to the title", _quit, 440))


func _ready() -> void:
	LGScreenFit.center(_panel)


func _set_play(value: Variant, key: String) -> void:
	LGSettings.set_value("play", key, value)


func open_pause_menu() -> void:
	# Cogito opens this from the player's _input; without this the same Escape
	# press reaches _unhandled_input below and closes the menu straight away.
	if is_inside_tree():
		get_viewport().set_input_as_handled()
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	LGUi.focus_first(_col)


func close_pause_menu() -> void:
	var was_open := visible
	visible = false
	if is_inside_tree():
		get_tree().paused = false
	var f := get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	if f:
		f.release_focus()
	if was_open:
		resume.emit()


func _give_up() -> void:
	close_pause_menu()
	give_up.emit()


func _quit() -> void:
	visible = false
	get_tree().paused = false
	quit_to_title.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("menu")):
		get_viewport().set_input_as_handled()
		close_pause_menu()
