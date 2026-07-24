extends Control

@export var railLabel : Label

var railNum : int = 12
var storedScale : int


func _ready() ->void:
	EventBus.connect_signal("setInitialRails" , setInitialRailNumber)
	EventBus.connect_signal("PlacedRail" , railPlaced)

func setInitialRailNumber(railNumber : int) -> void:
	railNum = railNumber
	railLabel.text = str(railNum)

func railPlaced()-> void:
	if railNum > 0:
		if railNum <= 10:
			railLabel.self_modulate = Color8(255,(255 * railNum / 10),(255 * railNum / 10),255)
			
			
		railNum = railNum - 1
		railLabel.text = str(railNum)
