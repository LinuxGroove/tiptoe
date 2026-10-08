class_name Job
extends Node3D
## One night of a job: builds the level, the night sky and the player, runs
## the [JobRun] and shows how it went. [method Jobs.play] sets `job` and
## `start_id` before this enters the tree.

const MOTH := preload("res://game/player/moth.tscn")
const SKY := "res://assets/kenney/skyboxes/skybox-night.png"
const MUSIC := "res://assets/kenney/audio/music/mishief_stroll.ogg"
## How long the chase music keeps going after the last chase ends.
const CHASE_HOLD := 4.0
## How many of each gadget the bag starts with (a gadget's own "count" in
## the job's data wins).
const GADGET_COUNTS := {"treats": 3, "darts": 6, "snooze_darts": 2, "noisemaker": 2}

var job: JobDef
var start_id := ""
var run: JobRun
var level: JobLevel
var player: Moth
var hud: JobHud
var pause: TiptoePause
var results: ResultsPanel
var keypad_panel: KeypadPanel
var people: Array = []
var gadgets: Gadgets
var _last_exit := "door"
var _fade: ColorRect
var _chase_music := false
var _calm_t := 0.0


func _ready() -> void:
	if job == null:
		job = Jobs.get_job("maple_close")
	if start_id == "":
		start_id = job.start_points[0].id
	run = JobRun.new()
	run.name = "Run"
	add_child(run)
	run.setup(job, start_id, bool(LGSettings.get_value("play", "leads", true)))
	_build_night()
	level = load(job.scene).new()
	level.name = "Level"
	level.build()
	add_child(level)
	var ui := CanvasLayer.new()
	ui.name = "UI"
	add_child(ui)
	hud = JobHud.new()
	ui.add_child(hud)
	pause = TiptoePause.new()
	ui.add_child(pause)
	keypad_panel = KeypadPanel.new()
	ui.add_child(keypad_panel)
	results = ResultsPanel.new()
	ui.add_child(results)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_fade)
	player = MOTH.instantiate()
	player.tiptoe_pause = pause
	add_child(player)
	player.global_transform = level.start_transform(start_id)
	player.light_probe.indoors_test = level.indoors
	var mastery := Progress.mastery(job.id)
	for g in job.open_gadgets(mastery):
		player.add_item(g.id, g.get("count", GADGET_COUNTS.get(g.id, 1)))
	hud.setup(run, player)
	hud.watch_prompts(player.player_interaction_component)
	gadgets = Gadgets.new()
	gadgets.player = player
	add_child(gadgets)
	hud.watch_gadgets(gadgets)
	people = level.add_people(run)
	for p in people:
		if p is Person:
			p.caught_player.connect(_on_caught)
	level.note_opened.connect(hud.show_note)
	level.entered_house.connect(_on_entered_house)
	level.left_house.connect(_on_left_house)
	level.entered_area.connect(_on_entered_area)
	level.at_way_out.connect(_on_way_out)
	level.alarm_changed.connect(hud.show_alarm)
	pause.give_up.connect(_on_give_up)
	pause.quit_to_title.connect(_on_quit)
	run.finished.connect(_on_finished)
	results.again.connect(_on_again)
	results.board.connect(_on_quit)
	level.bake_navigation()
	LGAudio.play_music(_night_music(), -14.0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	if not run.running:
		return
	var chased := false
	for p in people:
		if p is Person and p.state == Person.State.CHASE:
			chased = true
	_calm_t = 0.0 if chased else _calm_t + delta
	if chased and not _chase_music:
		_chase_music = true
		LGAudio.play_music(Sfx.music("chase", MUSIC), -12.0)
	elif _chase_music and _calm_t > CHASE_HOLD:
		_chase_music = false
		LGAudio.play_music(_night_music(), -14.0)


## The job's own night music, else the shared night loop, else Kenney's.
func _night_music() -> String:
	return Sfx.music(job.music, Sfx.music("night", MUSIC)) if job.music != "" else Sfx.music("night", MUSIC)


func _build_night() -> void:
	var env := Environment.new()
	var sky := Sky.new()
	var mat := PanoramaSkyMaterial.new()
	mat.panorama = load(SKY)
	mat.energy_multiplier = 0.6
	sky.sky_material = mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.32, 0.38, 0.55)
	env.ambient_light_energy = 0.35
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.1
	env.fog_enabled = true
	env.fog_light_color = Color(0.08, 0.1, 0.16)
	env.fog_density = 0.012
	env.ssao_enabled = true
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var moon := DirectionalLight3D.new()
	moon.name = "Moon"
	moon.light_color = Color(0.6, 0.7, 1.0)
	moon.light_energy = 0.35
	moon.shadow_enabled = true
	moon.rotation_degrees = Vector3(-38, 30, 0)
	add_child(moon)


func _on_entered_house(by: String) -> void:
	run.record("entered_house")
	if by != "":
		run.record("entered_by:" + by)


func _on_left_house(kind: String) -> void:
	_last_exit = kind


func _on_entered_area(area: String) -> void:
	run.record("entered_" + area)


func _on_way_out(_id: String) -> void:
	if not run.running:
		return
	if player.has_item(job.treasure_item):
		run.has_treasure = true
		run.escape(_last_exit)
	elif run.has("entered_house"):
		hud.toast("Come back here with the treasure to get away.")


## Caught: marched back out to where the player came in, without the trophy.
func _on_caught(_by: Person) -> void:
	if not run.running:
		return
	run.add_caught()
	player.is_movement_paused = true
	var t := create_tween()
	t.tween_property(_fade, "color:a", 1.0, 0.5)
	await t.finished
	if player.hiding != null:
		player.leave_hiding()
	keypad_panel.close()
	if player.take_item(job.treasure_item):
		run.drop_treasure()
		level.return_treasure()
	player.global_transform = level.start_transform(start_id)
	player.velocity = Vector3.ZERO
	player.is_movement_paused = false
	hud.toast("Caught! Marched back outside.", Color(1.0, 0.5, 0.4))
	var back := create_tween()
	back.tween_property(_fade, "color:a", 0.0, 0.6)


func _on_give_up() -> void:
	run.finish()


func _on_finished(result: Dictionary) -> void:
	var unlocked := Progress.record_run(job.id, result)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.is_movement_paused = true
	results.show_result(job, result, unlocked)
	LGAudio.play_music(Sfx.music("escaped" if result.get("escaped", false) else "night_over", MUSIC), -10.0, false)


func _on_again() -> void:
	Jobs.play(job.id, start_id)


func _on_quit() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	LGScenes.change_scene("res://game/ui/title.tscn")
