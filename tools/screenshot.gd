extends Node
## Takes screenshots, for checking how the game looks without a screen. Run
## with a display (xvfb-run on a server) and --resolution 1280x720:
##   godot --path . --resolution 1280x720 tools/screenshot.tscn -- --out=/tmp/shots [--job=maple_close] [--view=name] [--at=x,y,z,yaw,pitch]
## saves a job's views as PNGs. A view is a player position, a facing and a
## look pitch: the level's own ([method JobLevel.screenshot_views]), one at
## each start point and one of each person.
## Or every job and the menus, as JPEGs in <dir>/<job>/<view>.jpg and
## <dir>/menus/<menu>.jpg, plus a README.md listing them:
##   godot --path . --resolution 1280x720 tools/screenshot.tscn -- --all=docs/screenshots [--job=market]
## (or only the README: --index=docs/screenshots). Progress stays in memory,
## so the player's own is never touched.

const JOB_SCENE := preload("res://game/jobs/job.tscn")
const TITLE_SCENE := preload("res://game/ui/title.tscn")
## Seconds of the night before the shots, for the people to get to their places.
const SETTLE := 20.0
## The player's eyes above their feet.
const EYE := 1.6
## How far the camera may rise to see someone over a crowd.
const LIFT := 0.6
## Where to stand to see someone: degrees off the way they face, best first,
## in front (from higher up before giving up on it), then to the side.
const AROUND := [[0.0, 25.0, -25.0, 50.0, -50.0], [75.0, -75.0, 100.0, -100.0, 130.0, -130.0, 180.0]]
## The menus, in the order the README lists them: [file, caption].
const MENUS := [
	["title", "The title, on the first night"],
	["board", "The job board, on the first night"],
	["job", "A job's briefing"],
	["settings", "Settings"],
	["about", "About Tiptoe"],
	["title_home", "The title, with every treasure home"],
	["board_home", "The job board, with every treasure home"],
	["note", "Reading a note"],
	["capers", "The capers list"],
	["keypad", "A keypad up close"],
	["pause", "Paused"],
	["results", "How the night went"],
]

var _job: Job
## Where the player's neck sits, before any lift.
var _neck_y := NAN


func _ready() -> void:
	var out := "/tmp/shots"
	var all := ""
	var index := ""
	var job_id := ""
	var only := ""
	var spot := []
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.trim_prefix("--out=")
		elif a.begins_with("--all="):
			all = a.trim_prefix("--all=")
		elif a.begins_with("--index="):
			index = a.trim_prefix("--index=")
		elif a.begins_with("--job="):
			job_id = a.trim_prefix("--job=")
		elif a.begins_with("--view="):
			only = a.trim_prefix("--view=")
		elif a.begins_with("--at="):
			spot = Array(a.trim_prefix("--at=").split_floats(","))
	LGSettings.register_defaults(GameConfig.SETTING_DEFAULTS)
	LGSettings.set_value("video", "fullscreen", false, false)
	LGInput.register_actions(GameConfig.ACTIONS)
	LGTheme.apply(get_tree().root, 22)
	Progress.in_memory = true
	Progress.load_progress()
	if index != "":
		_write_index(_root(index))
	elif all != "":
		await _all(_root(all), job_id)
	else:
		await _job_views(out, job_id if job_id != "" else "maple_close", only, spot)
	get_tree().quit()


## One job's views as PNGs in `out` (only those starting with `only`, or one
## spot [x, y, z, yaw, pitch]).
func _job_views(out: String, job_id: String, only: String, spot: Array) -> void:
	DirAccess.make_dir_recursive_absolute(out)
	var views := await _open_job(job_id)
	if spot.size() == 5:
		views = {"at": [Vector3(spot[0], spot[1], spot[2]), spot[3], spot[4]]}
		only = "at"
	for v in views:
		if only != "" and not v.begins_with(only):
			continue
		await _stand(views[v])
		_image().save_png("%s/%s.png" % [out, v])
		print("saved ", v)


## Every job (or one) and the menus, as JPEGs under `root`, and the README.
func _all(root: String, only_job: String) -> void:
	for id in Jobs.ids():
		if only_job != "" and id != only_job:
			continue
		var job := Jobs.get_job(id)
		if job == null:
			continue
		DirAccess.make_dir_recursive_absolute(root.path_join(id))
		var views := await _open_job(id)
		for v in views:
			await _stand(views[v])
			await _save(root.path_join(id).path_join(v + ".jpg"))
		# The menus that show over a night: Maple Close's, and the bottling
		# plant's staff door keypad.
		if id == "maple_close" or id == "bottling":
			DirAccess.make_dir_recursive_absolute(root.path_join("menus"))
			await _night_menus(root.path_join("menus"), id)
	if only_job == "":
		DirAccess.make_dir_recursive_absolute(root.path_join("menus"))
		await _title_menus(root.path_join("menus"))
	_close_job()
	_write_index(root)


