extends Button

func _ready():
	pressed.connect(_restart)


func _restart():
	get_tree().paused = false
	get_tree().set_meta("from_restart", true)
	EventBus.emit("exit_pause")
	EventBus.emit("play_transition", ["restart_animation"])
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene()
