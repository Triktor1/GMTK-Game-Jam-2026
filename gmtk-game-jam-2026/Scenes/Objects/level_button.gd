extends Button

@export_enum("1","2","3","4","5") var scene_to_load:String

const LEVEL_1:String="res://Scenes/Levels/level_1.tscn"
const LEVEL_2:String="res://Scenes/Levels/level_2.tscn"
const LEVEL_3:String="res://Scenes/Levels/level_3.tscn"
const LEVEL_4:String="res://Scenes/Levels/level_4.tscn"
const LEVEL_5:String="res://Scenes/Levels/level_5.tscn"


func _ready() -> void:
	pressed.connect(_load_scene)


func _load_scene():
	var level:String=""
	match scene_to_load:
		"1":
			level=LEVEL_1
		"2":
			level=LEVEL_2
		"3":
			level=LEVEL_3
		"4":
			level=LEVEL_4
		"5":
			level=LEVEL_5
	if level!="":
		get_tree().change_scene_to_file(level)
