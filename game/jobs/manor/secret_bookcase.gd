class_name SecretBookcase
extends UsableBody
## The library's secret door: a full bookcase over a doorway that slides
## aside along the wall when the red book is pulled (or the lever behind it
## is). It blocks the way, sight and sound like a closed door, and people
## don't know it's there, so it stays out of their navigation.

## Sideways along the wall (its local +X) it slides this far.
const SLIDE := 1.4
const TIME := 1.6

var is_open := false
var _closed_pos := Vector3.ZERO
var _tween: Tween


static func make(id: String) -> SecretBookcase:
	var b := SecretBookcase.new()
	b.name = "Secret_" + id
	b.collision_layer = Kit.LAYER_DOOR
	# A wide bookcase, the shelves facing +Z (into the library).
	var m: Node3D = Kit.scene(Kit.FURNITURE + "bookcaseClosedWide.glb").instantiate()
	m.scale = Vector3.ONE * Kit.FURNITURE_SCALE
	m.position = Vector3(-0.8, 0, 0.25)
	b.add_child(m)
	# The top shelf to the ceiling, so there's no gap over the doorway.
	var top := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.6, 0.9, 0.5)
	bm.material = Kit.flat(Color(0.42, 0.28, 0.18))
	top.mesh = bm
	top.position = Vector3(0, 2.03, 0)
	b.add_child(top)
	b.add_box(Vector3(0, 1.24, 0), Vector3(1.6, 2.48, 0.5))
	return b


func _ready() -> void:
	_closed_pos = position


## Opens (or closes) it: `by` is whoever pulled the book or the lever.
func toggle(by: Node) -> void:
	is_open = not is_open
	if _tween:
		_tween.kill()
	_tween = create_tween()
	var to := _closed_pos + transform.basis.x.normalized() * SLIDE if is_open else _closed_pos
	_tween.tween_property(self, "position", to, TIME).set_trans(Tween.TRANS_SINE)
	Sfx.at(self, "kenney:stoneDrag4", global_position + Vector3(0, 1.0, 0), -4.0, 0.8)
	if by and by.is_in_group("moth"):
		StealthNoise.make(self, global_position + Vector3(0, 1.0, 0), 4.0, "door", by)
		if is_open and JobRun.current:
			JobRun.current.record("opened:secret_bookcase")
