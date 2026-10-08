class_name Jobs
extends RefCounted
## Every job on the town map, in story order, and starting one.

const JOB_SCENE := "res://game/jobs/job.tscn"

## [id, title, place, treasure] for the jobs that aren't built yet.
const LATER := [
	["market", "The corner market", "after closing", "Hoard's rent ledger"],
	["bottling", "The bottling plant", "on the night shift", "The clock tower's last cog"],
	["town_hall", "Town hall", "on council night", "The town charter"],
	["museum", "The Hoard Museum", "at the gala", "The founder's statue"],
	["labs", "Hoard Labs", "after hours", "The school's model rocket"],
	["manor", "Hoard Manor", "the last job", "The vault"],
]

static var _cache := {}


static func all() -> Array:
	var out := [get_job("maple_close")]
	for row in LATER:
		var j := JobDef.new()
		j.id = row[0]
		j.title = row[1]
		j.place = row[2]
		j.treasure = row[3]
		j.playable = false
		out.append(j)
	return out


static func get_job(id: String) -> JobDef:
	if _cache.has(id):
		return _cache[id]
	var job: JobDef = null
	match id:
		"maple_close":
			job = MapleCloseJob.make()
	if job:
		_cache[id] = job
	return job


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
