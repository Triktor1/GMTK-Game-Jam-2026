extends AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.connect_signal("play_transition", _playAnim)

func _playAnim(animName: StringName)->void:
	get_parent().visible = true
	play(animName)

func _on_animation_finished(_anim_name: StringName) -> void:
	get_parent().visible = false
