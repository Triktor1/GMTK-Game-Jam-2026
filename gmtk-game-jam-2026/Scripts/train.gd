extends Node2D
@export var speed : int
@export var direction: Vector2i
@export var iniTilePos: Vector2i
@export var iniPosOffset: Vector2
@export var tilemapTracks: TileMapLayer
@export var tilemapCargos: TileMapLayer
@export var tilemapLevers: TileMapLayer
@export var tilemapPassengers: TileMapLayer
@export var tilemapPortals: TileMapLayer
@export var tilemapWin: TileMapLayer
@export var cargo: PackedScene
@export var sprite: Node
@export var isCargo: bool

var lastTile: Vector2i
var currTile: Vector2i
var nextTile: Vector2i
var saveDir: Vector2i
var currDir: Vector2i
var lastDir: Vector2i

var canChangeDir: bool = true
var fixDistance = 10
var fixDistanceBehind = 5
var NextVia = true
var exploded = false
var wthoutTracks = false
var myCargo: Node2D
var coronavirusSafetyDistance: float = 27

func _ready() -> void:
	if !isCargo:
		EventBus.connect_signal("explode", explode)
		EventBus.connect_signal("withoutTracks", noT)
	EventBus.connect_signal("ReachedEnd",_stop)
	currTile = iniTilePos
	currDir = direction
	lastTile=currTile
	lastDir = currDir
	nextTile = currTile + currDir
	canChangeDir = true
	saveDir = Vector2i(0,0)
	global_position = tilemapTracks.map_to_local(currTile) + iniPosOffset
	change_sprite()

func noT()->void:
	wthoutTracks=true

func _process(delta: float) -> void:
	if exploded: return
	
	var input_vector = Vector2.ZERO
	if not isCargo:
		input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	
	var distanceCurr = global_position.distance_to(tilemapTracks.map_to_local(currTile))
	var distanceNext = global_position.distance_to(tilemapTracks.map_to_local(nextTile))
	# Recieve inputs
	# When we recieve a movement input, we want to know if
	# we can move it inmediatly or not.
	# If we cant move it inmediatly, we save the input until we arrive the next tile
	if input_vector != Vector2.ZERO and !exploded and currTile != iniTilePos:
		if input_vector.x == 0 and abs(input_vector.y) != abs(currDir.y):
			saveDir = Vector2i(0, input_vector.y)
		elif input_vector.y == 0 and abs(input_vector.x) != abs(currDir.x):
			saveDir = Vector2i(input_vector.x, 0)
	#When we reach the new Tile
	# Updates current and next Tiles
	# Allow the player to change direction
	# Allow to put the next track
	if distanceNext < fixDistanceBehind:
		lastTile = currTile
		currTile = nextTile
		nextTile = currTile + currDir
		canChangeDir = true
		if not onTrack():
			NextVia = true
			changeDir(saveDir)
		if not exploded:
			onLever()
			onCargo()
			onPassenger()
			onPortal()
	
	#We can change direction if we arrive the new tile or
	#if we are some fixed distance away
	if distanceCurr < fixDistance:
		changeDir(saveDir)
	#Moves the train forward
	global_position += Vector2(currDir) * speed * delta
	
	#Once we have moved, We can set up the next track.
	#Thats if the distance to the current Tile is enought away
	#so the player cant change the direction before the next tile
	distanceCurr = global_position.distance_to(tilemapTracks.map_to_local(currTile))
	if distanceCurr > fixDistance and NextVia:
		var degress: int = 0
		if currDir.y != 0: degress = 90
		put_track(nextTile, true, degress)
		
	#If myCargo is very close to me, I adjust the distance
	if myCargo and global_position.distance_to(myCargo.global_position) < coronavirusSafetyDistance:
		var distance = coronavirusSafetyDistance - global_position.distance_to(myCargo.global_position)
		myCargo.global_position += Vector2(distance, distance)*Vector2(-myCargo.currDir)

# OTHER FUNCTIONS

