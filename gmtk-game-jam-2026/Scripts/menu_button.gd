extends Button

@export_file("*.tscn") var menu_path: String

func _ready():
	pressed.connect(_back)

func _back():
	get_tree().paused = false
	get_tree().change_scene_to_file(menu_path)
	EventBus.emit("exit_pause")
