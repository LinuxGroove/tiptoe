class_name GameConfig
extends RefCounted
## Game-wide constants: identity, version, input map and setting defaults.

const GAME_ID := "tiptoe"

const SETTING_DEFAULTS := {
	"online": {
		"enabled": true,
		"host": OnlineServer.HOST,
		"port": OnlineServer.PORT,
		"scheme": OnlineServer.SCHEME,
		"server_key": OnlineServer.SERVER_KEY,
	},
	"tutorial": {
		"welcomed": false,
		"seen": "",
	},
	"play": {
		# Leads give step-by-step hints for a route once they're switched on.
		"leads": true,
		# Rings on screen for every noise, for players who can't hear them.
		"noise_rings": true,
		"invert_look": false,
		"mouse_sensitivity": 0.25,
		"stick_sensitivity": 2.0,
		"head_bob": 0.7,
		"toggle_crouch": true,
	},
}

## Every in-game action, with keyboard and controller bindings (see LGInput).
## The names are Cogito's, so its player, interactions and inventory read them
## as they are.
const ACTIONS := {
	"forward": ["key:W", "axis:ly-"],
	"back": ["key:S", "axis:ly+"],
	"left": ["key:A", "axis:lx-"],
	"right": ["key:D", "axis:lx+"],
	"jump": ["key:Space", "joy:a"],
	"crouch": ["key:Ctrl", "key:C", "joy:b"],
	"sprint": ["key:Shift", "joy:ls"],
	"menu": ["key:Escape", "joy:start"],
	"free_look": ["key:Alt"],
	# Use what you're looking at: doors, drawers, switches, notes, pick-ups.
	"interact": ["key:F", "joy:x"],
	# Carry or drag it, or pick its lock.
	"interact2": ["key:R", "joy:y"],
	"lean_left": ["key:Q", "joy:lb"],
	"lean_right": ["key:E", "joy:rb"],
	# Use the gadget in hand, or throw what you're carrying.
	"action_primary": ["mouse:left", "axis:rt+"],
	"action_secondary": ["mouse:right", "axis:lt+"],
	"inventory": ["key:Tab", "key:I", "joy:back"],
	"inventory_move_item": ["mouse:left", "joy:x"],
	"inventory_use_item": ["mouse:right", "joy:a"],
	"inventory_drop_item": ["key:G", "joy:y"],
	"inventory_assign_item": ["mouse:middle", "joy:rs"],
	"quickslot_1": ["key:1"],
	"quickslot_2": ["key:2"],
	"quickslot_3": ["key:3"],
	"quickslot_4": ["key:4"],
	"quickslot_prev_wieldable": ["mouse:wheel_up", "joy:left"],
	"quickslot_next_wieldable": ["mouse:wheel_down", "joy:right"],
	"reload": ["key:T"],
	"ui_next_tab": ["key:E", "joy:rb"],
	"ui_prev_tab": ["key:Q", "joy:lb"],
	"capers": ["key:J", "joy:down"],
	"leads": ["key:L", "joy:up"],
}


static func version() -> String:
	return LGVersion.current()
