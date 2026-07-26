class_name MixedRailsCollider
extends Node2D

var train: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	train = get_parent()

func onTrack() -> bool :
	var tile_data = train.tilemapTracks.get_cell_tile_data(train.currTile)
	
	var textureAtlas = train.tilemapTracks.get_cell_atlas_coords(train.currTile)
	var degrees: int = train.tilemapTracks.get_cell_alternative_tile(train.currTile)
	match degrees:
		TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_TRANSPOSE: degrees = 90
		TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V: degrees = 180
		TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_TRANSPOSE: degrees = 270
		_: degrees = 0
	
	if textureAtlas == Vector2i(11,0): #curvado, de izq a arr
		if degrees == 0:
			if train.currDir == Vector2i(0, 1): train.changeDir(Vector2i(-1,0), true)
			elif train.currDir == Vector2i(1, 0): train.changeDir(Vector2i(0,-1), true)
			else: train.explode()
		elif degrees == 90:
			if train.currDir == Vector2i(0, 1): train.changeDir(Vector2i(1,0), true)
			elif train.currDir == Vector2i(-1, 0): train.changeDir(Vector2i(0,-1), true)
			else: train.explode()
		elif degrees == 180:
			if train.currDir == Vector2i(0, -1): train.changeDir(Vector2i(1,0), true)
			elif train.currDir == Vector2i(-1, 0): train.changeDir(Vector2i(0,1), true)
			else: train.explode()
		else:
			if train.currDir == Vector2i(0, -1): train.changeDir(Vector2i(-1,0), true)
			elif train.currDir == Vector2i(1, 0): train.changeDir(Vector2i(0,1), true)
			else: train.explode()
	elif textureAtlas == Vector2i(6,0):
		if (train.currDir.x != 0 and (degrees == 90 or degrees == 270)) or (train.currDir.y != 0 and degrees == 0): train.explode()
		elif (train.currDir.x != 0 and degrees == 0) or (train.currDir.y != 0 and (degrees == 90 or degrees == 270)): train.changeDir(train.currDir, true)
	return true