# Changes the train direction to the especify direction
# excepts null direction, cause the train is always moving
# or if the player has already changed the direction on the same tile
func changeDir(newDir: Vector2i, track:bool = false, portal:bool = false) -> void:
	if not canChangeDir or (newDir.x == 0 and newDir.y == 0): return
	if currDir == newDir or currDir == -newDir: return
	
	if tilemapPortals and tilemapPortals.get_cell_tile_data(currTile) and not portal: return
	#To change direction, we update last directon and current direction
	#Relocate the train
	#Update the last track to make it curve
	#We know player cant change Direction until the next tile, so we can put the next track
	#Also changes the train sprite and resets saved direction
	if newDir != currDir: global_position = tilemapTracks.map_to_local(currTile)
	
	lastDir = currDir
	currDir = newDir
	
	if not track:
		# When we change direction, the last track changes to be a curve track
		try_change_track(currTile)
		# And we can place the next track cause the player cant change the direction on this tile
		var degrees: int = 0
		if currDir.y != 0: degrees = 90
		put_track(currTile, true, degrees)
		saveDir = Vector2i(0,0)
	
	change_sprite()
	#Resets saved direction
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
func put_track(tile: Vector2i, straight: bool, degrees: int, replace:bool = false) -> void:
	if not NextVia: return
	
	var maps: Array = [tilemapTracks, tilemapCargos, tilemapLevers, tilemapPassengers, tilemapPortals, tilemapWin]
	var tile_data = null
	var tile_map = null
	for map in maps:
		if map:
			tile_map = map
			tile_data = tile_map.get_cell_tile_data(tile)
			if not tile_data: tile_map = null
			else: break
	
	if tile_data and not replace: return
	if wthoutTracks and (not tile_data or (tile_map and !tile_map.get_cell_tile_data(tile+currDir))) and not replace:
		explode()
		return

	# If there isn´t any track, we create the tile data.
	if not replace :
		tilemapTracks.set_cell(tile, 0, Vector2i(22, 0))
		tile_data = tilemapTracks.get_cell_tile_data(tile)
		EventBus.emit("PlacedRail" , [])
	
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
	if straight:
		var source := tilemapTracks.tile_set.get_source(0) as TileSetAtlasSource
		var effect = preload("res://Scenes/Objects/trackAnim.tscn").instantiate()
		effect.position = tilemapTracks.map_to_local(tile)
		get_parent().add_child(effect)
		await effect.setup(source.texture, source.get_tile_texture_region(track), alternative_id)
		tilemapTracks.set_cell(tile, 0, track, alternative_id)
	else: tilemapTracks.set_cell(tile, 0, track, alternative_id)
	
	if not replace: NextVia = false

func onTrack() -> bool :
	if not NextVia: return false
	
	var i := 0
	while i < get_child_count():
		var child = get_child(i)
		if child is MixedRailsCollider:
			child.onTrack()
			break
		i += 1
	
	if not crash(currTile, currDir): changeDir(nextDir(currTile, currDir), true)
	else: explode()
	
	return true

func crash(tile: Vector2i, dir: Vector2i) -> bool:
	var maps: Array = [tilemapTracks, tilemapCargos, tilemapLevers, tilemapPassengers, tilemapWin]
	var tile_map = null
	var tile_data = null
	for map in maps:
		if map:
			tile_map = map
			tile_data = tile_map.get_cell_tile_data(tile)
			if not tile_data: tile_map = null
			else: break 
			
	if not tile_data: return false
	
	var textureAtlas = tile_map.get_cell_atlas_coords(tile)
	var degrees: int = tile_map.get_cell_alternative_tile(tile)
	match degrees:
		TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_TRANSPOSE: degrees = 90
		TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V: degrees = 180
		TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_TRANSPOSE: degrees = 270
		_: degrees = 0
	
	if textureAtlas == Vector2i(5,0):
		if dir.x != 0 and degrees == 90: return true
		elif dir.y != 0 and degrees == 0: return true
		else: return false
	elif textureAtlas == Vector2i(0,0):
		if degrees == 0 and dir != Vector2i(1,0) and dir != Vector2i(0,1): return true
		elif degrees == 90 and dir != Vector2i(-1, 0) and dir != Vector2i(0, 1): return true
		elif degrees == 180 and dir != Vector2i(-1, 0) and dir != Vector2i(0, -1): return true
		elif degrees == 270 and dir != Vector2i(1, 0) and dir != Vector2i(0, -1): return true
		else: return false
	else:
		return false

