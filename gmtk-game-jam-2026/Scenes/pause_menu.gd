extends CanvasLayer
@export var resume_button: Button

var pausedBefore: bool = false

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		visible = !visible
		resume_button.grab_focus()
		if visible:
			EventBus.emit("pause_game")
			pausedBefore = get_tree().paused
			get_tree().paused = true
		else:
			if not pausedBefore: get_tree().paused = false
			pausedBefore = false
