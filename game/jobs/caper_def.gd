class_name CaperDef
extends Resource
## One caper: a short goal beyond the treasure. It's finished when the run
## records the event `done_on`, as long as every event in `needs` has
## happened and none in `never` has. Capers with `on_escape` are only judged
## when the player gets away with the treasure (like "never seen").

@export var id := ""
@export var title := ""
## How to do it, shown in the capers list once the player asks for a hint.
@export var hint := ""
@export var done_on := ""
@export var needs := PackedStringArray()
@export var never := PackedStringArray()
@export var on_escape := false


static func make(p_id: String, p_title: String, p_hint: String, p_done_on: String,
		p_needs := PackedStringArray(), p_never := PackedStringArray(), p_on_escape := false) -> CaperDef:
	var c := CaperDef.new()
	c.id = p_id
	c.title = p_title
	c.hint = p_hint
	c.done_on = p_done_on
	c.needs = p_needs
	c.never = p_never
	c.on_escape = p_on_escape
	return c
