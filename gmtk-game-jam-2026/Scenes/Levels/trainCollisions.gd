extends Node2D
@export var obstaclesMap: TileMapLayer
@export var wallsMap:TileMapLayer
@export var passegersMap:TileMapLayer
@export var train: Node2D
@export var win_track:TileMapLayer

var storedTile : TileData
var exploded: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.connect_signal("getCargo", eraseAdyacentObstacle)
	EventBus.connect_signal("pullLever", pullAdyacentLever)
	EventBus.connect_signal("getPassenger", erasePassengers)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	checkIfInsideTile()
	pass

func checkIfInsideTile() ->void:
	var tileData = null
	var tileDataWall = null
	var tileDataWinTrack=null
	if obstaclesMap:
		var currentTile = obstaclesMap.local_to_map(obstaclesMap.to_local(train.global_position))
		tileData=obstaclesMap.get_cell_tile_data(currentTile);
	if wallsMap:
		var currentTileWall = wallsMap.local_to_map(wallsMap.to_local(train.global_position))
		tileDataWall=wallsMap.get_cell_tile_data(currentTileWall);
	if win_track:
		var currentTileWinTrack= win_track.local_to_map(win_track.to_local(train.global_position))
		tileDataWinTrack=win_track.get_cell_tile_data(currentTileWinTrack);
		
	if tileData && tileData != storedTile || tileDataWall && tileDataWall!=storedTile:
		tileEvent()
	elif tileDataWinTrack && tileDataWinTrack!=storedTile:
		EventBus.emit("ReachedEnd")
		
	storedTile = tileData

func eraseAdyacentObstacle(tile: Vector2i, id: int) -> void:
	if not obstaclesMap: return
	if obstaclesMap.get_cell_tile_data(tile+Vector2i(1,0)): if obstaclesMap.get_cell_source_id(tile+Vector2i(1,0)) == id: obstaclesMap.erase_cell(tile+Vector2i(1,0))
	if obstaclesMap.get_cell_tile_data(tile+Vector2i(-1,0)): if obstaclesMap.get_cell_source_id(tile+Vector2i(-1,0)) == id: obstaclesMap.erase_cell(tile+Vector2i(-1,0))
	if obstaclesMap.get_cell_tile_data(tile+Vector2i(0,1)): if obstaclesMap.get_cell_source_id(tile+Vector2i(0,1)) == id: obstaclesMap.erase_cell(tile+Vector2i(0,1))
	if obstaclesMap.get_cell_tile_data(tile+Vector2i(0,-1)): if obstaclesMap.get_cell_source_id(tile+Vector2i(0,-1)) == id: obstaclesMap.erase_cell(tile+Vector2i(0,-1))
func erasePassengers(tile: Vector2i) -> void:
	if not passegersMap: return
	tile = tile*2
	var count: int = 0
	
	if passegersMap.get_cell_tile_data(tile+Vector2i(2,0)): 
		passegersMap.erase_cell(tile+Vector2i(2,0))
		count+=1
	if passegersMap.get_cell_tile_data(tile+Vector2i(-2,0)): 
		passegersMap.erase_cell(tile+Vector2i(-2,0))
		count+=1
	if passegersMap.get_cell_tile_data(tile+Vector2i(0,2)): 
		passegersMap.erase_cell(tile+Vector2i(0,2))
		count+=1
	if passegersMap.get_cell_tile_data(tile+Vector2i(0,-2)): 
		passegersMap.erase_cell(tile+Vector2i(0,-2))
		count+=1
	
	
	if passegersMap.get_cell_tile_data(tile+Vector2i(3,0)): 
		passegersMap.erase_cell(tile+Vector2i(3,0))
		count+=1
	if passegersMap.get_cell_tile_data(tile+Vector2i(-1,0)): 
		passegersMap.erase_cell(tile+Vector2i(-1,0))
		count+=1
	if passegersMap.get_cell_tile_data(tile+Vector2i(1,2)): 
		passegersMap.erase_cell(tile+Vector2i(1,2))
		count+=1
	if passegersMap.get_cell_tile_data(tile+Vector2i(1,-2)): 
		passegersMap.erase_cell(tile+Vector2i(1,-2))
		count+=1
	
	
	if passegersMap.get_cell_tile_data(tile+Vector2i(2,1)): 
		passegersMap.erase_cell(tile+Vector2i(2,1))
		count+=1
	if passegersMap.get_cell_tile_data(tile+Vector2i(-2,1)): 
		passegersMap.erase_cell(tile+Vector2i(-2,1))
		count+=1
	if passegersMap.get_cell_tile_data(tile+Vector2i(0,3)): 
		passegersMap.erase_cell(tile+Vector2i(0,3))
		count+=1
	if passegersMap.get_cell_tile_data(tile+Vector2i(0,-1)): 
		passegersMap.erase_cell(tile+Vector2i(0,-1))
		count+=1
	
	
	if passegersMap.get_cell_tile_data(tile+Vector2i(3,1)): 
		passegersMap.erase_cell(tile+Vector2i(3,1))
		count+=1
	if passegersMap.get_cell_tile_data(tile+Vector2i(-1,1)): 
		passegersMap.erase_cell(tile+Vector2i(-1,1))
		count+=1
	if passegersMap.get_cell_tile_data(tile+Vector2i(1,3)): 
		passegersMap.erase_cell(tile+Vector2i(1,3))
		count+=1
	if passegersMap.get_cell_tile_data(tile+Vector2i(1,-1)): 
		passegersMap.erase_cell(tile+Vector2i(1,-1))
		count+=1
	
	EventBus.emit("newPassengers", [count])
	print(count)

func pullAdyacentLever(tile: Vector2i, id: int) -> void:
	var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for dir in directions:
		var pos = tile + dir
		if obstaclesMap.get_cell_tile_data(pos) and obstaclesMap.get_cell_source_id(pos) == id:
			var atlas = obstaclesMap.get_cell_atlas_coords(pos)
			var alternative = obstaclesMap.get_cell_alternative_tile(pos)
			if id == 0:
				obstaclesMap.set_cell(pos, 1, atlas, alternative)
			elif id == 1:
				obstaclesMap.set_cell(pos, 0, atlas, alternative)
			else: #Invierte horizontalmente el sprite
				obstaclesMap.set_cell(pos, id, atlas, alternative ^ TileSetAtlasSource.TRANSFORM_FLIP_H)
	
	for cell in train.tilemapTracks.get_used_cells():
					var atlas: Vector2i = train.tilemapTracks.get_cell_atlas_coords(cell)
					var alt : int = train.tilemapTracks.get_cell_alternative_tile(cell)
					if atlas == Vector2i(11,0):
						train.tilemapTracks.set_cell(cell, 0, Vector2i(6,0), alt)
					elif atlas == Vector2i(6,0):
						train.tilemapTracks.set_cell(cell, 0, Vector2i(11,0), alt)

func tileEvent() -> void:
	if !exploded:
		exploded = true
		EventBus.emit("explode", [])
	print ("Executing tile event")
