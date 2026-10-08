class_name Jobs
extends RefCounted
## Every job on the town map, in story order, and starting one. A job lives in
## its own folder, game/jobs/<id>/, whose <id>_job.gd has a static make()
## returning its [JobDef]; jobs not built yet show on the board as titles.

const JOB_SCENE := "res://game/jobs/job.tscn"
const JOB_SCRIPT := "res://game/jobs/%s/%s_job.gd"

## [id, title, place, treasure], in story order.
const ORDER := [
	["maple_close", "Maple Close", "a family home", "The bakery's prize trophy"],
	["market", "The corner market", "after closing", "Hoard's rent ledger"],
	["bottling", "The bottling plant", "on the night shift", "The clock tower's last cog"],
	["town_hall", "Town hall", "on council night", "The town charter"],
	["museum", "The Hoard Museum", "at the gala", "The founder's statue"],
	["labs", "Hoard Labs", "after hours", "The school's model rocket"],
	["manor", "Hoard Manor", "the last job", "The vault"],
]

static var _cache := {}


static func all() -> Array:
	var out := []
	for row in ORDER:
		var j := get_job(row[0])
		if j == null:
			j = JobDef.new()
			j.id = row[0]
			j.title = row[1]
			j.place = row[2]
			j.treasure = row[3]
			j.playable = false
		out.append(j)
	return out


static func ids() -> PackedStringArray:
	var out := PackedStringArray()
	for row in ORDER:
		out.append(row[0])
	return out


static func get_job(id: String) -> JobDef:
	if _cache.has(id):
		return _cache[id]
	var path := JOB_SCRIPT % [id, id]
	if not ResourceLoader.exists(path):
		return null
	var job: JobDef = load(path).make()
	_cache[id] = job
	return job


## A job opens once the treasure of the one before it is home (the first is
## always open).
static func is_open(id: String) -> bool:
	var i := ids().find(id)
	if i <= 0:
		return i == 0
	return Progress.treasures(ORDER[i - 1][0]) > 0


## Starts a job from a start point ("" for the first one).
static func play(id: String, start := "") -> void:
	var job := get_job(id)
	if job == null:
		push_error("Unknown job %s" % id)
		return
	if start == "":
		start = job.start_points[0].id
	LGScenes.change_scene(JOB_SCENE, func(scene: Node) -> void:
		scene.job = job
		scene.start_id = start)