func nextDir(tile: Vector2i, dir: Vector2i) -> Vector2i:
	var maps: Array = [tilemapTracks, tilemapCargos, tilemapLevers, tilemapPassengers, tilemapWin]
	var tile_map = null
	var tile_data = null
	for map in maps:
		if map:
			tile_map = map
			tile_data = tile_map.get_cell_tile_data(tile)
			if not tile_data: tile_map = null
			else: break 
	if not tile_data: return Vector2i(0, 0)
	
	var textureAtlas = tile_map.get_cell_atlas_coords(tile)
	var degrees: int = tile_map.get_cell_alternative_tile(tile)
	match degrees:
		TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_TRANSPOSE: degrees = 90
		TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V: degrees = 180
		TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_TRANSPOSE: degrees = 270
		_: degrees = 0
		
	
	var nDir = Vector2i(0,0)
	if textureAtlas == Vector2i(0,0):
		if degrees == 0 and dir == Vector2i(0,1): nDir = Vector2i(-1,0)
		elif degrees == 0 and dir == Vector2i(1, 0): nDir = Vector2i(0,-1)
		elif degrees == 90 and dir == Vector2i(0, 1): nDir = Vector2i(1,0)
		elif degrees == 90 and dir == Vector2i(-1, 0): nDir = Vector2i(0,-1)
		elif degrees == 180 and dir == Vector2i(0, -1): nDir = Vector2i(1,0)
		elif degrees == 180 and dir == Vector2i(-1, 0): nDir = Vector2i(0,1)
		elif degrees == 270 and dir == Vector2i(0, -1): nDir = Vector2i(-1,0)
		elif degrees == 270 and dir == Vector2i(1, 0):nDir = Vector2i(0,1)
	elif textureAtlas == Vector2i(5,0): nDir = dir
	
	return nDir

func onCargo() -> bool :
	if not tilemapCargos: return false
	#If there´s a cargo, we erase the tile and instantiate the cargo
	#return otherwise
	var tile_data = tilemapCargos.get_cell_tile_data(currTile)
	if not tile_data: return false
	
	var textureAtlas = tilemapCargos.get_cell_atlas_coords(currTile)
	var degrees: int = tilemapCargos.get_cell_alternative_tile(currTile)
	tilemapCargos.erase_cell(currTile)
	EventBus.emit("getCargo", [currTile, 4])
	tilemapTracks.set_cell(currTile, 0, textureAtlas, degrees)
	
	createCargo()
	return true

func onLever() -> bool :
	if not tilemapLevers: return false
	
	var tile_data = tilemapLevers.get_cell_tile_data(currTile)
	if not tile_data: return false
	AudioManager.play("LeverVagon")
	var textureAtlas = tilemapLevers.get_cell_atlas_coords(currTile)
	
	if textureAtlas != Vector2i(5,0):
		return false
	
	if not isCargo: EventBus.emit("pullLever", [currTile, 7])
	return true

