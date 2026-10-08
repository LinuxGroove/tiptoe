class_name TownHallCrowd
extends TownHallPerson
## One of the townsfolk (or a councillor) sitting through the meeting. They
## never leave their seat: a noise turns their head, and someone they don't
## like the look of gets pointed out to the staff instead of chased. They
## mumble rather than speak, so they have no recorded lines.

## Staff come when the crowd points someone out from this far away.
const CALL_RANGE := 22.0

var _turn_t := 0.0


func _physics_process(delta: float) -> void:
	_turn_t -= delta
	if suspicion < 0.15:
		_spotted_this_time = false
	super(delta)


## Seated: arriving is instant and they stay put.
func _go(at: Vector3, _speed: float) -> void:
	_target = at
	_arrived = false


func _move(_delta: float) -> void:
	if not _arrived and state != State.SNOOZE:
		_on_arrived()


func _curious(_at: Vector3, bump: float, said_line: String) -> void:
	suspicion = minf(0.99, suspicion + bump)
	if suspicion < CURIOUS and bump > 0.0:
		return
	if _turn_t > 0.0 or state == State.SNOOZE:
		return
	_turn_t = 6.0
	rig.play_once("startled")
	say(said_line if said_line != "" else line("curious"))


## Spotted: a shout and a pointed finger, and the staff come running.
func _spot() -> void:
	if not _spotted_this_time:
		_spotted_this_time = true
		run.add_spotted()
		Sfx.at(self, "spotted", global_position + Vector3(0, 1.8, 0), -2.0)
		say(line("spotted"))
		rig.play_once("startled")
		var p := get_tree().get_first_node_in_group("moth") as Node3D
		var at: Vector3 = p.global_position if p else global_position
		for o in get_tree().get_nodes_in_group("people"):
			if o is TownHallCrowd or not o is Person or o.is_asleep():
				continue
			if o.global_position.distance_to(global_position) < CALL_RANGE:
				o._curious(at, 0.8, o.line("others"))
	suspicion = 0.6


func all_lines() -> PackedStringArray:
	return PackedStringArray()
