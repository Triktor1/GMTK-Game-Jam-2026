extends Control

@onready var grid := $CanvasLayer/GridContainer
@onready var main_menu := $CanvasLayer/MainMenuButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button: Button in grid.get_children():
		button.focus_neighbor_bottom = main_menu.get_path()

		button.focus_entered.connect(func():
			main_menu.focus_neighbor_top = button.get_path())
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
