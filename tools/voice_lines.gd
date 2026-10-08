extends Node
## Brings the voice lines in tools/lemonade/audio.json up to date with what
## every job's people can say: builds each job's level, adds its people and
## asks them (see [method Person.all_lines]). Lines keep any extra fields
## they had (like "say"); lines nobody says any more are dropped.
##
##   godot --headless --path . tools/voice_lines.tscn
##
## Then make the new lines with tools/lemonade/generate.py --only voices.

const MANIFEST := "res://tools/lemonade/audio.json"


func _ready() -> void:
	var m := update(read_manifest())
	var f := FileAccess.open(MANIFEST, FileAccess.WRITE)
	f.store_string(JSON.stringify(whole_numbers(m), "\t", false) + "\n")
	f.close()
	var n := 0
	for v in m.voices.voices:
		n += m.voices.voices[v].lines.size()
	print("Voice lines: %d voices, %d lines" % [m.voices.voices.size(), n])
	get_tree().quit()


static func read_manifest() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))


## Every voice in the built jobs: voice -> {info: {...}, lines: [text]}.
static func collect() -> Dictionary:
	var out := {}
	for job in Jobs.all():
		if not job.playable:
			continue
		var level: JobLevel = load(job.scene).new()
		level.build()
		var run := JobRun.new()
		run.setup(job)
		var people := level.add_people(run)
		var info := level.voice_info()
		for p in people:
			if not p is Person:
				continue
			if not out.has(p.voice):
				out[p.voice] = {"info": info.get(p.voice, {}), "lines": PackedStringArray()}
			for l in p.all_lines():
				if not l in out[p.voice].lines:
					out[p.voice].lines.append(l)
		level.free()
		run.free()
	return out


## The manifest with its voices brought up to date.
static func update(m: Dictionary) -> Dictionary:
	var old: Dictionary = m.voices.voices
	var voices := {}
	var found := collect()
	for v in found:
		var was: Dictionary = old.get(v, {})
		var info: Dictionary = found[v].info
		# Mumble-only crowds have no recorded voice.
		if info.get("kokoro", was.get("kokoro_voice", "")) == "":
			continue
		var entry := {
			"who": info.get("who", was.get("who", v)),
			"kokoro_voice": info.get("kokoro", was.get("kokoro_voice", "")),
			"speed": info.get("speed", was.get("speed", 1.0)),
		}
		var old_lines := {}
		for l in was.get("lines", []):
			old_lines[l.text] = l
		var lines := []
		for text in found[v].lines:
			var l: Dictionary = old_lines.get(text, {}).duplicate()
			l["text"] = text
			l["file"] = "assets/audio/voice/%s/%s.ogg" % [v, Sfx.slug(text)]
			lines.append(l)
		entry["lines"] = lines
		voices[v] = entry
	m.voices.voices = voices
	return m


## JSON reads every number as a float; turns the whole ones (like music
## seconds) back into ints so rewriting the manifest changes only the voices.
## Voice speeds stay floats.
static func whole_numbers(v: Variant, key := "") -> Variant:
	if v is Dictionary:
		for k in v:
			v[k] = whole_numbers(v[k], k)
	elif v is Array:
		for i in v.size():
			v[i] = whole_numbers(v[i], key)
	elif v is float and key != "speed" and v == floorf(v):
		return int(v)
	return v
