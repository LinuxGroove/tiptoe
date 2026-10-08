class_name ManorPerson
extends Person
## Someone at Hoard Manor. On top of a [Person]: routine steps can ask the
## level to do something on arrival (`"do": "lock_up"`, see
## [method ManorLevel.on_step]), being spotted by them is recorded by name
## ("spotted_by:Hoard"), and whoever wears Hoard's key on a chain can have it
## lifted while they're out cold from a snooze dart.

## Wearing the vault key on a chain (Hoard, until bedtime).
var has_key := false
## The key on the chain, shown while a snoozed wearer can be robbed.
var _pocket: UsableBody
var _pocket_on := false


func _ready() -> void:
	if has_key:
		_pocket = UsableBody.new()
		_pocket.name = "Pocket"
		_pocket.collision_layer = Kit.LAYER_INTERACT
		# Wider than the body, so the interaction ray finds it first.
		_pocket.add_box(Vector3(0, 0.8, 0), Vector3(1.0, 1.6, 1.0))
		_pocket.add_action("interact", "", _lift_key)
		add_child(_pocket)
		_pocket.set_action_text("interact", "")


func _physics_process(delta: float) -> void:
	super(delta)
	if _pocket == null:
		return
	var can := has_key and is_asleep()
	if can != _pocket_on:
		_pocket_on = can
		_pocket.set_action_text("interact", "Lift the key off his chain" if can else "")


func _arrive_step() -> void:
	super()
	if routine.is_empty():
		return
	var s: Dictionary = routine[_step]
	if s.has("do") and level.has_method("on_step"):
		level.on_step(self, s.do)


func _spot() -> void:
	if state != State.CHASE:
		run.record("spotted_by:" + display_name)
	super()


func _lift_key(pic: PlayerInteractionComponent) -> void:
	if not (has_key and is_asleep()):
		return
	has_key = false
	pic.get_parent().add_item("hoard_key")
	Sfx.at(self, "kenney:metalClick", global_position + Vector3(0, 1.2, 0), -10.0, 1.3)
	UsableBody.hint(pic, "The vault key, warm from his waistcoat.")
	run.record("took:hoard_key")
	run.record("lifted_key")
