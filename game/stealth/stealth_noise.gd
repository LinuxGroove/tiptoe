class_name StealthNoise
extends RefCounted
## Noises people (and the dog) can hear. A noise has a position and a radius
## in metres: anyone inside it hears it, with each wall or closed door in
## between halving the radius. Listeners join the "hears" group and have
## `hear(noise: StealthNoise)`; the HUD's noise rings join "noise_watchers" and have
## `on_noise(noise: StealthNoise)`.

## How far footsteps carry on each floor, walking (metres).
const SURFACE_RADIUS := {
	"carpet": 2.0,
	"grass": 3.0,
	"concrete": 4.5,
	"tile": 5.5,
	"wood": 6.5,
}
const CROUCH_FACTOR := 0.5
const SPRINT_FACTOR := 2.0
## Collision layer of walls and doors that muffle sound.
const WALL_MASK := 1

var position := Vector3.ZERO
var radius := 0.0
## "step", "climb", "door", "knock", "bell", "bark", "rattle", "voice"...
var kind := ""
var source: Node


static func make(from: Node, p_position: Vector3, p_radius: float, p_kind: String, p_source: Node = null) -> StealthNoise:
	var n := StealthNoise.new()
	n.position = p_position
	n.radius = p_radius
	n.kind = p_kind
	n.source = p_source
	if from == null or not from.is_inside_tree():
		return n
	var tree := from.get_tree()
	for l in tree.get_nodes_in_group("hears"):
		if l != p_source and l.has_method("hear"):
			l.hear(n)
	for w in tree.get_nodes_in_group("noise_watchers"):
		w.on_noise(n)
	return n


## How loud this noise is at `ear` (0 = can't hear it, 1 = right next to it),
## counting walls in between. `world` is any node in the world.
func loudness_at(world: Node3D, ear: Vector3) -> float:
	var d := position.distance_to(ear)
	if d >= radius:
		return 0.0
	var r := radius
	var walls := count_walls(world, position + Vector3(0, 0.3, 0), ear)
	for i in walls:
		r *= 0.5
	if d >= r:
		return 0.0
	return 1.0 - d / r


## Walls and closed doors between two points, up to three.
static func count_walls(world: Node3D, a: Vector3, b: Vector3) -> int:
	var space := world.get_world_3d().direct_space_state
	var count := 0
	var from := a
	var exclude: Array[RID] = []
	while count < 3:
		var q := PhysicsRayQueryParameters3D.create(from, b, WALL_MASK)
		q.exclude = exclude
		q.collide_with_areas = false
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			break
		var c: Object = hit.collider
		if c is CollisionObject3D and not (c is CharacterBody3D) and not (c is RigidBody3D):
			count += 1
		exclude.append(hit.rid)
		from = hit.position
	return count


static func step_radius(surface: String, crouching: bool, sprinting: bool) -> float:
	var r: float = SURFACE_RADIUS.get(surface, 4.0)
	if crouching:
		r *= CROUCH_FACTOR
	elif sprinting:
		r *= SPRINT_FACTOR
	return r
