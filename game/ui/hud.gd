class_name JobHud
extends Control
## The heads-up display during a job: the light gem (how lit you are), rings
## for noises, what's in your bag, what you can do with the thing you're
## looking at, the lead you're following, short messages, capers as you
## finish them, and notes you read. Prompts and messages are parchment cards
## in the game's own font (Cogito's own prompt and hint areas are hidden).

const RING_TIME := 0.9
const TOAST_TIME := 3.5
## Text sizes: prompts and messages are read at a glance, from a couch too.
const PROMPT_SIZE := 26
const TOAST_SIZE := 24
## Messages longer than this wrap.
const TOAST_WIDTH := 640.0
const KEY_SIZE := 44
## The brown edge of a parchment card, and its accent for plain messages.
const EDGE := Color("8a5a32")
## The same message again within this many seconds isn't shown twice.
const REPEAT_TIME := 1.5

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
var _center_card: PanelContainer
var _lead_card: PanelContainer
## The cards under the crosshair: what you can do with what you look at.
var _prompts: VBoxContainer
var _prompt_name: Label
var _pick_bar: ProgressBar
var _pic: PlayerInteractionComponent
var _prompt_nodes: Array = []
var _carrying: Node
var _last_toast := ""
var _last_toast_at := -10.0
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
	_gem_label = _label("", 20)
	_gem_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_gem_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_gem_label.position += Vector2(-80, -28)
	_gem_label.custom_minimum_size = Vector2(160, 0)
	add_child(_gem_label)
	_bag = _label("", 22)
	_bag.position = Vector2(24, 20)
	add_child(_bag)
	_gadget = _label("", 24)
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
	_lead_card = card(Color("6fb6e8"))
	_lead_card.visible = false
	_lead = ink_label("", 22)
	_lead.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lead.custom_minimum_size = Vector2(460, 0)
	_lead_card.add_child(_lead)
	var lead_box := _corner_box(Control.PRESET_BOTTOM_LEFT, Vector2(24, -96))
	lead_box.alignment = BoxContainer.ALIGNMENT_END
	lead_box.add_child(_lead_card)
	_toasts = VBoxContainer.new()
	# Top right, out of the way of the crosshair and of what people say.
	_toasts.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_toasts.position += Vector2(-24 - TOAST_WIDTH - 60, 20)
	_toasts.custom_minimum_size = Vector2(TOAST_WIDTH + 60, 0)
	_toasts.add_theme_constant_override("separation", 8)
	_toasts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toasts)
	_prompts = VBoxContainer.new()
	_prompts.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_prompts.position += Vector2(-360, 48)
	_prompts.custom_minimum_size = Vector2(720, 0)
	_prompts.add_theme_constant_override("separation", 8)
	_prompts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_prompts)
	_center_card = card(EDGE)
	_center_card.visible = false
	_center = ink_label("", TOAST_SIZE)
	_center.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_center_card.add_child(_center)
	var center_box := VBoxContainer.new()
	center_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center_box.position += Vector2(-400, 200)
	center_box.custom_minimum_size = Vector2(800, 0)
	center_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_box.add_child(_center_card)
	_center_card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(center_box)
	_note = PanelContainer.new()
	_note.visible = false
	_note.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_note.theme_type_variation = "ParchmentPanel"
	_note.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	_note.add_child(col)
	_note_title = Label.new()
	_note_title.theme_type_variation = "InkHeader"
	col.add_child(_note_title)
	_note_text = ink_label("", 24)
	_note_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note_text.custom_minimum_size = Vector2(600, 0)
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


## Shows what the player can do with whatever they look at, and the short
## messages (hints) the things they use send back, as Tiptoe's own cards.
func watch_prompts(pic: PlayerInteractionComponent) -> void:
	_pic = pic
	pic.interactive_object_detected.connect(_on_object_detected)
	pic.nothing_detected.connect(_on_nothing_detected)
	pic.started_carrying.connect(_on_started_carrying)
	pic.hint_prompt.connect(_on_hint)
	var router := get_node_or_null("/root/LGInput")
	if router:
		router.device_changed.connect(_on_device_changed)


