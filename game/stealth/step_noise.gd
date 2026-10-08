class_name StepNoise
extends FootstepSurfaceDetector
## Cogito's footstep player, which also makes a noise for every step. The
## floor's footstep profile is named after its surface
## (footsteps_<surface>.tres), which sets how far the step carries.

var last_surface := ""


func _play_footstep(profile: AudioStreamRandomizer, interaction_type: String):
	super(profile, interaction_type)
	var surface := surface_of(profile)
	last_surface = surface
	var p := get_parent()
	var crouching: bool = p.get("is_crouching") == true
	var sprinting: bool = p.get("is_sprinting") == true
	var r := StealthNoise.step_radius(surface, crouching, sprinting)
	if interaction_type == "landing":
		r *= 1.5
	StealthNoise.make(self, global_position, r, "step", p)


static func surface_of(profile: AudioStreamRandomizer) -> String:
	if profile == null:
		return ""
	var f := profile.resource_path.get_file().get_basename()
	if f.begins_with("footsteps_"):
		return f.trim_prefix("footsteps_")
	return "concrete"
