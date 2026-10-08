class_name Gadgets
extends Node
## Throwing things from the bag: a dog treat (secondary action), which draws
## the dog, and the noisemaker (primary action), a wind-up toy that rattles
## where it lands and draws people away.

const THROW_SPEED := 7.0
const RATTLE_DELAY := 1.2
const RATTLE_TIME := 6.0
const RATTLE_RADIUS := 11.0

var player: Moth


func _unhandled_input(event: InputEvent) -> void:
	if player == null or player.is_movement_paused or player.is_showing_ui:
		return
	if event.is_action_pressed("action_secondary") and player.take_item("treats"):
		_throw("treat")
	elif event.is_action_pressed("action_primary") and player.take_item("noisemaker"):
		_throw("noisemaker")


func _throw(kind: String) -> RigidBody3D:
	var b := RigidBody3D.new()
	b.collision_layer = 0
	b.collision_mask = Kit.LAYER_WORLD | Kit.LAYER_GLASS
	b.mass = 0.2
	var cs := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.08
	cs.shape = shape
	b.add_child(cs)
	var path := Kit.FOOD + "cookie.glb" if kind == "treat" else "res://assets/kenney/blaster-kit/grenade-a.glb"
	var m: Node3D = Kit.scene(path).instantiate()
	m.scale = Vector3.ONE * (0.35 if kind == "treat" else 0.5)
	b.add_child(m)
	player.get_parent().add_child(b)
	var cam := player.camera
	b.global_position = cam.global_position - cam.global_basis.z * 0.5
	b.linear_velocity = -cam.global_basis.z * THROW_SPEED + Vector3(0, 1.5, 0) + player.velocity
	Sfx.at(player, "kenney:woosh1", b.global_position, -10.0)
	if kind == "treat":
		b.add_to_group("treats")
		_record("threw_treat")
	else:
		_record("used_noisemaker")
		_rattle(b)
	return b


func _rattle(b: RigidBody3D) -> void:
	await get_tree().create_timer(RATTLE_DELAY).timeout
	if not is_instance_valid(b):
		return
	Sfx.at(b, "noisemaker_wind", b.global_position, -2.0)
	var loop := Sfx.on(b, "noisemaker_rattle_loop", 0.0)
	var left := RATTLE_TIME
	while left > 0.0 and is_instance_valid(b):
		StealthNoise.make(b, b.global_position, RATTLE_RADIUS, "rattle", b)
		await get_tree().create_timer(0.8).timeout
		left -= 0.8
	if is_instance_valid(loop):
		loop.stop()


func _record(event: String) -> void:
	if JobRun.current:
		JobRun.current.record(event)