func _on_object_detected(nodes: Array[Node]) -> void:
	_carrying = null
	_prompt_nodes = nodes
	_build_prompts()


func _on_nothing_detected() -> void:
	_carrying = null
	_prompt_nodes = []
	_build_prompts()


func _on_started_carrying(node: Node) -> void:
	_carrying = node
	_build_prompts()


func _on_device_changed(_family: String) -> void:
	_build_prompts()


func _on_hint(_icon: Texture2D, text: String) -> void:
	toast(text)


## The prompt cards showing now, as [action, text] pairs (for tests).
func prompt_lines() -> Array:
	var out := []
	for c in _prompts.get_children():
		if c.has_meta("action") and not c.is_queued_for_deletion():
			out.append([c.get_meta("action"), c.get_meta("text")])
	return out


func _build_prompts() -> void:
	for c in _prompts.get_children():
		_prompts.remove_child(c)
		c.queue_free()
	_pick_bar = null
	if _carrying != null and is_instance_valid(_carrying):
		_add_prompt(_carrying.input_map_action, "Drop it")
		return
	if _prompt_nodes.is_empty() or _pic == null:
		return
	var thing: Node = _prompt_nodes[0].get_parent()
	var title: String = thing.get("display_name") if thing.get("display_name") else ""
	if title != "":
		_prompt_name = _label(title, 24)
		_prompt_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_prompts.add_child(_prompt_name)
	for node in _prompt_nodes:
		if not is_instance_valid(node) or not node is InteractionComponent:
			continue
		var ic: InteractionComponent = node
		if ic.set_disabled(_pic.get_parent()) or ic.is_disabled or ic.interaction_text == "":
			continue
		if ic.attribute_check == 2 and not ic.check_attribute(_pic):
			continue
		_add_prompt(ic.input_map_action, tr(ic.interaction_text))
	if thing.has_method("pick_progress"):
		_pick_bar = ProgressBar.new()
		_pick_bar.show_percentage = false
		_pick_bar.custom_minimum_size = Vector2(320, 14)
		_pick_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_pick_bar.max_value = 1.0
		_pick_bar.visible = false
		_prompts.add_child(_pick_bar)


func _add_prompt(action: String, text: String) -> void:
	var c := card(EDGE)
	c.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	c.set_meta("action", action)
	c.set_meta("text", text)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(row)
	row.add_child(key_cap(action))
	var l := ink_label(text, PROMPT_SIZE)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(l)
	_prompts.add_child(c)


