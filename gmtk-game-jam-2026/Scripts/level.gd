extends Node2D
#Pause Menu
#signal paused_game
@export var pause_menu: CanvasLayer
@onready var resume_button:= $pause_menu/VBoxContainer/ResumeButton
func _ready()->void:y_sort_enabled=true
func _on_resume_requested():
	pause_menu.visible = false
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
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
