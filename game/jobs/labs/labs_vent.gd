class_name LabsVent
extends UsableBody
## An air vent at floor level, big enough to crawl through crouched, with a
## cover to unscrew first. In a wall it's a Building Kit doorway filled in
## above crouch height, with the wall vent model on the room side; on the
## roof it's a hatch over a shaft. Crawling through records "vent:<id>".

const MODEL := "res://assets/models/props/wall_vent.glb"
## The opening: wide and tall enough for a crouching player (0.6 x 0.7).
const WIDE := 0.9
const HIGH := 0.9
const WALL_COLOR := Color(0.8, 0.79, 0.88)

var id := ""
var is_open := false
## Where the opening is (its middle, on the floor), and how near counts as
## crawling through it.
var hole := Vector3.ZERO
var reach := 0.5
var _cover: Node3D
var _block: CollisionShape3D
var _passed := false


## A vent in a wall whose middle is at `c` (on the floor), with `normal`
## pointing into the room the cover faces. Adds the wall piece to `level`.
static func in_wall(p_id: String, level: JobLevel, c: Vector3, normal: Vector3) -> LabsVent:
	var along := Vector3(-normal.z, 0, normal.x)
	var yaw := rad_to_deg(atan2(along.x, along.z))
	Kit.solid(level, Kit.BUILDING + "wall-doorway-square.glb", c, yaw, JobLevel.WALL_SCALE)
	# Fill the doorway in above the vent.
	var top := 2.1 * JobLevel.WALL_SCALE.y
	var filler := Kit.block(level, c + Vector3(0, (HIGH + top) * 0.5, 0), Vector3(0.22, top - HIGH, 0.94), "", Kit.flat(WALL_COLOR))
	filler.rotation.y = deg_to_rad(yaw)
	var v := LabsVent.new()
	v.id = p_id
	v.name = "Vent_" + p_id
	v.hole = c
	v.position = c + normal * 0.11
	v.rotation.y = atan2(normal.x, normal.z)
	var m: Node3D = Kit.scene(MODEL).instantiate()
	m.scale = Vector3(WIDE / 0.6, HIGH / 0.4, 1.0)
	v.add_child(m)
	v._cover = m.find_child("cover", true, false) as Node3D
	v._block = v.add_box(Vector3(0, HIGH * 0.5, -0.08), Vector3(WIDE, HIGH, 0.12))
	v.add_action("interact", "Unscrew the vent cover", v._unscrew)
	level.add_child(v)
	return v


## A hatch lying on a roof at `c` (its middle, on the roof), `size` across,
## over a shaft going down.
static func hatch(p_id: String, level: JobLevel, c: Vector3, size: Vector2) -> LabsVent:
	var v := LabsVent.new()
	v.id = p_id
	v.name = "Vent_" + p_id
	# Counted on the way down the shaft, below the roof.
	v.hole = c - Vector3(0, 1.2, 0)
	v.reach = 1.0
	v.position = c
	var lid := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(size.x, 0.06, size.y)
	bm.material = Kit.flat(Color(0.42, 0.44, 0.5))
	lid.mesh = bm
	lid.position = Vector3(0, 0.03, 0)
	v.add_child(lid)
	# Slats, so it reads as a grille.
	for i in 5:
		var slat := MeshInstance3D.new()
		var sm := BoxMesh.new()
		sm.size = Vector3(size.x - 0.2, 0.03, 0.06)
		sm.material = Kit.flat(Color(0.2, 0.21, 0.24))
		slat.mesh = sm
		slat.position = Vector3(0, 0.07, (i - 2) * size.y / 6.0)
		lid.add_child(slat)
	v._cover = lid
	v._block = v.add_box(Vector3(0, 0.03, 0), Vector3(size.x, 0.06, size.y))
	v.add_action("interact", "Lift the vent hatch", v._unscrew)
	level.add_child(v)
	return v


func _unscrew(pic: PlayerInteractionComponent) -> void:
	open()
	StealthNoise.make(self, global_position + Vector3(0, 0.4, 0), 1.5, "vent", pic.get_parent())
	UsableBody.hint(pic, "The cover comes away. In you go.")


## Takes the cover off (quietly, by hand).
func open() -> void:
	if is_open:
		return
	is_open = true
	if _cover:
		_cover.visible = false
	_block.disabled = true
	Sfx.at(self, "kenney:metalClick", global_position + Vector3(0, 0.4, 0), -12.0, 0.8)
	set_action_text("interact", "")
	_record("vent_open:" + id)


func _physics_process(_delta: float) -> void:
	if not is_open or _passed:
		return
	var p := get_tree().get_first_node_in_group("moth") as Moth
	if p == null:
		return
	var feet := p.feet_position()
	var flat := Vector2(feet.x - hole.x, feet.z - hole.z)
	if flat.length() < reach and feet.y > hole.y - 0.2 and feet.y < hole.y + 0.6:
		_passed = true
		_record("vent:" + id)


func _record(event: String) -> void:
	if JobRun.current:
		JobRun.current.record(event)
