extends Control

@export_group("NODES")
@export var railLabel : RichTextLabel

@export var reachEndLabel : RichTextLabel
@export var passengersLabel : RichTextLabel
@export var cargoLabel : RichTextLabel

@export var railUiIm : Texture
@export var reachEndUiIm : Texture
@export var passengerUiIm : Texture
@export var cargoUiIm : Texture

@export_group("VARIABLES")
@export var railNum : int = 12

@export_subgroup("ACTIVE OBJECTIVES")

@export var ReachEndObjective : bool
@export var PassengerObjective : bool
@export var CargoObjective : bool

@export_subgroup("OBJECTIVE INFO")
@export var passengerExactNum : bool
@export var requiredPassengerNum : int;
var currentPassengers : int = 0

@export var cargoExactNum : bool
@export var requiredCargoNum : int
var currentCargo:int = 0

var RailImage : String
var ReachEndImage : String
var PassengerImage : String
var CargoImage : String

var ReachEndComplete : bool = false
var PassengerComplete : bool = false
var CargoComplete : bool = false
var HasAlreadyLost : bool = false


signal win_signal

func _ready() ->void:
	
	EventBus.connect_signal("UISetup" , setupUI)
	#Rail
	EventBus.connect_signal("PlacedRail" , railPlaced)
	#Passenger
	EventBus.connect_signal("newPassengers" , passengerPicked)
	#Cargo
	EventBus.connect_signal("CargoPicked" , cargoPicked)
	#Reach end
	EventBus.connect_signal("ReachedEnd",reachedEnd)
	
	RailImage = "[img=64x64]" + railUiIm.resource_path + "[/img]"
	ReachEndImage = "[img=32x32]" + reachEndUiIm.resource_path + "[/img]"
	PassengerImage = "[img=32x32]" + passengerUiIm.resource_path + "[/img]"
	CargoImage = "[img=32x32]" + cargoUiIm.resource_path + "[/img]"
	
	reachEndLabel.text = ReachEndImage + "[color=#white]" + "Reach the end!" + "[/color]"
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

func reachedEnd () -> void:
	if ReachEndObjective:
		ReachEndComplete = true
		reachEndLabel.text = ReachEndImage + "[color=#" + Color(0.847, 0.706, 0.0, 1.0).to_html()  + "]"+ "Reach the end!" + "[/color]"
		checkObjectives()
	

func passengerPicked( passengerNum : int) -> void:
	currentPassengers += passengerNum
	passengerUpdate()
	checkObjectives()

func cargoPicked() -> void:
	currentCargo += 1
	cargoUpdate()
	checkObjectives()

func passengerUpdate() -> void:
	
	var currentColor = Color(1 , 1 , 1 , 1)
	
	if PassengerObjective:
		if currentPassengers >= requiredPassengerNum:
			# Color and objective
			if !passengerExactNum || (passengerExactNum && currentPassengers == requiredPassengerNum):
				currentColor = Color(0.847, 0.706, 0.0, 1.0)
				PassengerComplete = true
			elif passengerExactNum && currentPassengers > requiredPassengerNum:
				currentColor = Color(1.0, 0.0, 0.0, 1.0)
				PassengerComplete = false
				HasAlreadyLost = true
			 
		#Text
		if passengerExactNum:
			passengersLabel.text= PassengerImage + "[color=#" + currentColor.to_html() + "]"  + str(currentPassengers) + "/" + str(requiredPassengerNum) + "[font_size=15] (Pick only " + str(requiredPassengerNum) + "!) [/font_size]" + "[/color]"
		else:
			passengersLabel.text= PassengerImage + "[color=#" + currentColor.to_html() + "]"  + str(currentPassengers) + "/" + str(requiredPassengerNum) + "[/color]"
	else:
		passengersLabel.visible = false
func cargoUpdate() -> void:
	
	var currentColor = Color(1 , 1 , 1 , 1)
	
	if CargoObjective:
		if currentCargo >= requiredCargoNum:
			# Color and objective
			if !cargoExactNum || (cargoExactNum && currentCargo == requiredCargoNum):
				currentColor = Color(0.847, 0.706, 0.0, 1.0)
				CargoComplete = true
			elif cargoExactNum && currentCargo > requiredCargoNum:
				currentColor = Color(1.0, 0.0, 0.0, 1.0)
				CargoComplete = false
				HasAlreadyLost = true
		#Text
		if cargoExactNum:
			cargoLabel.text= CargoImage + "[color=#" + currentColor.to_html() + "]"  + str(currentCargo) + "/" + str(requiredCargoNum) + "[font_size=15] (Pick only " + str(requiredCargoNum) + "!) [/font_size]" + "[/color]"
		else:
			cargoLabel.text= CargoImage + "[color=#" + currentColor.to_html() + "]"  + str(currentCargo) + "/" + str(requiredCargoNum) + "[/color]"
	else:
		cargoLabel.visible = false
	
#THIS FUNCTION IS CALLED WHEN THE LEVEL SHOULD BE OVER, AND IT CHECKS IF THE PLAYER WON OR LOST
func checkObjectives() -> void:
	
	#Check the state of the objectives
	var activeObjectivesNum = 0
	var completedObjectives = 0
	
	if ReachEndObjective:
		activeObjectivesNum += 1
		if ReachEndComplete:
			completedObjectives += 1
	if PassengerObjective:
		activeObjectivesNum += 1
		if PassengerComplete:
			completedObjectives += 1
	if CargoObjective:
		activeObjectivesNum += 1
		if CargoComplete:
			completedObjectives += 1
	
	#Level end
	
	if ReachEndObjective:
		if ReachEndComplete:
			if activeObjectivesNum == completedObjectives && !HasAlreadyLost:
				win_signal.emit()
		else:
			EventBus.emit("withoutTracks", [])
			pass
	else:
		if activeObjectivesNum == completedObjectives:
			if !HasAlreadyLost:
				win_signal.emit()
			else:
				EventBus.emit("withoutTracks", [])
