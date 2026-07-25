extends Node2D
#Pause Menu
#signal paused_game
@export var pause_menu: CanvasLayer
@onready var resume_button:= $pause_menu/VBoxContainer/ResumeButton
func _ready()->void:
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
	pause_menu.visible = false
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().set_meta("from_restart", true)
		EventBus.emit("exit_pause")
		EventBus.emit("play_transition", ["restart_animation"])
		await get_tree().create_timer(1).timeout
		get_tree().reload_current_scene()


func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		pause_menu.visible = !pause_menu.visible
		resume_button.grab_focus()
		if pause_menu.visible:
			EventBus.emit("pause_game")
			get_tree().paused = true
		else:
			get_tree().paused = false
