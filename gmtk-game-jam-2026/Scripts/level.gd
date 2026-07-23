extends Node2D

#Pause Menu
@export var pause_menu: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_resume_requested():
	pause_menu.visible = false
	get_tree().paused = false


func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		pause_menu.visible = !pause_menu.visible
		if pause_menu.visible:
			get_tree().paused = true
		else:
			get_tree().paused = false
