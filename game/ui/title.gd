extends Node
## The title screen: the job board (pick a job and where to start), settings,
## about and quit.

const TITLE_COLOR := Color("ffd54a")

var _ui: Control
var _col: VBoxContainer
var _start := ""


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var layer := CanvasLayer.new()
	add_child(layer)
	_ui = Control.new()
	_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_ui)
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.05, 0.1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui.add_child(bg)
	var version := LGUi.label("v%s" % GameConfig.version(), "HintLabel")
	_ui.add_child(version)
	version.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 12)
	_col = LGUi.centered_column(_ui, 640)
	LGScreenFit.center(_col)
	LGAudio.play_music(Sfx.music("title", "res://assets/kenney/audio/music/wacky_waiting.ogg"), -10.0)
	_show_main()


func _clear() -> void:
	for c in _col.get_children():
		_col.remove_child(c)
		c.queue_free()


func _add_title() -> void:
	var title := LGUi.label("Tiptoe", "HeaderLarge")
	title.add_theme_color_override("font_color", TITLE_COLOR)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_col.add_child(title)


func _show_main() -> void:
	_clear()
	_add_title()
	var tag := LGUi.label("Put things back where they belong. Quietly.", "HintLabel")
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_col.add_child(tag)
	_col.add_child(LGUi.button("Job board", _show_board))
	_col.add_child(LGUi.button("Settings", _show_settings))
	_col.add_child(LGUi.button("About Tiptoe", _show_about))
	var quit := LGUi.button("Quit", _quit)
	quit.theme_type_variation = "DangerButton"
	_col.add_child(quit)
	LGUi.focus_first(_col)


func _show_board() -> void:
	_clear()
	_col.add_child(LGUi.label("Job board", "HeaderMedium"))
	for job in Jobs.all():
		if job.playable:
			var m := Progress.mastery(job.id)
			var done := Progress.capers_done(job.id).size()
			var b := LGUi.button("%s: %s   (mastery %d, capers %d/%d)" % [job.title, job.treasure, m, done, job.capers.size()], _show_job.bind(job.id), 600)
			_col.add_child(b)
		else:
			var l := LGUi.label("%s: %s (coming later)" % [job.title, job.treasure], "HintLabel")
			_col.add_child(l)
	_col.add_child(LGUi.button("Back", _show_main))
	LGUi.focus_first(_col)


func _show_job(id: String) -> void:
	var job := Jobs.get_job(id)
	_clear()
	_col.add_child(LGUi.label(job.title, "HeaderMedium"))
	var blurb := LGUi.label(job.blurb)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.custom_minimum_size = Vector2(600, 0)
	_col.add_child(blurb)
	var m := Progress.mastery(id)
	var best := Progress.best_score(id)
	_col.add_child(LGUi.label("Mastery %d    Best score %d    Capers %d/%d" % [m, best, Progress.capers_done(id).size(), job.capers.size()], "HintLabel"))
	var starts := []
	for s in job.open_start_points(m):
		starts.append([s.id, s.title])
	_start = starts[0][0]
	_col.add_child(LGCycler.make("Start from", starts, _start, _set_start, 600))
	var gadgets := []
	for g in job.open_gadgets(m):
		gadgets.append(g.title)
	_col.add_child(LGUi.label("Bag: " + ", ".join(gadgets), "HintLabel"))
	_col.add_child(LGUi.button("Start the job", _play.bind(id), 600))
	_col.add_child(LGUi.button("Back", _show_board))
	LGUi.focus_first(_col)


func _set_start(value: Variant) -> void:
	_start = value


func _play(id: String) -> void:
	Jobs.play(id, _start)


func _show_settings() -> void:
	_clear()
	_col.add_child(LGUi.label("Settings", "HeaderMedium"))
	_col.add_child(SettingsPanel.new())
	_col.add_child(LGCycler.make("Leads", SettingsPanel.ON_OFF, LGSettings.get_value("play", "leads"), _set_play.bind("leads"), 440))
	_col.add_child(LGCycler.make("Noise rings", SettingsPanel.ON_OFF, LGSettings.get_value("play", "noise_rings"), _set_play.bind("noise_rings"), 440))
	_col.add_child(LGCycler.make("Invert look", SettingsPanel.ON_OFF, LGSettings.get_value("play", "invert_look"), _set_play.bind("invert_look"), 440))
	_col.add_child(LGUi.button("Back", _show_main))
	LGUi.focus_first(_col)


func _set_play(value: Variant, key: String) -> void:
	LGSettings.set_value("play", key, value)


func _show_about() -> void:
	_clear()
	_col.add_child(LGUi.label("About Tiptoe", "HeaderMedium"))
	var t := LGUi.label("A sneaky first person game about putting things back. Made by the LinuxGroove team with Godot, Cogito and Kenney's assets.")
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.custom_minimum_size = Vector2(600, 0)
	_col.add_child(t)
	_col.add_child(LGUi.button("Back", _show_main))
	LGUi.focus_first(_col)


func _quit() -> void:
	get_tree().quit()
