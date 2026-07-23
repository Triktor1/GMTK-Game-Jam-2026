extends Node2D
@export var speed : int
@export var direction: Vector2i
@export var iniTilePos: Vector2i
@export var tilemap: TileMapLayer
@export var sprite: Node

var currTile: Vector2i
# Saves the last input action which makes train changes direction
var saveDir: Vector2i
# Current train direction
var currDir: Vector2i
# Next tile´s index
var nextTile: Vector2i

func _ready() -> void:
	#Init current Tile and the next one
	#Also init current direction
	currTile = iniTilePos
	currDir = direction
	nextTile = currTile + currDir
	#We save (0,0) as no direction changes
	saveDir = Vector2i(0,0)
	#Put the train at the beginning of its journey
	global_position = tilemap.map_to_local(currTile)
	change_sprite()

func _process(delta: float) -> void:
	var input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	
	#Train´s direction changes
	if input_vector != Vector2.ZERO:
		#The train can´t go backwards
		if input_vector.x == 0 and input_vector.y != -currDir.y:
			saveDir = Vector2i(0, input_vector.y)
		elif input_vector.y == 0 and input_vector.x != -currDir.x:
			saveDir = Vector2i(input_vector.x, 0)
	
	#When you arrive the next Tile
	#Updates current and next Tile indexes
	#Repositions the train on the new tile (just in case)
	var distance = global_position.distance_to(tilemap.map_to_local(nextTile))
	if distance < 2:
		global_position = tilemap.map_to_local(nextTile)
		#If the player has been changing the direction
		#Updates it
		if saveDir.x != 0 || saveDir.y != 0:
			currDir = saveDir
			change_sprite()
			saveDir = Vector2i(0,0)
		currTile = nextTile
		nextTile += currDir
		
	#Ejecutar cambio de posición
	global_position += currDir * speed * delta

func change_sprite() -> void:
	#Change sprite depending on new direction
	if (currDir.y == -1):
		sprite.play("up")
	elif (currDir.y == 1):
		sprite.play("down")
	else:
		sprite.play("horizontal")
		sprite.flip_h = currDir.x == -1
