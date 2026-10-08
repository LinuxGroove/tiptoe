class_name Rigs
extends RefCounted
## Animated models for people and the dog: Kenney's Mini Characters and
## cube dog with the extra clips made in Blender (assets/models/clips), which
## are copied onto whichever character needs them.

const CLIPS_PERSON := "res://assets/models/clips/mini-character-clips.glb"
const CLIPS_DOG := "res://assets/models/clips/animal-dog-clips.glb"
const CHARACTERS := "res://assets/kenney/mini-characters/character-%s.glb"
const PERSON_CLIPS := ["startled", "look-around", "sleep", "phone-call", "sit-watch"]
const PERSON_LOOPS := ["look-around", "sleep", "phone-call", "sit-watch"]
const DOG_LOOPS := ["sleep", "sniff", "idle", "walk"]
## Mini Characters are 0.67 units tall; people are about 1.7 m.
const PERSON_SCALE := 2.55
const DOG_SCALE := 0.4

static var _source: Dictionary = {}


## A person in one of the Mini Character looks ("male-a", "female-b"...), or
## another model on the same rig by its res:// path (the market's employee).
static func person(look: String) -> RigCharacter:
	var path := look if look.begins_with("res://") else CHARACTERS % look
	var rc := RigCharacter.create(load(path), PERSON_SCALE)
	_copy_clips(rc, CLIPS_PERSON, "character-male-a/Skeleton3D", PERSON_CLIPS)
	for c in PERSON_LOOPS:
		rc.set_looping(c)
	return rc


static func dog() -> RigCharacter:
	var rc := RigCharacter.create(load(CLIPS_DOG), DOG_SCALE)
	for c in DOG_LOOPS:
		rc.set_looping(c)
	return rc


## Copies clips from a clips file onto a rig whose skeleton has the same
## bones, rewriting the track paths to the rig's own skeleton.
static func _copy_clips(rc: RigCharacter, clips_path: String, from_prefix: String, names: Array) -> void:
	var anim := rc._anim
	if anim == null:
		return
	var skel := rc.skeleton()
	var root := anim.get_node(anim.root_node)
	var to_prefix := str(root.get_path_to(skel))
	var lib := anim.get_animation_library("")
	var src := _source_player(clips_path)
	for n in names:
		if anim.has_animation(n) or not src.has_animation(n):
			continue
		var a: Animation = src.get_animation(n).duplicate(true)
		for t in a.get_track_count():
			var p := str(a.track_get_path(t))
			if p.begins_with(from_prefix):
				a.track_set_path(t, NodePath(to_prefix + p.trim_prefix(from_prefix)))
		lib.add_animation(n, a)


static func _source_player(path: String) -> AnimationPlayer:
	if not _source.has(path):
		var inst: Node = load(path).instantiate()
		var found := inst.find_children("*", "AnimationPlayer", true, false)
		_source[path] = found[0]
		# Kept alive (out of the tree) for as long as the game runs.
		_source[path + "#root"] = inst
	return _source[path]
