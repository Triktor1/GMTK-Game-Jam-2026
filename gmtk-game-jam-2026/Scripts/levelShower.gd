extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startLevel()

func startLevel() -> void:
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.keycode == KEY_ESCAPE:
		get_tree().paused = false
		disappear()

func appear() -> void: visible = true
func disappear() -> void: visible = false
