extends Control

@export var lvl_num:int

func win():
	LevelManager.won(lvl_num)
