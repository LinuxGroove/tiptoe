class_name BottlingLadder
extends Node3D
## A fixed ladder (or the rope down from the skylight): using its foot
## climbs to the top and using its top climbs back down. Climbing takes a
## moment, rattles a little, and records "climbed:<id>". People don't use
## ladders.

const SPEED := 2.2
const NOISE := 2.0

var id := ""
## Feet positions at the bottom and the top.
var bottom := Vector3.ZERO
var top := Vector3.ZERO
## False (and hidden) until something opens the way (the skylight's latch).
var usable := true
var foot: UsableBody
var head: UsableBody
var _climbing: Moth
var _tween: Tween


## A ladder standing at `base` (on the floor, against the edge it climbs)
## from `p_bottom` up to `p_top` (where the climber's feet start and end),
## drawn as rails and rungs in `color`, or as a knotted rope with `rope`.
static func make(p_id: String, base: Vector3, p_bottom: Vector3, p_top: Vector3, color := Color(0.85, 0.7, 0.15), rope := false) -> BottlingLadder:
	var l := BottlingLadder.new()
	l.id = p_id
	l.name = "Ladder_" + p_id
	l.bottom = p_bottom
	l.top = p_top
	l._draw(base, color, rope)
	l.foot = l._end("Foot", p_bottom + Vector3(0, 0.9, 0), "Climb up")
	l.head = l._end("Head", p_top + Vector3(0, 0.4, 0), "Climb down")
	return l


func _draw(a: Vector3, color: Color, rope: bool) -> void:
	# The rails run from the base up past the top.
	var b := Vector3(a.x, top.y + 1.0, a.z)
	var along := bottom - top
	along.y = 0
	var side := Vector3(-along.z, 0, along.x).normalized() if along.length() > 0.01 else Vector3.RIGHT
	var h := b.y - a.y
	if rope:
		_bar(a.lerp(b, 0.5), Vector3(0.05, h, 0.05), side, Color(0.75, 0.62, 0.42))
		var y := a.y + 0.4
		while y < b.y - 0.2:
			_bar(Vector3(a.x, y, a.z), Vector3(0.12, 0.08, 0.12), side, Color(0.62, 0.5, 0.33))
			y += 0.5
		return
	for s in [-0.22, 0.22]:
		_bar(a.lerp(b, 0.5) + side * s, Vector3(0.05, h, 0.05), side, color)
	var y := a.y + 0.3
	while y < b.y - 0.1:
		_bar(Vector3(a.x, y, a.z), Vector3(0.44, 0.04, 0.04), side, color)
		y += 0.3


func _bar(center: Vector3, size: Vector3, side: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	bm.material = Kit.flat(color)
	mi.mesh = bm
	mi.position = center
	mi.rotation.y = atan2(-side.z, side.x)
	add_child(mi)


func _end(n: String, at: Vector3, verb: String) -> UsableBody:
	var u := UsableBody.new()
	u.name = n
	u.collision_layer = Kit.LAYER_INTERACT
	u.position = at
	u.add_box(Vector3.ZERO, Vector3(0.7, 0.9, 0.7))
	u.add_action("interact", verb, _use.bind(u))
	add_child(u)
	return u


## Shows (or hides) the ladder and lets it be climbed.
func set_usable(on: bool) -> void:
	usable = on
	visible = on
	for u in [foot, head]:
		u.collision_layer = Kit.LAYER_INTERACT if on else 0


func _use(pic: PlayerInteractionComponent, end: UsableBody) -> void:
	if not usable:
		return
	climb(pic.get_parent(), end == foot)


## Climbs `p` up (or down) the ladder.
func climb(p: Moth, up: bool) -> void:
	if _climbing != null:
		return
	_climbing = p
	var from := bottom if up else top
	var to := top if up else bottom
	var lift := Vector3(0, 0.9, 0)
	var t := absf(to.y - from.y) / SPEED + 0.4
	p.velocity = Vector3.ZERO
	p.main_velocity = Vector3.ZERO
	p.global_position = from + lift
	StealthNoise.make(self, from, NOISE, "climb", p)
	Sfx.at(self, "kenney:handleSmallLeather", from + Vector3(0, 1.0, 0), -10.0)
	_tween = create_tween()
	# The player's own mantle tween also pauses their walking and gravity.
	p._mantle_tween = _tween
	_tween.tween_property(p, "global_position", Vector3(from.x, to.y, from.z) + lift if up else Vector3(to.x, from.y, to.z) + lift, t * 0.8)
	_tween.tween_property(p, "global_position", to + lift + Vector3(0, 0.05, 0), t * 0.2)
	_tween.finished.connect(_done.bind(p))
	if JobRun.current:
		JobRun.current.record("climbed:" + id)


func _done(p: Moth) -> void:
	_climbing = null
	if is_instance_valid(p):
		StealthNoise.make(self, p.feet_position(), NOISE, "climb", p)
