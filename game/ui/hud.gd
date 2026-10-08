class_name JobHud
extends Control
## The heads-up display during a job: the light gem (how lit you are), rings
## for noises, what's in your bag, the lead you're following, capers as you
## finish them, and notes you read. Cogito's own HUD still shows prompts and
## hints underneath.

const RING_TIME := 0.9
const TOAST_TIME := 3.5

var run: JobRun
var player: Node
var _gem: Control
var _gem_label: Label
var _bag: Label
var _gadget: Label
var _alarm: Label
var _gadgets: Gadgets
var _lead: Label
var _toasts: VBoxContainer
var _note: PanelContainer
var _note_title: Label
var _note_text: Label
var _capers: PanelContainer
var _capers_list: VBoxContainer
var _center: Label
## [position, radius, age, kind]
var _rings: Array = []
var _note_from := Vector3.ZERO


func _init() -> void:
	name = "JobHud"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("noise_watchers")
	_gem = Control.new()
	_gem.custom_minimum_size = Vector2(64, 64)
	_gem.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_gem.position += Vector2(-32, -96)
	_gem.draw.connect(_draw_gem)
	_gem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_gem)
	_gem_label = _label("", 16)
	_gem_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_gem_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_gem_label.position += Vector2(-80, -28)
	_gem_label.custom_minimum_size = Vector2(160, 0)
	add_child(_gem_label)
	_bag = _label("", 18)
	_bag.position = Vector2(24, 20)
	add_child(_bag)
	_gadget = _label("", 20)
	_gadget.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_gadget.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_gadget.custom_minimum_size = Vector2(420, 0)
	_gadget.position += Vector2(-444, -64)
	add_child(_gadget)
	_alarm = _label("ALARM", 30)
	_alarm.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_alarm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_alarm.custom_minimum_size = Vector2(300, 0)
	_alarm.position += Vector2(-150, 70)
	_alarm.add_theme_color_override("font_color", Color(1.0, 0.3, 0.25))
	_alarm.visible = false
	add_child(_alarm)
	_lead = _label("", 20)
	_lead.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_lead.position += Vector2(24, -64)
	_lead.add_theme_color_override("font_color", Color("ffd54a"))
	add_child(_lead)
	_toasts = VBoxContainer.new()
	_toasts.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_toasts.position += Vector2(-300, 24)
	_toasts.custom_minimum_size = Vector2(600, 0)
	_toasts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toasts)
	_center = _label("", 24)
	_center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_center.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_center.custom_minimum_size = Vector2(800, 0)
	_center.position += Vector2(-400, 80)
	add_child(_center)
	_note = PanelContainer.new()
	_note.visible = false
	_note.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color(0.96, 0.93, 0.82)
	paper.set_content_margin_all(28)
	paper.set_corner_radius_all(4)
	_note.add_theme_stylebox_override("panel", paper)
	var col := VBoxContainer.new()
	_note.add_child(col)
	_note_title = _label("", 24)
	_note_title.add_theme_color_override("font_color", Color(0.2, 0.15, 0.1))
	col.add_child(_note_title)
	_note_text = _label("", 20)
	_note_text.add_theme_color_override("font_color", Color(0.15, 0.12, 0.1))
	_note_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note_text.custom_minimum_size = Vector2(460, 0)
	col.add_child(_note_text)
	add_child(_note)
	_capers = PanelContainer.new()
	_capers.theme_type_variation = "DarkPanel"
	_capers.visible = false
	_capers.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_capers.position += Vector2(-520, -240)
	_capers_list = VBoxContainer.new()
	_capers.add_child(_capers_list)
	add_child(_capers)


func setup(p_run: JobRun, p_player: Node) -> void:
	run = p_run
	player = p_player
	run.caper_done.connect(_on_caper_done)
	run.lead_found.connect(_on_lead_found)
	run.lead_step.connect(_on_lead_step)
	player.bag_changed.connect(_update_bag)
	_update_bag()


func _process(delta: float) -> void:
	_gem.queue_redraw()
	if player:
		var v: float = player.visibility
		_gem_label.text = "Hidden" if v < 0.25 else ("Dim" if v < 0.5 else "Lit up")
		if _note.visible and player.global_position.distance_to(_note_from) > 1.5:
			_note.visible = false
	for r in _rings:
		r[2] += delta
	_rings = _rings.filter(_ring_alive)
	queue_redraw()


func _ring_alive(r: Array) -> bool:
	return r[2] < RING_TIME


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("capers"):
		_toggle_capers()


## A noise somewhere: draws a ring that grows and fades (if rings are on).
func on_noise(noise: StealthNoise) -> void:
	if not LGSettings.get_value("play", "noise_rings", true):
		return
	_rings.append([noise.position, noise.radius, 0.0, noise.kind])