func createCargo() -> void:
	if myCargo:
		myCargo.createCargo()
		return
	AudioManager.play("Connect")
	EventBus.emit("CargoPicked")
	
	#Init Cargo
	myCargo = cargo.instantiate()
	myCargo.tilemapTracks = tilemapTracks
	myCargo.tilemapCargos = tilemapCargos
	myCargo.tilemapPassengers = tilemapPassengers
	myCargo.tilemapPortals = tilemapPortals
	myCargo.tilemapLevers = tilemapLevers

	myCargo.isCargo = true
	myCargo.direction = lastDir
	myCargo.cargo = cargo
	
	#Position, don't ask how it works, I don't know how it works.
	#it just works!
	#When we reach the tile, currTile is the lastTile
	#regardless of whether it goes past the center or falls a little short
	#So, we want to place the cargo on the Tile before with some fixed distance
	var Offset: Vector2 = Vector2(0,0)
	var closerTile: Vector2i = Vector2i(0,0)
	if global_position.distance_to(tilemapTracks.map_to_local(currTile)) > global_position.distance_to(tilemapTracks.map_to_local(nextTile)):
		closerTile = nextTile
	else: closerTile = currTile
	
	if lastDir.x > 0: Offset.x = -tilemapTracks.map_to_local(closerTile).distance_to(global_position)
	elif lastDir.x < 0: Offset.x = tilemapTracks.map_to_local(closerTile).distance_to(global_position)
	elif lastDir.y > 0: Offset.y = -tilemapTracks.map_to_local(closerTile).distance_to(global_position)
	elif lastDir.y < 0: Offset.y = tilemapTracks.map_to_local(closerTile).distance_to(global_position)
	
	if isCargo:
		if global_position.distance_to(tilemapTracks.map_to_local(currTile)) > global_position.distance_to(tilemapTracks.map_to_local(nextTile)):
			closerTile = currTile
		else: closerTile = currTile
	
	if lastDir.x > 0: Offset.x = tilemapTracks.map_to_local(closerTile).distance_to(global_position)
	elif lastDir.x < 0: Offset.x = -tilemapTracks.map_to_local(closerTile).distance_to(global_position)
	elif lastDir.y > 0: Offset.y = tilemapTracks.map_to_local(closerTile).distance_to(global_position)
	elif lastDir.y < 0: Offset.y = -tilemapTracks.map_to_local(closerTile).distance_to(global_position)
	
	myCargo.iniTilePos = lastTile
	myCargo.iniPosOffset = Offset
	get_parent().add_child(myCargo)
	

func onPassenger() -> bool:
	if not tilemapPassengers: return false
	#If there´s a passenger, we erase the passenger
	#return otherwise
	var tile_data = tilemapPassengers.get_cell_tile_data(currTile)
	if not tile_data: return false
	
	var textureAtlas = tilemapPassengers.get_cell_atlas_coords(currTile)
	var degrees: int = tilemapPassengers.get_cell_alternative_tile(currTile)
	tilemapPassengers.erase_cell(currTile)
	EventBus.emit("getPassenger", [currTile])
	tilemapTracks.set_cell(currTile, 0, textureAtlas, degrees)
	AudioManager.play("PassengerOn")
	return true

func explode() -> void:
	currDir = Vector2i(0,0)
	saveDir = Vector2i(0,0)
	sprite.stop()
	exploded = true
	print("EXPLODE")
	if not isCargo:
		AudioManager.play("Death")
	if myCargo:
		await get_tree().create_timer(0.15).timeout
		myCargo.explode()
	else:
		await get_tree().create_timer(1).timeout
		get_tree().set_meta("from_restart", true)
		EventBus.emit("exit_pause")
		EventBus.emit("play_transition", ["restart_animation"])
		await get_tree().create_timer(1).timeout
		get_tree().reload_current_scene()

