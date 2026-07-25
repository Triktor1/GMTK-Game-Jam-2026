extends AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.connect_signal("play_transition", _playAnim)
	_playAnim("restart_animation")

func _playAnim(name: StringName)->void:
	play(name)