## Starts a night of a job, lets the people settle, then holds it still and
## returns its views: the level's own, the start points and the people.
func _open_job(id: String) -> Dictionary:
	_close_job()
	_job = JOB_SCENE.instantiate()
	_job.job = Jobs.get_job(id)
	add_child(_job)
	await _job.level.navigation_ready
	# Let the people get to their places, quickly and without drawing.
	RenderingServer.render_loop_enabled = false
	Engine.time_scale = 8.0
	await get_tree().create_timer(SETTLE, true, true).timeout
	Engine.time_scale = 1.0
	RenderingServer.render_loop_enabled = true
	# Hold the night still: nobody moves or notices the player hopping between
	# views, nothing raises the alarm, and nothing the player passes counts.
	for p in _job.people:
		p.process_mode = Node.PROCESS_MODE_DISABLED
	_job.run.running = false
	_job.level.alarm_armed = false
	_job.level.set_physics_process(false)
	var views: Dictionary = _job.level.screenshot_views()
	for s in _job.job.start_points:
		var t: Transform3D = _job.level.start_transform(s.id)
		views["start_" + s.id] = [t.origin - Vector3(0, 0.9, 0), rad_to_deg(t.basis.get_euler().y), 0.0]
	for p in _job.people:
		views["who_" + _file_name(p.name)] = _facing(p)
	return views


func _close_job() -> void:
	if _job:
		get_tree().paused = false
		_job.free()
		_job = null


## A view of someone from a couple of metres away: from in front if there's
## room to stand and nobody in the way, else from a little higher up (over a
## crowd's heads), else from the side or behind, else wherever the fewest
## people are in the way. The view's fourth item is who it's of, so
## only they speak, and its fifth how far the camera is lifted.
func _facing(p: Node3D) -> Array:
	var dog := p is Dog
	var front: Vector3 = p.rig.global_basis.z
	front.y = 0.0
	front = front.normalized()
	var head := _head(p)
	var space := _job.get_world_3d().direct_space_state
	var fallback := []
	var best := []
	var fewest := 1000
	for angles in AROUND:
		for lift in ([0.0] if dog else [0.0, LIFT]):
			for d in ([2.0, 1.5] if dog else [2.6, 2.0]):
				for a in angles:
					var dir := front.rotated(Vector3.UP, deg_to_rad(a))
					var at: Vector3 = p.global_position + dir * d
					var ground := _ground(space, at, p.global_position.y)
					if ground.is_finite():
						at = ground
					var eye := at + Vector3(0, EYE + lift, 0)
					var q := PhysicsRayQueryParameters3D.create(head, eye, Kit.LAYER_SOLID | Kit.LAYER_GLASS | Kit.LAYER_INTERACT)
					if not space.intersect_ray(q).is_empty():
						continue
					# Down at their face, keeping room above it for what they say.
					var pitch := -28.0 if dog else minf(-12.0, 5.0 - rad_to_deg(atan2(eye.y - head.y, d)))
					var view := [at, rad_to_deg(atan2(dir.x, dir.z)), pitch, p, lift]
					if fallback.is_empty():
						fallback = view
					if not ground.is_finite():
						continue
					var n := _in_the_way(p, head, eye)
					if n == 0:
						return view
					if n < fewest and lift == 0.0:
						fewest = n
						best = view
	return best if not best.is_empty() else fallback


## Whether someone is sitting or lying down (their head is lower).
func _seated(who: Node3D) -> bool:
	var clip: String = who.rig.current_clip()
	return clip.begins_with("sit") or clip == "sleep"


## Roughly where someone's head is.
func _head(who: Node3D) -> Vector3:
	var up := 0.5 if who is Dog else (0.95 if _seated(who) else 1.4)
	return who.global_position + Vector3(0, who.rig.position.y + up, 0)


