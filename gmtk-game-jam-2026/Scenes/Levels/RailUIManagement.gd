extends Control

@export var railLabel : Label

var railNum : int  =40

func _ready() ->void:
	
	EventBus.connect_signal("setInitialRails" , setInitialRailNumber)
	EventBus.connect_signal("PlacedRail" , railPlaced)
	
	print ("in")


func setInitialRailNumber(railNumber : int) -> void:
	railNum = railNumber
	railLabel.text = str(railNum)

func railPlaced()-> void:
	if railNum > 0:
		railNum = railNum - 1
		railLabel.text = str(railNum)
