extends AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.connect_signal("play_transition", _playAnim)

func _playAnim(name: StringName)->void:
	get_parent().visible = true
	play(name)

func _on_animation_finished(anim_name: StringName) -> void:
	get_parent().visible = false
