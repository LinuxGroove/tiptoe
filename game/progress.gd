extends Node
## What the player has done in every job, kept between runs (autoload:
## Progress): capers finished, leads found, best score and time, and the
## mastery level that unlocks start points and gadgets.

signal changed(job_id: String)

const PATH := "user://progress.cfg"

var _cfg := ConfigFile.new()
## Tests set this so they never touch the player's real progress file.
var in_memory := false


func _ready() -> void:
	load_progress()


func load_progress() -> void:
	_cfg = ConfigFile.new()
	if not in_memory:
		_cfg.load(PATH)


func reset() -> void:
	_cfg = ConfigFile.new()
	_save()


func capers_done(job_id: String) -> PackedStringArray:
	return PackedStringArray(_cfg.get_value(job_id, "capers", PackedStringArray()))


func has_caper(job_id: String, caper_id: String) -> bool:
	return caper_id in capers_done(job_id)


func leads_found(job_id: String) -> PackedStringArray:
	return PackedStringArray(_cfg.get_value(job_id, "leads", PackedStringArray()))


func best_score(job_id: String) -> int:
	return int(_cfg.get_value(job_id, "best_score", 0))


## Fastest run that got the treasure out, in seconds, or 0 for none yet.
func best_time(job_id: String) -> float:
	return float(_cfg.get_value(job_id, "best_time", 0.0))


func runs(job_id: String) -> int:
	return int(_cfg.get_value(job_id, "runs", 0))


func treasures(job_id: String) -> int:
	return int(_cfg.get_value(job_id, "treasures", 0))


## Mastery goes up one level for every two capers, up to five.
func mastery(job_id: String) -> int:
	return mini(5, capers_done(job_id).size() / 2)


## Records a finished run (a JobRun's result) and returns what it newly
## unlocked, as {"capers": [...], "mastery_from": n, "mastery_to": m}.
func record_run(job_id: String, result: Dictionary) -> Dictionary:
	var before := mastery(job_id)
	var capers := capers_done(job_id)
	var new_capers := []
	for c in result.get("capers", []):
		if not c in capers:
			capers.append(c)
			new_capers.append(c)
	_cfg.set_value(job_id, "capers", capers)
	var leads := leads_found(job_id)
	for l in result.get("leads", []):
		if not l in leads:
			leads.append(l)
	_cfg.set_value(job_id, "leads", leads)
	_cfg.set_value(job_id, "runs", runs(job_id) + 1)
	if result.get("escaped", false) and result.get("treasure", false):
		_cfg.set_value(job_id, "treasures", treasures(job_id) + 1)
		var t := float(result.get("time", 0.0))
		if best_time(job_id) <= 0.0 or t < best_time(job_id):
			_cfg.set_value(job_id, "best_time", t)
	var score := int(result.get("score", 0))
	if score > best_score(job_id):
		_cfg.set_value(job_id, "best_score", score)
	_save()
	changed.emit(job_id)
	return {"capers": new_capers, "mastery_from": before, "mastery_to": mastery(job_id)}


func _save() -> void:
	if not in_memory:
		_cfg.save(PATH)