## The floor where the player would stand near `at`, if they fit there: no
## higher than a step above `floor_y` (not a bench or a table), and nothing
## solid in the way. Vector3.INF if not.
func _ground(space: PhysicsDirectSpaceState3D, at: Vector3, floor_y: float) -> Vector3:
	var down := PhysicsRayQueryParameters3D.create(Vector3(at.x, floor_y + 2.0, at.z), Vector3(at.x, floor_y - 1.0, at.z), Kit.LAYER_SOLID)
	var hit := space.intersect_ray(down)
	if hit.is_empty() or hit.position.y > floor_y + 0.3:
		return Vector3.INF
	var shape := CapsuleShape3D.new()
	shape.radius = 0.35
	shape.height = 1.5
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = shape
	q.collision_mask = Kit.LAYER_SOLID | Kit.LAYER_GLASS | Kit.LAYER_INTERACT
	q.transform = Transform3D(Basis.IDENTITY, hit.position + Vector3(0, 0.95, 0))
	return hit.position if space.intersect_shape(q, 1).is_empty() else Vector3.INF


## How many people but `who` are in the way from the eye to their face (a
## seated head that looks lower than their chin doesn't count), or a lot if
## someone is where the player would stand.
func _in_the_way(who: Node3D, head: Vector3, eye: Vector3) -> int:
	var a := Vector2(head.x, head.z)
	var b := Vector2(eye.x, eye.z)
	var chin := (eye.y - head.y + 0.3) / maxf(a.distance_to(b), 0.01)
	var n := 0
	for other in _job.people:
		if other == who:
			continue
		var o := Vector2(other.global_position.x, other.global_position.z)
		if o.distance_to(b) < 0.6:
			n += 10
			continue
		var near := Geometry2D.get_closest_point_to_segment(o, a, b)
		var t := a.distance_to(near) / maxf(a.distance_to(b), 0.01)
		# Near the camera, someone just off the line still fills the picture.
		if near.distance_to(o) >= lerpf(0.6, 0.9, t):
			continue
		# How far below the eye the top of their head looks, against the chin.
		var top := (eye.y - _head(other).y - 0.4) / maxf(o.distance_to(b), 0.01)
		if top < chin:
			n += 1
	return n


## Puts the player at a view and gives the picture a moment to settle.
func _stand(view: Array) -> void:
	var p := _job.player
	p.global_position = view[0] + Vector3(0, 0.9, 0)
	p.velocity = Vector3.ZERO
	p.rotation.y = 0.0
	p.body.rotation.y = deg_to_rad(view[1])
	p.head.rotation.x = deg_to_rad(view[2])
	if is_nan(_neck_y):
		_neck_y = p.neck.position.y
	p.neck.position.y = _neck_y + (view[4] if view.size() > 4 else 0.0)
	p.reset_physics_interpolation()
	_job.hud.clear_messages()
	# A use prompt would cover the face in a picture of someone.
	_job.hud._prompts.modulate.a = 1.0 if view.size() < 4 else 0.0
	for who in _job.people:
		if who is Person:
			who.hush()
	await _frames(12)
	# Who the view is of, or else whoever's nearest, says the first thing
	# their routine has them say.
	var speaker: Node = view[3] if view.size() > 3 else null
	if speaker == null:
		var near := 3.0
		for who in _job.people:
			if who is Person and who.global_position.distance_to(view[0]) < near:
				near = who.global_position.distance_to(view[0])
				speaker = who
	if speaker is Person:
		speaker.show_line(speaker.first_line())
	await _frames(2)


## The menus over a night: notes, capers, the pause menu and the results in
## Maple Close, and a keypad at the bottling plant.
func _night_menus(dir: String, id: String) -> void:
	var views: Dictionary = _job.level.screenshot_views()
	if id == "bottling":
		await _stand(views["staff_door"])
		_job.keypad_panel.open_for(null, _job.player)
		_job.keypad_panel._show("19")
		await _frames(4)
		await _save(dir.path_join("keypad.jpg"))
		_job.keypad_panel.close()
		return
	await _stand(views["kitchen"])
	var note := _job.level.get_node("Note_shopping_list") as UsableBody
	note.action("interact").interact(_job.player.player_interaction_component)
	await _frames(4)
	await _save(dir.path_join("note.jpg"))
	await _stand(views["living"])
	_job.hud._toggle_capers()
	await _frames(4)
	await _save(dir.path_join("capers.jpg"))
	await _stand(views["hall"])
	_job.pause.open_pause_menu()
	await _frames(4)
	await _save(dir.path_join("pause.jpg"))
	_job.pause.close_pause_menu()
	await _stand(views["street"])
	var capers: Array = _job.job.capers.slice(0, 3).map(func(c: CaperDef) -> String: return c.id)
	var result := {"treasure": true, "escaped": true, "time": 287.0, "spotted": 1, "caught": 0,
		"ratings": ["Tidy", "Quick"], "score": 2450, "capers": capers}
	_job.results.show_result(_job.job, result, {"capers": capers.slice(1), "mastery_from": 0, "mastery_to": 1})
	await _frames(4)
	await _save(dir.path_join("results.jpg"))
	_job.results.visible = false


