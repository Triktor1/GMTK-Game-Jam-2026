extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().has_meta("from_level"):
		await get_tree().process_frame
		EventBus.emit("play_transition", ["level_transition_out"])
		get_tree().remove_meta("from_level")