## The button for an action: the controller's button glyph when playing on
## a controller, else the key's name on a dark key cap (the white keyboard
## glyphs get lost on parchment).
static func key_cap(action: String) -> Control:
	var router: Node = Engine.get_main_loop().root.get_node_or_null("LGInput")
	var tex: Texture2D = router.glyph_for_action(action) if router and router.is_gamepad() else null
	if tex:
		var icon := TextureRect.new()
		icon.texture = tex
		icon.custom_minimum_size = Vector2(KEY_SIZE, KEY_SIZE)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return icon
	var cap := PanelContainer.new()
	var box := StyleBoxFlat.new()
	box.bg_color = LGTheme.INK
	box.set_corner_radius_all(8)
	box.set_content_margin_all(6)
	box.content_margin_left = 12
	box.content_margin_right = 12
	cap.add_theme_stylebox_override("panel", box)
	cap.custom_minimum_size = Vector2(KEY_SIZE, KEY_SIZE)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := Label.new()
	l.text = router.label_for_action(action) if router else action
	l.add_theme_font_override("font", LGTheme.heading_font)
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", LGTheme.PARCHMENT)
	l.add_theme_constant_override("outline_size", 0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cap.add_child(l)
	return cap


## A parchment card with a coloured edge on its left, like the game's menus.
static func card(accent: Color) -> PanelContainer:
	var c := PanelContainer.new()
	var box := StyleBoxFlat.new()
	box.bg_color = Color(LGTheme.PARCHMENT, 0.96)
	box.border_color = EDGE if accent == EDGE else accent.darkened(0.25)
	box.set_border_width_all(3)
	box.border_width_left = 10
	box.set_corner_radius_all(10)
	box.content_margin_left = 20
	box.content_margin_right = 20
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	box.shadow_color = Color(0, 0, 0, 0.4)
	box.shadow_size = 6
	c.add_theme_stylebox_override("panel", box)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


## Dark ink text for a parchment card.
static func ink_label(text: String, font_size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = "InkLabel"
	l.add_theme_font_size_override("font_size", font_size)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _corner_box(preset: Control.LayoutPreset, offset: Vector2) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(preset)
	box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	box.position += offset
	box.custom_minimum_size = Vector2(520, 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	return box


func _process(delta: float) -> void:
	_gem.queue_redraw()
	if _pic:
		var busy: bool = player.is_showing_ui or get_tree().paused
		_prompts.visible = not busy
		if _pick_bar and is_instance_valid(_pick_bar) and _pic.interactable and _pic.interactable.has_method("pick_progress"):
			var t: float = _pic.interactable.pick_progress()
			_pick_bar.visible = t > 0.0
			_pick_bar.value = t
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
	_center_card.visible = text != ""


## A short message card at the top of the screen that fades after a while.
## `color` is its edge: gold for capers, blue for leads, red for trouble.
func toast(text: String, color := EDGE) -> void:
	if text == "":
		return
	var now := Time.get_ticks_msec() / 1000.0
	if text == _last_toast and now - _last_toast_at < REPEAT_TIME:
		return
	_last_toast = text
	_last_toast_at = now
	var c := card(EDGE if color == Color.WHITE else color)
	c.size_flags_horizontal = Control.SIZE_SHRINK_END
	var l := ink_label(text, TOAST_SIZE)
	var font: Font = LGTheme.body_font
	if font and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, TOAST_SIZE).x > TOAST_WIDTH:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(TOAST_WIDTH, 0)
	c.add_child(l)
	_toasts.add_child(c)
	while _toasts.get_child_count() > 4:
		_toasts.get_child(0).queue_free()
		_toasts.remove_child(_toasts.get_child(0))
	var t := c.create_tween()
	t.tween_interval(TOAST_TIME)
	t.tween_property(c, "modulate:a", 0.0, 0.6)
	t.tween_callback(c.queue_free)


## The message cards showing now (for tests).
func toast_lines() -> PackedStringArray:
	var out := PackedStringArray()
	for c in _toasts.get_children():
		if not c.is_queued_for_deletion():
			out.append((c.get_child(0) as Label).text)
	return out


func _on_caper_done(caper: CaperDef) -> void:
	toast("Caper: " + caper.title, Color("ffd54a"))
	Sfx.at(player, "caper_done", player.global_position, -6.0)


func _on_lead_found(lead: LeadDef) -> void:
	if LGSettings.get_value("play", "leads", true):
		toast("New lead: " + lead.title, Color("9fd8ff"))


func _on_lead_step(lead: LeadDef, text: String) -> void:
	if not LGSettings.get_value("play", "leads", true):
		_lead.text = ""
		_lead_card.visible = false
		return
	_lead.text = ("Lead: " + text) if text != "" else ""
	_lead_card.visible = text != ""
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
	_capers_list.add_child(_label("Capers", 28))
	for c in run.job.capers:
		var done := run.is_caper_done(c.id) or Progress.has_caper(run.job.id, c.id)
		var l := _label(("[x] " if done else "[ ] ") + c.title, 22)
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
		var behind := cam.is_position_behind(pos)
		var on_screen := Vector2(-1, -1) if behind else cam.unproject_position(pos)
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
