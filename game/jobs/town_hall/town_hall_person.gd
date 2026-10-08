class_name TownHallPerson
extends Person
## Someone at the town hall whose routine steps can make things happen: the
## level hears when they reach a step (`step_arrived`) and when they finish
## one and move on (`step_done`), so the mayor can open the strongbox, carry
## the charter and put it on the lectern. A step with "overhear" records
## "heard:<id>" if the player is close enough to catch what they say.

signal step_arrived(person: TownHallPerson, step: Dictionary)
signal step_done(person: TownHallPerson, step: Dictionary)
signal dozed(person: TownHallPerson)

## How close the player must be to overhear a line (through at most one wall).
const OVERHEAR_RANGE := 9.0


func _think(delta: float) -> void:
	var before := _step
	var was: Array = routine
	super(delta)
	if state == State.ROUTINE and is_same(routine, was) and _step != before and before < routine.size():
		step_done.emit(self, routine[before])


func _arrive_step() -> void:
	super()
	if routine.is_empty():
		return
	var s: Dictionary = routine[_step]
	if s.has("overhear") and player_hears():
		run.record("heard:" + s.overhear)
	step_arrived.emit(self, s)


## Can the player hear this person talk from where they are?
func player_hears() -> bool:
	var p := get_tree().get_first_node_in_group("moth") as Moth
	if p == null:
		return false
	var mouth := global_position + Vector3(0, EYE_HEIGHT, 0)
	if mouth.distance_to(p.eye_position()) > OVERHEAR_RANGE:
		return false
	return StealthNoise.count_walls(self, mouth, p.eye_position()) <= 1


func snooze() -> void:
	var was := state
	super()
	if was != State.SNOOZE and state == State.SNOOZE:
		dozed.emit(self)


## Starts a new routine from its first step (the mayor's trip for the vote).
func switch_routine(new_routine: Array) -> void:
	routine = new_routine
	_step = 0
	if state in [State.ROUTINE, State.WAIT]:
		_resume_routine()
