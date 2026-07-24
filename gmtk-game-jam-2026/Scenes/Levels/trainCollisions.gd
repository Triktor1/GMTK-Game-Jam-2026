extends Node2D
@export var obstaclesMap: TileMapLayer
@export var wallsMap:TileMapLayer
@export var train: Node2D

var storedTile : TileData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.connect_signal("getCargo", eraseAdyacentObstacle)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	checkIfInsideTile()
	pass


func checkIfInsideTile() ->void:
	var currentTile = obstaclesMap.local_to_map(obstaclesMap.to_local(train.global_position))
	#print(currentTile)
	var tileData=obstaclesMap.get_cell_tile_data(currentTile);
	
	var currentTileWall = wallsMap.local_to_map(wallsMap.to_local(train.global_position))
	var tileDataWall=wallsMap.get_cell_tile_data(currentTileWall);
	
	if tileData && tileData != storedTile || tileDataWall && tileDataWall!=storedTile:
		print("inside Tile")
		tileEvent()
	storedTile = tileData
	
func eraseAdyacentObstacle(tile: Vector2i, id: int) -> void:
	if obstaclesMap.get_cell_tile_data(tile+Vector2i(1,0)): if obstaclesMap.get_cell_source_id(tile+Vector2i(1,0)) == id: obstaclesMap.erase_cell(tile+Vector2i(1,0))
	if obstaclesMap.get_cell_tile_data(tile+Vector2i(-1,0)): if obstaclesMap.get_cell_source_id(tile+Vector2i(-1,0)) == id: obstaclesMap.erase_cell(tile+Vector2i(-1,0))
	if obstaclesMap.get_cell_tile_data(tile+Vector2i(0,1)): if obstaclesMap.get_cell_source_id(tile+Vector2i(0,1)) == id: obstaclesMap.erase_cell(tile+Vector2i(0,1))
	if obstaclesMap.get_cell_tile_data(tile+Vector2i(0,-1)): if obstaclesMap.get_cell_source_id(tile+Vector2i(0,-1)) == id: obstaclesMap.erase_cell(tile+Vector2i(0,-1))
func tileEvent() -> void:
	EventBus.emit("explode", [])
	print ("Executing tile event")
