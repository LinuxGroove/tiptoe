class_name ResultsPanel
extends Control
## How the night went: the score and ratings, capers finished (new ones
## marked), and anything a new mastery level unlocked.

signal again
signal board

var _col: VBoxContainer


func _init() -> void:
	name = "Results"
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.06, 0.8)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.theme_type_variation = "DarkPanel"
	center.add_child(panel)
	_col = VBoxContainer.new()
	_col.add_theme_constant_override("separation", 8)
	_col.custom_minimum_size = Vector2(560, 0)
	panel.add_child(_col)


func show_result(job: JobDef, result: Dictionary, unlocked: Dictionary) -> void:
	for c in _col.get_children():
		c.queue_free()
	var got_it: bool = result.get("treasure", false)
	_col.add_child(LGUi.label("Got away with it!" if got_it else "Night over", "HeaderMedium"))
	if got_it:
		_col.add_child(LGUi.label(job.treasure + " is going home."))
	else:
		_col.add_child(LGUi.label("The trophy's still there. There's always tomorrow night.", "HintLabel"))
	var t := int(result.get("time", 0.0))
	_col.add_child(LGUi.label("Time %d:%02d    Seen %d    Caught %d" % [t / 60, t % 60, result.get("spotted", 0), result.get("caught", 0)]))
	var ratings: Array = result.get("ratings", [])
	if not ratings.is_empty():
		_col.add_child(LGUi.label(", ".join(ratings)))
	_col.add_child(LGUi.label("Score %d" % result.get("score", 0), "HeaderMedium"))
	var new_capers: Array = unlocked.get("capers", [])
	for id in result.get("capers", []):
		var c := job.caper(id)
		if c:
			var l := LGUi.label(("New caper: " if id in new_capers else "Caper: ") + c.title)
			if id in new_capers:
				l.add_theme_color_override("font_color", Color("ffd54a"))
			_col.add_child(l)
	var m_from: int = unlocked.get("mastery_from", 0)
	var m_to: int = unlocked.get("mastery_to", 0)
	if m_to > m_from:
		_col.add_child(LGUi.label("Mastery %d!" % m_to, "HeaderMedium"))
		for level in range(m_from + 1, m_to + 1):
			for u in job.unlocks_at(level):
				_col.add_child(LGUi.label(u))
	_col.add_child(LGUi.button("Try again", _again, 440))
	_col.add_child(LGUi.button("Back to the job board", _board, 440))
	visible = true
	LGUi.focus_first(_col)


func _again() -> void:
	visible = false
	again.emit()


func _board() -> void:
	visible = false
	board.emit()