func onPortal() -> bool:
	if not tilemapPortals: return false
	
	var tile_data = tilemapPortals.get_cell_tile_data(currTile)
	if not tile_data: return false
	
	var textureAtlas = tilemapPortals.get_cell_atlas_coords(currTile)
	
	var portal: int = -1 # A=0, B=1, C=2, " "=3
	if textureAtlas == Vector2i(0, 0):
		if currDir.y == -1: portal = 0
		else: explode()
	elif textureAtlas == Vector2i(1, 0):
		if currDir.y == -1: portal = 1
		else: explode()
	elif textureAtlas == Vector2i(2, 0):
		if currDir.y == -1: portal = 2
		else: explode()
	elif textureAtlas == Vector2i(12, 0):
		if currDir.y == -1: portal = 3
		else: explode()
	elif textureAtlas == Vector2i(3, 0):
		if currDir.x == 1: portal = 0
		else: explode()
	elif textureAtlas == Vector2i(4, 0):
		if currDir.x == -1: portal = 0
		else: explode()
	elif textureAtlas == Vector2i(6, 0):
		if currDir.x == 1: portal = 1
		else: explode()
	elif textureAtlas == Vector2i(7, 0):
		if currDir.x == -1: portal = 1
		else: explode()
	elif textureAtlas == Vector2i(9, 0):
		if currDir.x == 1: portal = 2
		else: explode()
	elif textureAtlas == Vector2i(10, 0):
		if currDir.x == -1: portal = 2
		else: explode()
	elif textureAtlas == Vector2i(13, 0):
		if currDir.x == 1: portal = 3
		else: explode()
	elif textureAtlas == Vector2i(14, 0):
		if currDir.x == -1: portal = 3
		else: explode()
	elif textureAtlas == Vector2i(5, 0):
		if currDir.y == 1: portal = 0
		else: explode()
	elif textureAtlas == Vector2i(8, 0):
		if currDir.y == 1: portal = 1
		else: explode()
	elif textureAtlas == Vector2i(11, 0):
		if currDir.y == 1: portal = 2
		else: explode()
	elif textureAtlas == Vector2i(15, 0):
		if currDir.y == 1: portal = 3
		else: explode()
	if portal == -1: return false
	
	#Una vez he encontrado un portal busco el otro
	var portals = tilemapPortals.get_used_cells()
	var nextPortal = Vector2i(-1,-1)
	for tile in portals:
		var idx = -1
		var coords = tilemapPortals.get_cell_atlas_coords(tile)
		if coords == Vector2i(0,0) || coords == Vector2i(3,0) || coords == Vector2i(4,0) || coords == Vector2i(5,0): idx = 0
		elif coords == Vector2i(1,0) || coords == Vector2i(6,0) || coords == Vector2i(7,0) || coords == Vector2i(8,0): idx = 1
		elif coords == Vector2i(2,0) || coords == Vector2i(9,0) || coords == Vector2i(10,0) || coords == Vector2i(11,0): idx = 2
		elif coords == Vector2i(12,0) || coords == Vector2i(13,0) || coords == Vector2i(14,0) || coords == Vector2i(15,0): idx = 3
		
		if portal == idx and tile != currTile:
			nextPortal = tile
			break
	if nextPortal == Vector2i(-1,-1): return false
	AudioManager.play("Portal")
	global_position = tilemapPortals.map_to_local(nextPortal)
	currTile = nextPortal
	var atcoo = tilemapPortals.get_cell_atlas_coords(nextPortal)
	if atcoo == Vector2i(1,0) or atcoo == Vector2i(2,0) or atcoo == Vector2i(0,0) or atcoo == Vector2i(12,0): changeDir(Vector2i(0, 1),false,true)
	elif atcoo == Vector2i(3,0) or atcoo == Vector2i(6,0) or atcoo == Vector2i(9,0) or atcoo == Vector2i(13,0): changeDir(Vector2i(-1, 0),false,true)
	elif atcoo == Vector2i(4,0) or atcoo == Vector2i(7,0) or atcoo == Vector2i(10,0) or atcoo == Vector2i(14,0): changeDir(Vector2i(1, 0),false,true)
	elif atcoo == Vector2i(5,0) or atcoo == Vector2i(8,0) or atcoo == Vector2i(11,0) or atcoo == Vector2i(15,0): changeDir(Vector2i(0, -1),false,true)
	nextTile = currDir+currTile
	if tilemapTracks and tilemapTracks.get_cell_tile_data(currTile): tilemapTracks.erase_cell(currTile)
	return true

func _stop():
	speed=0
