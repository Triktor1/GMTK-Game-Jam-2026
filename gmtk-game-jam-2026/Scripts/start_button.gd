extends Button

@export var startScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_startGame)

func _startGame() -> void:
	AudioManager.stop()
	EventBus.emit("start_game")
	get_tree().change_scene_to_packed(startScene)
