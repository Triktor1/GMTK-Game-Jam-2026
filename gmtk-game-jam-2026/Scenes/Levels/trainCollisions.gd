extends Node2D
@export var obstaclesMap: TileMapLayer
@export var wallsMap:TileMapLayer
@export var train: Node2D

var storedTile : TileData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
	
	
func tileEvent() -> void:
	EventBus.emit("explode", [])
	print ("Executing tile event")
