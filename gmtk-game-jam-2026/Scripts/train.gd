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
				
	if distanceCurr > fixDistance and NextVia:
		var degress: int = 0
		if currDir.y != 0: degress = 90
		put_track(nextTile, true, degress)
		
	var distanceNext = global_position.distance_to(tilemap.map_to_local(nextTile))
	if distanceNext < 2:
		currTile = nextTile
		canChangeDir = true
		NextVia = true
		changeDir(saveDir)
		
	# CORRECCIÓN: Convertimos currDir a Vector2 para que el movimiento con delta sea preciso
	global_position += Vector2(currDir) * speed * delta

func changeDir(newDir: Vector2i) -> void:
	if not canChangeDir: return
	global_position = tilemap.map_to_local(currTile)
	
	if (newDir.x != 0 || newDir.y != 0):
		lastDir = currDir
		currDir = newDir
		
		# ¡LLAMADA CLAVE!: Cambia la vía actual (donde ocurre el giro) a una curva
		NextVia = true # Forzamos permiso temporal para editar el mapa
		try_change_track(currTile)
		
		# Coloca la siguiente vía recta hacia adelante
		NextVia = true
		var degrees: int = 0
		if currDir.y != 0: degrees = 90
		put_track(currTile + currDir, true, degrees)
		
		change_sprite()
		saveDir = Vector2i(0,0)
		canChangeDir = false
		
	nextTile = currTile + currDir

func change_sprite() -> void:
	if (currDir.y == -1):
		sprite.play("up")
	elif (currDir.y == 1):
		sprite.play("down")
	else:
		sprite.play("horizontal")
		sprite.flip_h = currDir.x == -1

func try_change_track(tile: Vector2i) -> void:
	var degrees: int = 0
	# Lógica de rotación de curvas según la dirección anterior y la nueva
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
	
func put_track(tile: Vector2i, straight: bool, degrees: int, replace:bool = false):
	if not NextVia: return
	
	var tile_data = tilemap.get_cell_tile_data(tile)
	if !tile_data or replace:
		if !tile_data :
			tilemap.set_cell(tile, 0, Vector2i(0, 0))
			tile_data = tilemap.get_cell_tile_data(tile)
		var track : Vector2i
		if straight: 
			track = Vector2i(5, 0) # Tu tile recto
		else: 
			track = Vector2i(0, 0) # Tu tile de curva
		
		var alternative_id: int = 0
		match degrees:
			90:  alternative_id = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_TRANSPOSE
			180: alternative_id = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
			270: alternative_id = TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_TRANSPOSE
			_: alternative_id = 0 
			
		tilemap.set_cell(tile, 0, track, alternative_id)
		NextVia = false
