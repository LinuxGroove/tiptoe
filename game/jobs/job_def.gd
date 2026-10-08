class_name JobDef
extends Resource
## One job: a building, its treasure, its capers and leads, where the player
## can start and what mastery unlocks.

@export var id := ""
@export var title := ""
@export var place := ""
@export var treasure := ""
## The treasure's item in the bag ("trophy"): getting out with it wins.
@export var treasure_item := ""
## Our night music for this job (assets/audio/music/<music>.ogg), or "" for
## the shared night loop.
@export var music := ""
## A paragraph for the briefing.
@export var blurb := ""
@export var scene := ""
@export var capers: Array[CaperDef] = []
@export var leads: Array[LeadDef] = []
## [{"id", "title", "mastery"}]: start points and the mastery that opens them.
@export var start_points: Array = []
## [{"id", "title", "mastery"}]: gadgets and the mastery that opens them.
@export var gadgets: Array = []
## A run under this many seconds earns the Quick rating.
@export var par_time := 300.0
## False for jobs shown on the board but not built yet.
@export var playable := true


func caper(caper_id: String) -> CaperDef:
	for c in capers:
		if c.id == caper_id:
			return c
	return null


func lead(lead_id: String) -> LeadDef:
	for l in leads:
		if l.id == lead_id:
			return l
	return null


## The start points open at a mastery level.
func open_start_points(mastery: int) -> Array:
	return start_points.filter(func(s): return int(s.mastery) <= mastery)


func open_gadgets(mastery: int) -> Array:
	return gadgets.filter(func(g): return int(g.mastery) <= mastery)


## What reaching a mastery level unlocks, as short lines for the results.
func unlocks_at(level: int) -> PackedStringArray:
	var out := PackedStringArray()
	for s in start_points:
		if int(s.mastery) == level:
			out.append("New start point: %s" % s.title)
	for g in gadgets:
		if int(g.mastery) == level:
			out.append("New gadget: %s" % g.title)
	return out
