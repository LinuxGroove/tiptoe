class_name JobRun
extends Node
## One night's run of a job: the events that happened, the capers finished,
## leads found and followed, times seen and caught, and the score. The level
## reports events with [method record]; everything else listens to signals.
## It needs no level, so tests drive it directly.

signal event_recorded(event: String)
signal caper_done(caper: CaperDef)
signal lead_found(lead: LeadDef)
## A lead moved on to its next step (or finished, when `text` is "").
signal lead_step(lead: LeadDef, text: String)
signal spotted_changed(count: int)
signal finished(result: Dictionary)

const TREASURE_POINTS := 1000
const CAPER_POINTS := 150
const GHOST_POINTS := 500
const TIDY_POINTS := 200
const QUICK_POINTS := 300
const SPOTTED_PENALTY := 100
const CAUGHT_PENALTY := 250

## The run in progress, for the level's pieces to report to.
static var current: JobRun

var job: JobDef
var start_id := ""
var leads_on := true
var time := 0.0
var running := false
var events: PackedStringArray = []
var capers: PackedStringArray = []
var spotted := 0
var caught := 0
var knocked := 0
var has_treasure := false
var escaped := false
## lead id -> index of its current step (steps.size() once finished).
var lead_steps := {}
var _result := {}


func setup(p_job: JobDef, p_start := "", p_leads_on := true) -> void:
	job = p_job
	start_id = p_start
	leads_on = p_leads_on
	running = true
	current = self


func _exit_tree() -> void:
	if current == self:
		current = null


func _process(delta: float) -> void:
	if running:
		time += delta


func has(event: String) -> bool:
	return event in events


## Reports something that happened. Repeats are kept once, so it's safe to
## call every time something happens.
func record(event: String) -> void:
	if not running or has(event):
		return
	events.append(event)
	match event:
		"spotted":
			pass
		"took_treasure":
			has_treasure = true
	event_recorded.emit(event)
	_check_capers(false)
	_check_leads(event)


## Someone saw the player: counted every time, recorded as an event once.
func add_spotted() -> void:
	if not running:
		return
	spotted += 1
	spotted_changed.emit(spotted)
	record("spotted")


func add_caught() -> void:
	if not running:
		return
	caught += 1
	record("caught")


## Something got knocked over or broken.
func add_knocked() -> void:
	if not running:
		return
	knocked += 1
	record("knocked_over")


func drop_treasure() -> void:
	has_treasure = false


## The player left the grounds by `method` (door, window, garden...). With
## the treasure it ends the run; without it, it's just leaving.
func escape(method: String) -> Dictionary:
	if not running:
		return _result
	record("escaped")
	record("escaped_by:%s" % method)
	if method != "door":
		record("escaped_not_door")
	escaped = true
	if has_treasure:
		record("escaped_with_treasure")
		if spotted == 0:
			record("ghost")
		if knocked == 0:
			record("tidy")
		if time <= job.par_time:
			record("quick")
	_check_capers(true)
	return finish()


## Ends the run (escaping or giving up) and works out the score.
func finish() -> Dictionary:
	if not running:
		return _result
	running = false
	var found := []
	for id in lead_steps:
		found.append(id)
	var score := 0
	var ratings := []
	if escaped and has_treasure:
		score += TREASURE_POINTS
		if spotted == 0:
			ratings.append("Ghost")
			score += GHOST_POINTS
		if knocked == 0:
			ratings.append("Tidy")
			score += TIDY_POINTS
		if time <= job.par_time:
			ratings.append("Quick")
			score += QUICK_POINTS
		score += int(maxf(0.0, job.par_time - time))
	score += capers.size() * CAPER_POINTS
	score -= spotted * SPOTTED_PENALTY + caught * CAUGHT_PENALTY
	_result = {
		"job": job.id,
		"start": start_id,
		"escaped": escaped,
		"treasure": has_treasure and escaped,
		"time": time,
		"spotted": spotted,
		"caught": caught,
		"knocked": knocked,
		"capers": Array(capers),
		"leads": found,
		"ratings": ratings,
		"score": maxi(0, score),
	}
	finished.emit(_result)
	return _result


func result() -> Dictionary:
	return _result


func is_caper_done(caper_id: String) -> bool:
	return caper_id in capers


## The current step's text of a lead, or "" if it isn't found or is finished.
func lead_text(lead: LeadDef) -> String:
	if not lead_steps.has(lead.id):
		return ""
	var i: int = lead_steps[lead.id]
	if i >= lead.steps.size():
		return ""
	return lead.steps[i][0]


func _check_capers(at_escape: bool) -> void:
	for c in job.capers:
		if c.id in capers or c.on_escape != at_escape:
			continue
		if not has(c.done_on):
			continue
		var ok := true
		for n in c.needs:
			if not has(n):
				ok = false
		for n in c.never:
			if has(n):
				ok = false
		if ok:
			capers.append(c.id)
			caper_done.emit(c)


func _check_leads(event: String) -> void:
	for l in job.leads:
		if not lead_steps.has(l.id):
			if l.found_on == event:
				lead_steps[l.id] = 0
				lead_found.emit(l)
				_advance_lead(l, true)
			continue
		_advance_lead(l, false)


## Skips the lead past every step whose event has already happened, so a
## step done before the lead was found doesn't hold it up.
func _advance_lead(l: LeadDef, just_found: bool) -> void:
	var i: int = lead_steps[l.id]
	var start := i
	while i < l.steps.size() and has(l.steps[i][1]):
		i += 1
	lead_steps[l.id] = i
	if just_found or i != start:
		lead_step.emit(l, lead_text(l))
