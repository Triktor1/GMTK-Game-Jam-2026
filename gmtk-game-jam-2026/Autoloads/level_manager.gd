extends Node

var max_level:int=1
var current_level:int=1

var levels:Array[String]=[
	"res://Scenes/Levels/level_1.tscn",
	"res://Scenes/Levels/level_2.tscn",
	"res://Scenes/Levels/level_3.tscn",
	"res://Scenes/Levels/level_4.tscn",
	"res://Scenes/Levels/level_5.tscn"
]

func won(lvl:int):
	current_level=lvl
	if lvl>max_level:
		max_level=lvl


func next_level():
	get_tree().change_scene_to_file(levels[current_level])
