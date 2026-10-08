extends Node
## Takes screenshots of a job from set viewpoints, for checking how a level
## looks. Run with a display (xvfb-run on a server):
##   xvfb-run -s "-screen 0 1280x720x24" godot --path . tools/screenshot.tscn -- --out=/tmp/shots [--job=maple_close] [--view=name]
## Each view is a player position, a facing and a look pitch.

const VIEWS := {
	"street": [Vector3(-4, 0, 16), 0.0, 0.0],
	"front": [Vector3(-1, 0, 8.5), 0.0, 5.0],
	"garden": [Vector3(-8, 0, -12), 150.0, 5.0],
	"alley": [Vector3(14.5, 0, -8), 180.0, 0.0],
	"hall": [Vector3(-1, 0, 4), 0.0, 0.0],
	"living": [Vector3(-2.6, 0, 0), 120.0, -5.0],
	"kitchen": [Vector3(0, 0, -1.6), 60.0, -10.0],
	"landing": [Vector3(-1, 2.5, 3.5), 0.0, -5.0],
	"bedroom": [Vector3(-2.6, 2.5, 0), 120.0, -10.0],
	"study": [Vector3(2.8, 2.5, -2), -110.0, -10.0],
	"garage": [Vector3(7, 0, 0), -140.0, -5.0],
	"roof": [Vector3(9, 2.5, -2), -90.0, 0.0],
}

var _out := "/tmp/shots"
var _job: Job


func _ready() -> void:
	var job_id := "maple_close"
	var only := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.trim_prefix("--out=")
		elif a.begins_with("--job="):
			job_id = a.trim_prefix("--job=")
		elif a.begins_with("--view="):
			only = a.trim_prefix("--view=")
	DirAccess.make_dir_recursive_absolute(_out)
	LGSettings.register_defaults(GameConfig.SETTING_DEFAULTS)
	LGInput.register_actions(GameConfig.ACTIONS)
	LGTheme.apply(get_tree().root, 22)
	_job = (load("res://game/jobs/job.tscn") as PackedScene).instantiate()
	_job.job = Jobs.get_job(job_id)
	add_child(_job)
	await _frames(30)
	for v in VIEWS:
		if only != "" and v != only:
			continue
		var view: Array = VIEWS[v]
		_job.player.global_position = view[0] + Vector3(0, 0.9, 0)
		_job.player.velocity = Vector3.ZERO
		_job.player.body.rotation.y = deg_to_rad(view[1])
		_job.player.head.rotation.x = deg_to_rad(view[2])
		await _frames(12)
		var img := get_viewport().get_texture().get_image()
		img.save_png("%s/%s.png" % [_out, v])
		print("saved ", v)
	get_tree().quit()


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame
