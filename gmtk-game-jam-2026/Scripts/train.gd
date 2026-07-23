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
	var distanceNext = global_position.distance_to(tilemap.map_to_local(nextTile))
	# Recieve inputs
	# When we recieve a movement input, we want to know if
	# we can move it inmediatly or not.
	# If we cant move it inmediatly, we save the input until we arrive the next tile
	if input_vector != Vector2.ZERO:
		if input_vector.x == 0 and abs(input_vector.y) != abs(currDir.y):
			saveDir = Vector2i(0, input_vector.y)
		elif input_vector.y == 0 and abs(input_vector.x) != abs(currDir.x):
			saveDir = Vector2i(input_vector.x, 0)
	
	#We can change direction if we arrive the new tile or
	#we are some fixed distance away
	if distanceCurr < fixDistance:
		changeDir(saveDir)
	
	#When we reach the new Tile
	# Updates current and next Tiles
	# Allow the player to change direction
	# Allow to put the next track
	if distanceNext < fixDistance:
		currTile = nextTile
		canChangeDir = true
		NextVia = true
		nextTile = currTile + currDir
		changeDir(saveDir)
	
	#Moves the train forward
	global_position += Vector2(currDir) * speed * delta
	
	#Once we have moved, We can set up the next track.
	#Thats if the distance to the current Tile is enought away
	#so the player cant change the direction before the next tile
	if distanceCurr > fixDistance and NextVia:
		var degress: int = 0
		if currDir.y != 0: degress = 90
		put_track(nextTile, true, degress)

# OTHER FUNCTIONS

# Changes the train direction to the especify direction
# excepts null direction, cause the train is always moving
# or if the player has already changed the direction on the same tile
func changeDir(newDir: Vector2i) -> void:
	if not canChangeDir or (newDir.x == 0 and newDir.y == 0): return
	#To change direction, we update last directon and current direction
	#Relocate the train
	#Update the last track to make it curve
	#We know player cant change Direction until the next tile, so we can put the next track
	#Also changes the train sprite and resets saved direction
	global_position = tilemap.map_to_local(currTile)
	
	lastDir = currDir
	currDir = newDir
	
	# When we change direction, the last track changes to be a curve track
	try_change_track(currTile)
	# And we can place the next track cause the player cant change the direction on this tile
	var degrees: int = 0
	if currDir.y != 0: degrees = 90
	put_track(currTile, true, degrees)
	
	change_sprite()
	#Resets saved direction
	saveDir = Vector2i(0,0)
	canChangeDir = false
	#Updates the next tile based on the new direction
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
