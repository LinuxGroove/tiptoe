class_name LabsOfficer
extends Person
## Officer Marsh: sits at the monitors in the security office, and goes to
## the break room for her tea at set times, regular as clockwork. While
## she's at her desk the cameras are watched; while she's away (or asleep)
## they only record.

## Run time of her first tea break, then how often and how long (seconds at
## the break room, after walking there).
var first_break := 60.0
var break_every := 180.0
var break_length := 45.0
var on_break := false
## Where she watches from (the level's point).
var desk := "monitors"
var _next_break := 0.0
var _break_line := ""


func setup_breaks(p_first: float, p_every: float, p_length: float, p_line: String) -> void:
	first_break = p_first
	break_every = p_every
	break_length = p_length
	_next_break = p_first
	_break_line = p_line


## Is she at her desk, watching the monitors?
func watching() -> bool:
	if state != State.ROUTINE or not _arrived or not level.points.has(desk):
		return false
	return global_position.distance_to(level.points[desk]) < 1.2


## Off for her tea now (tests call this to skip the wait).
func take_break() -> void:
	on_break = true
	_next_break = run.time + break_every
	say(_break_line)
	wait_at("coffee", break_length)
	run.record("officer_on_break")


func _physics_process(delta: float) -> void:
	super(delta)
	if run == null or not run.running or not _nav_ready:
		return
	if on_break:
		if state != State.WAIT:
			on_break = false
		return
	if run.time >= _next_break and state == State.ROUTINE:
		take_break()
