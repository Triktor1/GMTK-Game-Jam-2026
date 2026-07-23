extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().call_group("level", "_on_resume_requested")
	EventBus.emit("exit_pause")