## Shows a note; reading the same note again puts it away.
func show_note(title: String, text: String) -> void:
	if _note.visible and _note_title.text == title:
		_note.visible = false
		return
	_note_title.text = title
	_note_text.text = text
	_note.visible = true
	if player:
		_note_from = player.global_position
	_note.reset_size()
	_note.position = (size - _note.size) * 0.5


## A line in the middle of the screen, or "" to clear it.
func say(text: String) -> void:
	_center.text = text


func toast(text: String, color := Color.WHITE) -> void:
	var l := _label(text, 22)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_color", color)
	_toasts.add_child(l)
	var t := l.create_tween()
	t.tween_interval(TOAST_TIME)
	t.tween_property(l, "modulate:a", 0.0, 0.6)
	t.tween_callback(l.queue_free)


func _on_caper_done(caper: CaperDef) -> void:
	toast("Caper: " + caper.title, Color("ffd54a"))
	Sfx.at(player, "caper_done", player.global_position, -6.0)


func _on_lead_found(lead: LeadDef) -> void:
	if LGSettings.get_value("play", "leads", true):
		toast("New lead: " + lead.title, Color("9fd8ff"))


func _on_lead_step(lead: LeadDef, text: String) -> void:
	if not LGSettings.get_value("play", "leads", true):
		_lead.text = ""
		return
	_lead.text = ("Lead: " + text) if text != "" else ""
	if text != "" and player:
		Sfx.at(player, "lead_hint", player.global_position, -10.0)


## Shows the gadget in hand (and how many are left) from now on.
func watch_gadgets(g: Gadgets) -> void:
	_gadgets = g
	g.selected_changed.connect(_on_gadget_changed)
	_update_gadget()


func _on_gadget_changed(_g: String) -> void:
	_update_gadget()


func _update_gadget() -> void:
	if _gadgets == null or _gadgets.selected == "":
		_gadget.text = ""
		return
	var g := _gadgets.selected
	_gadget.text = "%s x%d" % [Gadgets.TITLES.get(g, g.capitalize()), int(player.bag.get(g, 0))]


func show_alarm(ringing: bool) -> void:
	_alarm.visible = ringing


func _update_bag() -> void:
	var names := []
	for item in player.bag:
		var n: int = player.bag[item]
		var title := String(item).capitalize()
		names.append(title if n == 1 else "%s x%d" % [title, n])
	_bag.text = ("Bag: " + ", ".join(names)) if not names.is_empty() else ""
	_update_gadget()


func _toggle_capers() -> void:
	_capers.visible = not _capers.visible
	if not _capers.visible or run == null:
		return
	for c in _capers_list.get_children():
		c.queue_free()
	_capers_list.add_child(_label("Capers", 22))
	for c in run.job.capers:
		var done := run.is_caper_done(c.id) or Progress.has_caper(run.job.id, c.id)
		var l := _label(("[x] " if done else "[ ] ") + c.title, 18)
		if run.is_caper_done(c.id):
			l.add_theme_color_override("font_color", Color("ffd54a"))
		_capers_list.add_child(l)


func _draw_gem() -> void:
	var v: float = player.visibility if player else 0.0
	var c := Color(0.08, 0.09, 0.12).lerp(Color(1.0, 0.85, 0.35), clampf(v * 1.4, 0.0, 1.0))
	var mid := _gem.size * 0.5
	_gem.draw_circle(mid, 26.0, Color(0, 0, 0, 0.6))
	_gem.draw_circle(mid, 20.0, c)
	_gem.draw_arc(mid, 26.0, 0, TAU, 40, Color(0.9, 0.9, 0.9, 0.5), 2.0)


func _draw() -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	for r in _rings:
		var pos: Vector3 = r[0]
		var t: float = r[2] / RING_TIME
		var on_screen := cam.unproject_position(pos)
		var behind := cam.is_position_behind(pos)
		var view := get_viewport_rect().size
		if behind or not Rect2(Vector2.ZERO, view).has_point(on_screen):
			# Pin it to the edge of the screen, towards the noise.
			var local := cam.global_transform.affine_inverse() * pos
			var dir := Vector2(local.x, -local.y if not behind else local.y).normalized()
			if behind:
				dir = Vector2(local.x, 0).normalized()
			on_screen = view * 0.5 + dir * (minf(view.x, view.y) * 0.45)
		var d: float = cam.global_position.distance_to(pos)
		var size_px := clampf(float(r[1]) / maxf(d, 1.0) * 120.0, 18.0, 220.0) * (0.4 + 0.6 * t)
		var col := Color(1, 1, 1, 0.55 * (1.0 - t))
		if r[3] in ["bark", "bell", "pry", "rattle"]:
			col = Color(1.0, 0.6, 0.3, 0.7 * (1.0 - t))
		draw_arc(on_screen, size_px, 0, TAU, 48, col, 3.0)


func _label(text: String, font_size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l
