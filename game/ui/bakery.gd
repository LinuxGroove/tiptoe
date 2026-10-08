class_name Bakery
extends Node3D
## Ottoline's bakery at night, behind the title menu: the counter, the bread,
## and the window shelf where every treasure the Moth brings home goes on show.
## Each job has a place on the shelf, empty with its name until its treasure
## is back. X runs along the shelf, the camera looks north (-Z).

const WOOD := Color(0.5, 0.36, 0.24)
const PLASTER := Color(0.86, 0.78, 0.64)
const SHELF := Color(0.42, 0.28, 0.18)
## How far apart the treasures stand on the shelves.
const SPACING := 0.6
## The heights of the window sill and the shelf above it.
const ROWS := [0.94, 1.55]
## The tallest a treasure stands, so a rocket and a cog sit side by side.
const TREASURE_HEIGHT := 0.42

## job id -> the Node3D on the shelf showing its treasure (absent when empty).
var shown := {}
var camera: Camera3D


func _ready() -> void:
	_build_room()
	_build_shelf()
	camera = Camera3D.new()
	camera.fov = 55.0
	add_child(camera)
	# The menu covers the right of the screen, so look past the window to
	# its right and leave the shelf on the left.
	camera.look_at_from_position(Vector3(0.9, 1.45, 4.6), Vector3(2.35, 1.2, -0.75))
	camera.make_current()


func _build_room() -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.03, 0.04, 0.09)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.35, 0.38, 0.55)
	env.environment.ambient_light_energy = 0.3
	env.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	add_child(env)
	var plaster := Kit.flat(PLASTER)
	Kit.block(self, Vector3(0, -0.05, 1), Vector3(12, 0.1, 8), "", Kit.flat(WOOD), false)
	# The shop front: a wall with a wide window onto the street at night.
	Kit.block(self, Vector3(0, 0.45, -1.0), Vector3(12, 0.9, 0.2), "", plaster, false)
	Kit.block(self, Vector3(0, 2.75, -1.0), Vector3(12, 0.9, 0.2), "", plaster, false)
	Kit.block(self, Vector3(-3.8, 1.6, -1.0), Vector3(4.4, 1.4, 0.2), "", plaster, false)
	Kit.block(self, Vector3(3.8, 1.6, -1.0), Vector3(4.4, 1.4, 0.2), "", plaster, false)
	Kit.block(self, Vector3(0, 0.1, -6), Vector3(12, 0.2, 8), "", Kit.flat(Color(0.2, 0.2, 0.22)), false)
	var street := OmniLight3D.new()
	street.position = Vector3(-0.8, 3.0, -4.5)
	street.light_color = Color(0.55, 0.65, 1.0)
	street.light_energy = 1.5
	street.omni_range = 8.0
	add_child(street)
	Kit.model(self, Kit.SUBURBAN + "tree-large.glb", Vector3(-1.2, 0.2, -6.5), 20.0, 1.0)
	Kit.model(self, Kit.SUBURBAN + "tree-small.glb", Vector3(1.6, 0.2, -5.5), 80.0, 1.0)
	# The counter with the day's last bread and cakes, under a warm lamp.
	for i in 3:
		Kit.furniture(self, "kitchenBar", Vector3(2.4 + i * 1.0, 0, 1.0), 180.0, false)
	Kit.model(self, Kit.FOOD + "bread.glb", Vector3(2.3, 1.05, 1.0), 30.0, 1.4)
	Kit.model(self, Kit.FOOD + "bread.glb", Vector3(2.65, 1.05, 0.9), -10.0, 1.4)
	Kit.model(self, Kit.FOOD + "cake.glb", Vector3(3.3, 1.05, 1.0), 0.0, 1.2)
	Kit.model(self, Kit.FOOD + "cupcake.glb", Vector3(3.8, 1.05, 0.9), 0.0, 1.4)
	Kit.furniture(self, "kitchenCabinetUpperDouble", Vector3(-2.6, 1.6, -0.75), 0.0, false)
	Kit.furniture(self, "kitchenCabinet", Vector3(-2.6, 0, -0.6), 0.0, false)
	Kit.model(self, Kit.FOOD + "bread.glb", Vector3(-2.7, 0.95, -0.6), 70.0, 1.4)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(1.2, 2.4, 1.6)
	lamp.light_color = Color(1.0, 0.8, 0.55)
	lamp.light_energy = 0.9
	lamp.omni_range = 5.0
	lamp.shadow_enabled = true
	add_child(lamp)


func _build_shelf() -> void:
	var jobs := Jobs.all()
	var per_row := ceili(jobs.size() / 2.0)
	var width := SPACING * per_row + 0.2
	# The window display: the sill and a shelf above it, lit from above like
	# a shop window.
	for y in ROWS:
		Kit.block(self, Vector3(0, y - 0.06, -0.75), Vector3(width, 0.12, 0.45), "", Kit.flat(SHELF), false)
	var glow := SpotLight3D.new()
	glow.position = Vector3(0, 2.25, -0.2)
	glow.rotation_degrees = Vector3(-80, 0, 0)
	glow.spot_angle = 45.0
	glow.spot_range = 4.0
	glow.light_color = Color(1.0, 0.86, 0.6)
	glow.light_energy = 2.2
	add_child(glow)
	for i in jobs.size():
		var job: JobDef = jobs[i]
		var row := i / per_row
		var in_row := mini(per_row, jobs.size() - row * per_row)
		var col := i % per_row
		var at := Vector3((col - (in_row - 1) * 0.5) * SPACING, ROWS[row], -0.8)
		var home := Progress.treasures(job.id) > 0
		var tag := Label3D.new()
		tag.text = job.title
		tag.font_size = 48
		tag.outline_size = 6
		tag.pixel_size = 0.0011
		tag.width = SPACING * 0.95 / tag.pixel_size
		tag.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tag.position = Vector3(at.x, at.y - 0.06, -0.75 + 0.23)
		tag.modulate = Color(1, 0.95, 0.8) if home else Color(0.65, 0.65, 0.75, 0.6)
		add_child(tag)
		if home and job.treasure_model != "":
			shown[job.id] = _place_treasure(job.treasure_model, at)


## Puts a treasure on the shelf, scaled to stand at most TREASURE_HEIGHT tall.
func _place_treasure(path: String, at: Vector3) -> Node3D:
	var holder := Node3D.new()
	holder.position = at
	holder.rotation.y = deg_to_rad(-15.0)
	add_child(holder)
	var n: Node3D = Kit.scene(path).instantiate()
	holder.add_child(n)
	var box := Kit.aabb_of(n)
	var s := 1.0
	if box.size.y > 0.0:
		s = minf(TREASURE_HEIGHT / box.size.y, (SPACING * 0.85) / maxf(box.size.x, box.size.z))
	n.scale = Vector3.ONE * s
	var c := box.get_center() * s
	n.position = Vector3(-c.x, -box.position.y * s, -c.z)
	return holder
