class_name TownHallSeat
extends HideSpot
## An empty seat in the council chamber. In a borrowed coat you sit down
## among the townsfolk and nobody gives you a second look; without one you'd
## stand out, so it won't let you.

const DISGUISE := "townsfolk"


static func make_seat(seat_name: String, eye_at: Vector3) -> TownHallSeat:
	var s := TownHallSeat.new()
	s.name = "Seat_" + seat_name
	s.collision_layer = Kit.LAYER_INTERACT
	s.eye = eye_at
	# Out behind the bench, away from the people in the next row.
	s.exit = Vector3(0, 0, -0.9)
	s.add_box(Vector3(0, 0.5, 0), Vector3(0.7, 1.0, 0.5))
	s.add_action("interact", "Take a seat", s._sit)
	return s


func _sit(pic: PlayerInteractionComponent) -> void:
	var p: Node = pic.get_parent()
	if p.hiding != null:
		return
	if p.disguise != DISGUISE:
		UsableBody.hint(pic, "You'd stand out. Borrow a coat first.")
		return
	p.hide_in(self)
	if JobRun.current:
		JobRun.current.record("sat_in_meeting")
