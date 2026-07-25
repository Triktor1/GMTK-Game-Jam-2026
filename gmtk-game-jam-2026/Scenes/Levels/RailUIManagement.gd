extends Control

@export var railLabel : RichTextLabel
@export var passengersLabel : RichTextLabel
@export var cargoLabel : RichTextLabel

@export var railUiIm : Texture
@export var passengerUiIm : Texture
@export var cargoUiIm : Texture

@export var railNum : int = 12

@export var passengerExactNum : bool
@export var requiredPassengerNum : int;
var currentPassengers : int = 0

@export var cargoExactNum : bool
@export var requiredCargoNum : int
var currentCargo:int = 0

var RailImage : String
var PassengerImage : String
var CargoImage : String

func _ready() ->void:
	
	EventBus.connect_signal("UISetup" , setupUI)
	#Rail
	EventBus.connect_signal("PlacedRail" , railPlaced)
	#Passenger
	EventBus.connect_signal("newPassengers" , passengerPicked)
	#Cargo
	EventBus.connect_signal("CargoPicked" , cargoPicked)
	
	RailImage = "[img=64x64]" + railUiIm.resource_path + "[/img]"
	PassengerImage = "[img=32x32]" + passengerUiIm.resource_path + "[/img]"
	CargoImage = "[img=32x32]" + cargoUiIm.resource_path + "[/img]"
	
	passengerUpdate()
	cargoUpdate()
	
	
func setupUI(railNumber : int , 
passengerRequirement : int , cargoRequirement : int , 
passengerExactNumber : bool , cargoExactNumber : bool) -> void:
	railNum = railNumber
	railLabel.text = str(railNum)

func railPlaced()-> void:
	var currentColor = Color(1 , 1 , 1 , 1)
	if railNum > 0:
		if railNum <= 10:
			var newValue = 1.0 * railNum / 10
			currentColor = Color(1.0,newValue,newValue,1)
			
		railNum = railNum - 1
		railLabel.text = RailImage +  "[color=#" + currentColor.to_html() + "]" + str(railNum) + "[/color]"
	if railNum == 0: EventBus.emit("withoutTracks", [])

func passengerPicked( passengerNum : int) -> void:
	currentPassengers += passengerNum
	passengerUpdate()

func cargoPicked() -> void:
	currentCargo += 1
	cargoUpdate()

func passengerUpdate() -> void:
	
	var currentColor = Color(1 , 1 , 1 , 1)
	
	if requiredPassengerNum > 0:
		
		if currentPassengers >= requiredPassengerNum:
			# Color and objective
			if !passengerExactNum || (passengerExactNum && currentPassengers == requiredPassengerNum):
				currentColor = Color(0.847, 0.706, 0.0, 1.0)
			elif passengerExactNum && currentPassengers > requiredPassengerNum:
				currentColor = Color(1.0, 0.0, 0.0, 1.0)
			 
		#Text
		if passengerExactNum:
			passengersLabel.text= PassengerImage + "[color=#" + currentColor.to_html() + "]"  + str(currentPassengers) + "/" + str(requiredPassengerNum) + "[font_size=15] (Pick only " + str(requiredPassengerNum) + "!) [/font_size]" + "[/color]"
		else:
			passengersLabel.text= PassengerImage + "[color=#" + currentColor.to_html() + "]"  + str(currentPassengers) + "/" + str(requiredPassengerNum) + "[/color]"

func cargoUpdate() -> void:
	
	var currentColor = Color(1 , 1 , 1 , 1)
	
	if requiredCargoNum > 0:
		if currentCargo >= requiredCargoNum:
			# Color and objective
			if !cargoExactNum || (cargoExactNum && currentCargo == requiredCargoNum):
				currentColor = Color(0.847, 0.706, 0.0, 1.0)
			elif cargoExactNum && currentCargo > requiredCargoNum:
				currentColor = Color(1.0, 0.0, 0.0, 1.0)
			 
		#Text
		if cargoExactNum:
			cargoLabel.text= CargoImage + "[color=#" + currentColor.to_html() + "]"  + str(currentCargo) + "/" + str(requiredCargoNum) + "[font_size=15] (Pick only " + str(requiredCargoNum) + "!) [/font_size]" + "[/color]"
		else:
			cargoLabel.text= CargoImage + "[color=#" + currentColor.to_html() + "]"  + str(currentCargo) + "/" + str(requiredCargoNum) + "[/color]"
