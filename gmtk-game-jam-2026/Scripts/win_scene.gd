extends Control

@export var lvl_num:int
@export var level_ui:Control

func _ready() -> void:
	level_ui.win_signal.connect(win)
	get_child(0).visible=false

func win():
	get_child(0).visible=true
	LevelManager.won(lvl_num)
