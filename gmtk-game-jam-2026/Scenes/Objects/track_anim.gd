extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

const TILE_SIZE := Vector2i(16,16)
const TRACK_ATLAS = preload("res://Assets/Sprites/RailTile.png")

func setup(texture: Texture2D, region: Rect2, alternative_id:int):
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = region
	apply_transform(alternative_id)
	sprite.scale = Vector2.ZERO
	var tween := create_tween()
	tween.parallel().tween_property(sprite, "scale:x", 1.0, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "scale:y", 1.0, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	queue_free()

func apply_transform(alternative_id:int):
	sprite.flip_h = false
	sprite.flip_v = false
	sprite.rotation_degrees = 0
	match alternative_id:
		TileSetAtlasSource.TRANSFORM_FLIP_H:
			sprite.flip_h = true
		TileSetAtlasSource.TRANSFORM_FLIP_V:
			sprite.flip_v = true
		TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_TRANSPOSE:
			sprite.rotation_degrees = 90
			sprite.flip_h = true
		TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V:
			sprite.flip_h = true
			sprite.flip_v = true
		TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_TRANSPOSE:
			sprite.rotation_degrees = 270
			sprite.flip_v = true
