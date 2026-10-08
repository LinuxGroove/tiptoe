class_name Sfx
extends RefCounted
## Plays sounds in the world: one-shots at a place, and loops on a node.

const DIR := "res://assets/audio/sfx/"
const VOICE_DIR := "res://assets/audio/voice/"
const MUSIC_DIR := "res://assets/audio/music/"
const COGITO := "res://addons/cogito/Assets/Audio/Kenney/"

static var _streams := {}


## A sound by name: "doorbell" is ours (assets/audio/sfx), "kenney:doorOpen_1"
## is one of Cogito's Kenney sounds, and a res:// path is used as it is.
static func stream(name: String) -> AudioStream:
	if not _streams.has(name):
		var path := name
		if name.begins_with("kenney:"):
			path = COGITO + name.trim_prefix("kenney:") + ".ogg"
		elif not name.begins_with("res://"):
			path = DIR + name + ".ogg"
		var s: AudioStream = load(path)
		if s is AudioStreamOggVorbis and name.ends_with("_loop"):
			s.loop = true
		_streams[name] = s
	return _streams[name]


## Plays a sound once at `pos`, then cleans up.
static func at(world: Node, name: String, pos: Vector3, volume_db := 0.0, pitch := 1.0) -> AudioStreamPlayer3D:
	if world == null or not world.is_inside_tree():
		return null
	var p := AudioStreamPlayer3D.new()
	p.stream = stream(name)
	p.volume_db = volume_db
	p.pitch_scale = pitch
	p.bus = &"SFX"
	p.unit_size = 4.0
	p.max_distance = 40.0
	world.get_tree().current_scene.add_child(p)
	p.global_position = pos
	p.finished.connect(p.queue_free)
	p.play()
	return p


## A sound attached to `node` that follows it, for loops (snores, hums).
static func on(node: Node3D, name: String, volume_db := 0.0, autoplay := true) -> AudioStreamPlayer3D:
	var p := AudioStreamPlayer3D.new()
	p.name = "Sfx_" + name.get_file()
	p.stream = stream(name)
	p.volume_db = volume_db
	p.bus = &"SFX"
	p.unit_size = 3.0
	p.max_distance = 30.0
	p.autoplay = autoplay
	node.add_child(p)
	return p


## The recorded line for `text` in `voice` ("low", "high"), or "" when there
## isn't one (people mumble instead). Lines live in
## assets/audio/voice/<voice>/<slug>.ogg; see [method slug].
static func voice_line(voice: String, text: String) -> String:
	var path := VOICE_DIR + voice + "/" + slug(text) + ".ogg"
	return path if ResourceLoader.exists(path) else ""


## A file name for a line: lower case words joined by underscores, at most
## 48 characters ("Oi! Stop right there!" is "oi_stop_right_there").
static func slug(text: String) -> String:
	var out := ""
	for c in text.to_lower():
		if (c >= "a" and c <= "z") or (c >= "0" and c <= "9"):
			out += c
		elif c != "'" and not out.ends_with("_") and out != "":
			out += "_"
	return out.left(48).trim_suffix("_")


## Our music track `id` from assets/audio/music, or `fallback` until it exists.
static func music(id: String, fallback: String) -> String:
	var path := MUSIC_DIR + id + ".ogg"
	return path if ResourceLoader.exists(path) else fallback
