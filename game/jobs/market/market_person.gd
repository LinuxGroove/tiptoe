extends Person
## Someone working at the corner market. Routine steps can carry a "do" the
## level acts on when they arrive (the bins, locking the back door), and the
## doors in `leave_to_closers` are left for their door closers to shut, so a
## door they hurried through stays open for a little while behind them.

## Door ids they never shut themselves.
var leave_to_closers: Array = []


func setup(p_name: String, look: String, p_level: JobLevel, p_run: JobRun, p_routine: Array, p_voice := "low", opts := {}) -> void:
	super(p_name, look, p_level, p_run, p_routine, p_voice, opts)
	# Stacking shelves and counting money go on for as long as the step does.
	rig.set_looping("interact-right")
	rig.set_looping("interact-left")


## The step they're on (for tests and the level).
func current_step() -> Dictionary:
	return routine[_step] if not routine.is_empty() else {}


func _arrive_step() -> void:
	super()
	var s := current_step()
	if s.has("do") and level.has_method("person_did"):
		level.person_did(self, s.do)


func _close_doors_behind() -> void:
	for d in _doors_opened.duplicate():
		if d.id in leave_to_closers:
			_doors_opened.erase(d)
	super()


## The deliveries door faces the alley: they look out of it at whoever rang.
func _answering(delta: float) -> void:
	super(delta)
	if state == State.ANSWER_DOOR and _arrived and level.points.has("front_step"):
		var to: Vector3 = level.points["front_step"] - global_position
		rig.rotation.y = atan2(to.x, to.z)
