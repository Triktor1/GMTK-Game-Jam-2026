extends Node2D
#Pause Menu
#signal paused_game

@export var showLevelCanvas: CanvasLayer

func _ready()->void:
	if showLevelCanvas: showLevelCanvas.appear()
	else: get_tree().paused = false
	
	y_sort_enabled=true
	if get_tree().has_meta("from_restart"):
		await get_tree().process_frame
		EventBus.emit("play_transition", ["restart_animation_out"])
		get_tree().remove_meta("from_restart")
	elif get_tree().has_meta("from_level"):
		await get_tree().process_frame
		EventBus.emit("play_transition", ["level_transition_out"])
		get_tree().remove_meta("from_level")

func _on_resume_requested():
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().set_meta("from_restart", true)
		EventBus.emit("exit_pause")
		EventBus.emit("play_transition", ["restart_animation"])
		await get_tree().create_timer(1).timeout
		get_tree().reload_current_scene()