## The title screen and its menus, first with nothing home, then with every
## treasure on the shelf.
func _title_menus(dir: String) -> void:
	_close_job()
	for home in [false, true]:
		if home:
			for id in Jobs.ids():
				var job := Jobs.get_job(id)
				var capers: Array = job.capers.map(func(c: CaperDef) -> String: return c.id)
				Progress.record_run(id, {"treasure": true, "escaped": true, "time": job.par_time * 0.8, "score": 3000, "capers": capers.slice(0, 6)})
		var title: Node = TITLE_SCENE.instantiate()
		add_child(title)
		var shots := ["title_home", "board_home"] if home else ["title", "board", "job", "settings", "about"]
		for shot in shots:
			match shot:
				"board", "board_home":
					title._show_board()
				"job":
					title._show_job("maple_close")
				"settings":
					title._show_settings()
				"about":
					title._show_about()
			await _frames(12)
			await _save(dir.path_join(shot + ".jpg"))
			title._show_main()
		title.free()


## A README.md beside the screenshots listing every job's and the menus,
## from the images that are there.
func _write_index(root: String) -> void:
	var lines := ["# Screenshots", "",
		"Every job in Tiptoe (the places, the start points and the people) and the menus, made with:", "",
		"    xvfb-run -a -s \"-screen 0 1280x720x24\" godot --path . --resolution 1280x720 tools/screenshot.tscn -- --all=docs/screenshots", "",
		"or one job with `--job=market` (that job's folder, and the menus if it shows any).", ""]
	for id in Jobs.ids():
		var job := Jobs.get_job(id)
		var files := DirAccess.get_files_at(root.path_join(id))
		if job == null or files.is_empty():
			continue
		lines.append("## %d. %s, %s" % [Jobs.ids().find(id) + 1, job.title, job.place])
		lines.append("")
		lines.append("The treasure: %s." % job.treasure)
		lines.append("")
		var level: JobLevel = load(job.scene).new()
		var places := []
		for v in level.screenshot_views():
			if files.has(v + ".jpg"):
				places.append([v + ".jpg", v.capitalize()])
		level.free()
		var starts := []
		for s in job.start_points:
			if files.has("start_%s.jpg" % s.id):
				starts.append(["start_%s.jpg" % s.id, s.title])
		var people := []
		for f in files:
			if f.begins_with("who_") and f.ends_with(".jpg"):
				people.append([f, f.trim_prefix("who_").trim_suffix(".jpg").capitalize()])
		for group in [["Around the job", places], ["Start points", starts], ["The people", people]]:
			if group[1].is_empty():
				continue
			lines.append("### " + group[0])
			lines.append("")
			lines.append_array(_grid(id, group[1]))
	var menus := []
	for m in MENUS:
		if FileAccess.file_exists(root.path_join("menus").path_join(m[0] + ".jpg")):
			menus.append([m[0] + ".jpg", m[1]])
	if not menus.is_empty():
		lines.append("## Menus")
		lines.append("")
		lines.append_array(_grid("menus", menus))
	var out := FileAccess.open(root.path_join("README.md"), FileAccess.WRITE)
	if out:
		out.store_string("\n".join(lines))


## Images two to a row, each with its caption: [[file, caption]].
func _grid(dir: String, shots: Array) -> Array:
	var lines := ["| | |", "|---|---|"]
	for i in range(0, shots.size(), 2):
		var cells := []
		for s in shots.slice(i, i + 2):
			cells.append("![%s](%s/%s)<br>%s" % [s[1], dir, s[0], s[1]])
		if cells.size() == 1:
			cells.append("")
		lines.append("| %s | %s |" % cells)
	lines.append("")
	return lines


func _file_name(s: String) -> String:
	return s.to_lower().replace(" ", "_").validate_filename()


func _root(dir: String) -> String:
	return dir if dir.begins_with("/") else ProjectSettings.globalize_path("res://").path_join(dir)


func _image() -> Image:
	return get_viewport().get_texture().get_image()


func _save(path: String) -> void:
	await RenderingServer.frame_post_draw
	_image().save_jpg(path, 0.85)
	print("Saved ", path)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame
