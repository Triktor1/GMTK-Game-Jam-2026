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
var canChangeDir: bool
#Distance to the currTile that makes train changes its direction inmediatly
var fixDistance = 5

func _ready() -> void:
	#Init current Tile and the next one
	#Also init current direction
	currTile = iniTilePos
	currDir = direction
	nextTile = currTile + currDir
	canChangeDir = true
	#We save (0,0) as no direction changes
	saveDir = Vector2i(0,0)
	#Put the train at the beginning of its journey
	global_position = tilemap.map_to_local(currTile)
	change_sprite()

func _process(delta: float) -> void:
	var input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	
	var distanceCurr = global_position.distance_to(tilemap.map_to_local(currTile))
	#Train´s direction changes
	if input_vector != Vector2.ZERO:
		#The train can´t go backwards or forward
		#If the train is only a few pixels away, changes inmediatly the train´s dir and relocates it.
		#Otherwise, saves the new direction.
		if input_vector.x == 0 and abs(input_vector.y) != abs(currDir.y):
			if distanceCurr < fixDistance :
				changeDir(Vector2i(0, input_vector.y))
			else: saveDir = Vector2i(0, input_vector.y)
		elif input_vector.y == 0 and abs(input_vector.x) != abs(currDir.x):
			if distanceCurr < fixDistance :
				changeDir(Vector2i(input_vector.x, 0))
			else: saveDir = Vector2i(input_vector.x, 0)
	#When you arrive the next Tile
	#Updates current and next Tile indexes
	#Repositions the train on the new tile (just in case)
	#If there´s some saved dir, updates train´s dir
	var distanceNext = global_position.distance_to(tilemap.map_to_local(nextTile))
	if distanceNext < 2:
		currTile = nextTile
		canChangeDir = true
		changeDir(saveDir)
	#Ejecutar cambio de posición
	global_position += currDir * speed * delta

#If the player has been changing the direction
#Updates it
func changeDir(newDir: Vector2i) -> void:
	global_position = tilemap.map_to_local(currTile)
	if (newDir.x != 0 || newDir.y != 0) && canChangeDir:
			currDir = newDir
			change_sprite()
			saveDir = Vector2i(0,0)
			#If you make any move you need to wait the next tile to do another
			canChangeDir = false
	nextTile = currTile + currDir

func change_sprite() -> void:
	#Change sprite depending on new direction
	if (currDir.y == -1):
		sprite.play("up")
	elif (currDir.y == 1):
		sprite.play("down")
	else:
		sprite.play("horizontal")
		sprite.flip_h = currDir.x == -1
