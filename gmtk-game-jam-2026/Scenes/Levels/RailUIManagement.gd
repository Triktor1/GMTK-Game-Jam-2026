extends Control

@export var railLabel : Label

var railNum : int = 12

func _ready() ->void:
	
	EventBus.connect_signal("setInitialRails" , setInitialRailNumber)
	EventBus.connect_signal("PlacedRail" , railPlaced)
	
	print ("in")


func setInitialRailNumber(railNumber : int) -> void:
	railNum = railNumber
	railLabel.text = str(railNum)

func railPlaced()-> void:
	if railNum > 0:
		if railNum <= 10:
			railLabel.modulate = Color8(255,(255 * railNum / 10),(255 * railNum / 10),255)
			railLabel.scale = (railLabel.scale * (11 - railNum)/10)
			
		railNum = railNum - 1
		railLabel.text = str(railNum)
