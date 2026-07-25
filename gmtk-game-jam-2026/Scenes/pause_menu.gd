extends CanvasLayer
@export var resume_button: Button

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		visible = !visible
		resume_button.grab_focus()
		if visible:
			EventBus.emit("pause_game")
			get_tree().paused = true
		else:
			get_tree().paused = false
