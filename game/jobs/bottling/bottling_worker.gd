class_name BottlingWorker
extends Person
## Someone on the plant's night shift: a [Person] who can be sent on an
## errand by the level (go and restart the stopped line, drop everything for
## a cup of tea) and wears a hard hat. Rosa and Eddie record
## "worker_bothered" whenever the player takes them away from their work.

## The errand under way ("restart", "tea"), or "".
var errand := ""
## Rosa and Eddie are line workers; the foreman isn't.
var line_worker := false
var _on_errand_done := Callable()
var _errand_clip := ""
var _errand_face := Vector3.ZERO


## Sends them to `point` to spend `seconds` there, saying `text`, then calls
## `on_done` with them. False if they're busy with something more pressing.
func send(kind: String, point: String, seconds: float, text: String, on_done := Callable(), clip := "", face := Vector3.ZERO) -> bool:
	if not is_free():
		return false
	errand = kind
	_on_errand_done = on_done
	_errand_clip = clip
	_errand_face = face
	say(text)
	wait_at(point, seconds)
	if line_worker:
		run.record("worker_bothered")
	return true


## Going about their routine, with no errand.
func is_free() -> bool:
	return errand == "" and state in [State.ROUTINE, State.WAIT]


## A hard hat on their head (and a hi-vis tabard over their clothes).
func dress(hat_color := Color(1, 1, 1), vest := true) -> void:
	var skel := rig.skeleton()
	if skel == null:
		return
	var head := BoneAttachment3D.new()
	head.bone_name = "head"
	skel.add_child(head)
	var hat: Node3D = Kit.scene(Kit.PROTOTYPE + "hat-hard.glb").instantiate()
	hat.position = Vector3(0, 0.235, 0.0)
	hat.scale = Vector3.ONE * 1.12
	if hat_color != Color(1, 1, 1):
		for mi in hat.find_children("", "MeshInstance3D", true, false):
			mi.material_override = Kit.flat(hat_color)
	head.add_child(hat)
	if vest:
		var torso := BoneAttachment3D.new()
		torso.bone_name = "torso"
		skel.add_child(torso)
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.27, 0.13, 0.17)
		bm.material = Kit.flat(Color(0.85, 0.95, 0.15), 0.6)
		mi.mesh = bm
		mi.position = Vector3(0, 0.075, 0)
		torso.add_child(mi)


func _think(delta: float) -> void:
	if errand != "":
		if state != State.WAIT:
			# Something more pressing came up; the level sends someone again.
			errand = ""
		elif _arrived and _state_t >= _step_time:
			var done := _on_errand_done
			errand = ""
			if done.is_valid():
				done.call(self)
			if state != State.WAIT:
				return
	super(delta)


func _on_arrived() -> void:
	super()
	if errand != "" and state == State.WAIT:
		if _errand_face != Vector3.ZERO:
			rig.rotation.y = atan2(_errand_face.x, _errand_face.z)
		if _errand_clip != "":
			rig.play(_errand_clip)


func _curious(at: Vector3, bump: float, said_line: String) -> void:
	var was := state
	super(at, bump, said_line)
	if line_worker and state == State.INVESTIGATE and was != State.INVESTIGATE:
		run.record("worker_bothered")


func snooze() -> void:
	super()
	run.record("snoozed:" + name.to_lower())
	if line_worker:
		run.record("worker_bothered")


func on_alarm(at: Vector3) -> void:
	errand = ""
	super(at)
	if line_worker and state == State.INVESTIGATE:
		run.record("worker_bothered")
