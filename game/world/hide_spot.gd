class_name HideSpot
extends UsableBody
## Somewhere to hide: a wardrobe, a cupboard, a cardboard box. It's only the
## part the player uses; the level puts the furniture there. Inside, the
## player looks out from `eye` and nobody sees them, unless someone chasing
## them watched them go in. Using it again (or jumping) steps back out.

## Where the player's eyes are inside, in this spot's space.
var eye := Vector3(0, 1.4, 0)
## Where they step out to, in this spot's space (in front, along +Z).
var exit := Vector3(0, 0, 0.9)


static func make(spot_name: String, verb: String, p_eye: Vector3, box: Vector3) -> HideSpot:
	var h := HideSpot.new()
	h.name = "Hide_" + spot_name
	h.collision_layer = Kit.LAYER_INTERACT
	h.eye = p_eye
	h.exit = Vector3(0, 0, box.z * 0.5 + 0.6)
	h.add_box(Vector3(0, box.y * 0.5, 0), box)
	h.add_action("interact", verb, h._use)
	return h


func _use(pic: PlayerInteractionComponent) -> void:
	var p: Node = pic.get_parent()
	if p.hiding == null:
		p.hide_in(self)
