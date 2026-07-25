extends Control

@onready var grid := $CanvasLayer/GridContainer
@onready var main_menu := $CanvasLayer/MainMenuButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var levels:Array=grid.get_children()
	for i in range(0,LevelManager.max_level):
		levels[i].unlock()
