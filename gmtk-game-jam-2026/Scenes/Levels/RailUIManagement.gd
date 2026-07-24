extends Control

@export var railLabel : RichTextLabel

var railNum : int = 12
var storedScale : int


func _ready() ->void:
	EventBus.connect_signal("setInitialRails" , setInitialRailNumber)
	EventBus.connect_signal("PlacedRail" , railPlaced)

func setInitialRailNumber(railNumber : int) -> void:
	railNum = railNumber
	railLabel.text = str(railNum)

func railPlaced()-> void:
	
	var currentColor = Color(1 , 1 , 1 , 1)
	if railNum > 0:
		if railNum <= 10:
			var newValue = 1.0 * railNum / 10
			currentColor = Color(1.0,newValue,newValue,1)
			
		railNum = railNum - 1
		railLabel.text = "[img=64x64]res://Assets/Placeholders/RailUI.png[/img]" +  "[color=#" + currentColor.to_html() + "]" + str(railNum) + "[/color]"
	else: EventBus.emit("withoutTracks", [])