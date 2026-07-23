extends Button

func _ready():
	pressed.connect(_restart)

func _restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
	EventBus.emit("exit_pause")
