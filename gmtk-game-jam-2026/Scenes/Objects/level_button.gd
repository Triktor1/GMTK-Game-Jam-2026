extends Button

@export_enum("1","2","3","4","5","6","7","8","9","10","11","12") var scene_to_load:String

var locked:bool=true

const LEVEL_1:String="res://Scenes/Levels/level_1.tscn"
const LEVEL_2:String="res://Scenes/Levels/level_2.tscn"
const LEVEL_3:String="res://Scenes/Levels/level_3.tscn"
const LEVEL_4:String="res://Scenes/Levels/level_4.tscn"
const LEVEL_5:String="res://Scenes/Levels/level_5.tscn"
const LEVEL_6:String="res://Scenes/Levels/level_6.tscn"
const LEVEL_7:String="res://Scenes/Levels/level_7.tscn"
const LEVEL_8:String="res://Scenes/Levels/level_8.tscn"
const LEVEL_9:String="res://Scenes/Levels/Level_10.tscn"
const LEVEL_10:String="res://Scenes/Levels/Level_13.tscn"
const LEVEL_11:String="res://Scenes/Levels/Level_14.tscn"

func _ready() -> void:
	pressed.connect(_load_scene)
	modulate=Color(0.5, 0.5, 0.5, 1)


func _load_scene():
	if !locked:
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
			"6":
				level=LEVEL_6
			"7":
				level=LEVEL_7
			"8":
				level=LEVEL_8
			"9":
				level=LEVEL_9
			"10":
				level=LEVEL_10
			"11":
				level=LEVEL_11
			
		if level!="":
			get_tree().set_meta("from_level", true)
			EventBus.emit("play_transition", ["level_transition"])
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_file(level)


func unlock():
	locked=false
	modulate=Color(1.0, 1.0, 1.0, 1.0)
