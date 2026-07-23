extends Node2D
@export var speed : int
@export var direction: Vector2i
@export var iniTilePos: Vector2i
@export var tilemap: TileMapLayer
@export var sprite: Node

var currTile: Vector2i
var nextTile: Vector2i
var saveDir: Vector2i
var currDir: Vector2i
var lastDir: Vector2i

var canChangeDir: bool = true
var fixDistance = 5
var NextVia = true

func _ready() -> void:
	currTile = iniTilePos
	currDir = direction
	lastDir = currDir
	nextTile = currTile + currDir
	canChangeDir = true
	saveDir = Vector2i(0,0)
	global_position = tilemap.map_to_local(currTile)
	change_sprite()

func _process(delta: float) -> void:
	var input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	var distanceCurr = global_position.distance_to(tilemap.map_to_local(currTile))
	
	# Recieve inputs
	# When we recieve a movement input, we want to know if
	# we can move it inmediatly or not.
	# If we cant move it inmediatly, we save the input until we arrive the next tile
	if input_vector != Vector2.ZERO:
		if input_vector.x == 0 and abs(input_vector.y) != abs(currDir.y):
			if distanceCurr < fixDistance:
				changeDir(Vector2i(0, input_vector.y))
			else: 
				saveDir = Vector2i(0, input_vector.y)
		elif input_vector.y == 0 and abs(input_vector.x) != abs(currDir.x):
			if distanceCurr < fixDistance:
				changeDir(Vector2i(input_vector.x, 0))
			else: 
				saveDir = Vector2i(input_vector.x, 0)
	
	#When we know player cant move until the next tile,
	#we can put the next track always straight vertically or horizontally
	if distanceCurr > fixDistance and NextVia:
		var degress: int = 0
		if currDir.y != 0: degress = 90
		put_track(nextTile, true, degress)
	
	#When we reach the new Tile
	# Updates current tile
	# Allow the player to change direction
	# Allow to put the next track
	# And changes direction if we have a saved one
	var distanceNext = global_position.distance_to(tilemap.map_to_local(nextTile))
	if distanceNext < 2:
		currTile = nextTile
		canChangeDir = true
		NextVia = true
		changeDir(saveDir)
	
	#Moves the train forward
	global_position += Vector2(currDir) * speed * delta

# OTHER FUNCTIONS

# Changes the train direction to the especify direction
# only if the player is allowed to change it.
# We try to change the direction every time we reach a new tile
# So every time we reach a new Tile, we relocate the train and update next tile
# If we have a save direction, we change the train direction, otherwise, we dont change it.
func changeDir(newDir: Vector2i) -> void:
	if not canChangeDir: return
	global_position = tilemap.map_to_local(currTile)
	
	#To change direction, we update last directon and current direction
	#Update the last track to make it curve
	#We know player cant change Direction until the next tile, so we can put the next track
	#Also changes the train sprite and resets saved direction
	if (newDir.x != 0 || newDir.y != 0):
		lastDir = currDir
		currDir = newDir
		
		try_change_track(currTile)
		
		var degrees: int = 0
		if currDir.y != 0: degrees = 90
		put_track(currTile + currDir, true, degrees)
		
		change_sprite()
		saveDir = Vector2i(0,0)
		canChangeDir = false
		
	nextTile = currTile + currDir

# Changes the train sprite based on the trains direction
func change_sprite() -> void:
	if (currDir.y == -1):
		sprite.play("up")
	elif (currDir.y == 1):
		sprite.play("down")
	else:
		sprite.play("horizontal")
		sprite.flip_h = currDir.x == -1

#Updates a track to make it curve
#based on the last direction and the new one
func try_change_track(tile: Vector2i) -> void:
	var degrees: int = 0
	if lastDir.y != currDir.y and currDir.y == 0:
		if lastDir.y > 0:
			if currDir.x > 0: degrees = 90
			else: degrees = 0
		else:
			if currDir.x > 0: degrees = 180
			else: degrees = 270
	elif lastDir.x != currDir.x and currDir.x == 0:
		if lastDir.x > 0:
			if currDir.y > 0: degrees = 270
			else: degrees = 0
		else:
			if currDir.y > 0: degrees = 180
			else: degrees = 90
	# Coloca falso en 'straight' para que use el tile de curva (0,0)
	put_track(tile, false, degrees, true)

#If we can put a new track, we put it, or on case we need to replace a straight track with a curve one
#we not count it like a new track, so we allow placing other track at the same tile.
func put_track(tile: Vector2i, straight: bool, degrees: int, replace:bool = false):
	if not NextVia: return
	
	var tile_data = tilemap.get_cell_tile_data(tile)
	if !tile_data or replace:
		# If there isn´t any track, we create the tile data.
		if !tile_data :
			tilemap.set_cell(tile, 0, Vector2i(0, 0))
			tile_data = tilemap.get_cell_tile_data(tile)
		
		# Choose the track type
		var track : Vector2i
		if straight:  track = Vector2i(5, 0)
		else: track = Vector2i(0, 0)
		
		# Rotates the texture
		var alternative_id: int = 0
		match degrees:
			90:  alternative_id = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_TRANSPOSE
			180: alternative_id = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
			270: alternative_id = TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_TRANSPOSE
			_: alternative_id = 0 
		
		# Place the new texture on the tileMap
		tilemap.set_cell(tile, 0, track, alternative_id)
		if not replace: NextVia = false
