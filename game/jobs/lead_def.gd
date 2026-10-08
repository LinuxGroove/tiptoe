class_name LeadDef
extends Resource
## A lead: a guided route found in the world (a note, an overheard call).
## Once found it shows one step at a time; each step ends on an event.

@export var id := ""
@export var title := ""
## The event that finds the lead, like "read:pizza_flyer".
@export var found_on := ""
## [[text, event], ...]: what to do next, and the event that finishes it.
@export var steps: Array = []


static func make(p_id: String, p_title: String, p_found_on: String, p_steps: Array) -> LeadDef:
	var l := LeadDef.new()
	l.id = p_id
	l.title = p_title
	l.found_on = p_found_on
	l.steps = p_steps
	return l
