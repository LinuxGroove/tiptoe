extends Node
## Boots the game: settings, input map, theme and window, then the title screen.
##
## Developer shortcuts (after `--`):
##   --job=maple_close   skip the menus and start that job
##   --start=garden      with --job: the start point
##   --set=video/fullscreen=false   any setting, for one run

func _ready() -> void:
	LGSettings.register_defaults(GameConfig.SETTING_DEFAULTS)
	LGInput.register_actions(GameConfig.ACTIONS, float(LGSettings.get_value("input", "stick_deadzone")))
	LGInput.extend_ui_actions()
	LGTheme.apply(get_tree().root, 22)
	get_window().title = "Tiptoe"
	var args := OS.get_cmdline_user_args()
	for a in args:
		if a.begins_with("--job="):
			var start := ""
			for b in args:
				if b.begins_with("--start="):
					start = b.trim_prefix("--start=")
			Jobs.play(a.trim_prefix("--job="), start)
			return
	LGScenes.change_scene("res://game/ui/title.tscn")
