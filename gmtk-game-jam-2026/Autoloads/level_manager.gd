extends Node

var max_level:int=1
var current_level:int=1

var levels:Array[String]=[
	"res://Scenes/Levels/level_1.tscn",
	"res://Scenes/Levels/level_2.tscn",
	"res://Scenes/Levels/level_3.tscn",
	"res://Scenes/Levels/level_4.tscn",
	"res://Scenes/Levels/level_5.tscn",
	"res://Scenes/Levels/level_6.tscn",
	"res://Scenes/Levels/level_7.tscn",
	"res://Scenes/Levels/level_8.tscn",
	"res://Scenes/Levels/level_13.tscn",
	"res://Scenes/Levels/level_14.tscn",
	"res://Scenes/Levels/end_scene.tscn"
]

func won(lvl:int):
	current_level=lvl
	if lvl==max_level:
		max_level=lvl+1


func next_level():
	get_tree().paused = false
	EventBus.emit("exit_pause")
	get_tree().set_meta("from_level", true)
	EventBus.emit("play_transition", ["level_transition"])
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file(levels[current_level])
