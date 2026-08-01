extends Button

@export_file("*.tscn") var menu_path: String

func _ready():
	pressed.connect(_back)

func _back():
	get_tree().paused = false
	EventBus.emit("exit_pause")
	get_tree().set_meta("from_level", true)
	EventBus.emit("play_transition", ["level_transition"])
	await get_tree().create_timer(2.3).timeout
	get_tree().change_scene_to_file(menu_path)
