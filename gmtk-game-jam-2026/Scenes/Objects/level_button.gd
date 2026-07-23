extends Button

@export_enum("1") var scene_to_load:String

const LEVEL_1:String="res://Scenes/Levels/level_1.tscn"


func _ready() -> void:
	pressed.connect(_load_scene)


func _load_scene():
	var level:String=""
	match scene_to_load:
		"1":
			level=LEVEL_1
	if level!="":
		get_tree().change_scene_to_file(level)
