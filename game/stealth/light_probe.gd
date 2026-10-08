class_name LightProbe
extends Node
## Works out how lit the player is, a few times a second, from the lamps in
## the "stealth_lights" group: each lamp that's on and reaches the player
## without a wall in the way adds light, falling off with distance. Writes the
## result to the player's `visibility` (0 dark to 1 brightly lit).

const INTERVAL := 0.15
## Light everywhere outdoors at night (the moon) and indoors with the lights off.
const MOONLIGHT := 0.08
const INDOORS_DARK := 0.03

var player: Node3D
## Set by the level: is this point indoors? (Callable(Vector3) -> bool)
var indoors_test := Callable()
var _t := 0.0


func _physics_process(delta: float) -> void:
	_t -= delta
	if _t > 0.0 or player == null:
		return
	_t = INTERVAL
	var at: Vector3 = player.chest_position()
	var v := light_at(player, at, [player.get_rid()])
	if player.get("is_crouching") == true:
		v *= 0.8
	player.visibility = lerpf(player.visibility, v, 0.6)


## How lit a point is, 0 to 1.
func light_at(world: Node3D, at: Vector3, exclude: Array) -> float:
	var base := MOONLIGHT
	if indoors_test.is_valid() and indoors_test.call(at):
		base = INDOORS_DARK
	var total := base
	var space := world.get_world_3d().direct_space_state
	for l in world.get_tree().get_nodes_in_group("stealth_lights"):
		var light := l as Light3D
		if light == null or not light.is_visible_in_tree() or light.light_energy <= 0.01:
			continue
		var reach := 0.0
		if light is OmniLight3D:
			reach = light.omni_range
		elif light is SpotLight3D:
			reach = light.spot_range
		var d := light.global_position.distance_to(at)
		if d >= reach:
			continue
		if light is SpotLight3D:
			var dir := -light.global_transform.basis.z
			var ang := rad_to_deg(dir.angle_to((at - light.global_position).normalized()))
			if ang > light.spot_angle:
				continue
		var q := PhysicsRayQueryParameters3D.create(light.global_position, at, Kit.LAYER_SOLID)
		q.exclude = exclude
		if not space.intersect_ray(q).is_empty():
			continue
		var f := 1.0 - d / reach
		total += f * f * clampf(light.light_energy, 0.0, 2.0) * 1.1
	return clampf(total, 0.0, 1.0)
