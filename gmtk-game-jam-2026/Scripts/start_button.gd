extends BaseButton

@export var startScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_startGame)
	grab_focus()

func _startGame() -> void:
	AudioManager.stop()
	EventBus.emit("start_game")
	get_tree().set_meta("from_level", true)
	EventBus.emit("exit_pause")
	EventBus.emit("play_transition", ["level_transition"])
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(startScene)
