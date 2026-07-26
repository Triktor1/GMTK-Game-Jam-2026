extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().has_meta("from_pause"):
		await get_tree().process_frame
		EventBus.emit("play_transition", ["level_transition_out"])
		get_tree().remove_meta("from_pause")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
