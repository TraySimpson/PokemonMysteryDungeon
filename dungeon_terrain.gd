extends Node2D

@export var tileset: TileSet
@export var map_width: int = 10
@export var map_height: int = 10

@onready var timer: Timer = $Timer
@onready var ground_layer: TileMapLayer = $GroundLayer
const WALL_TILE: Vector2 = Vector2(1 + (0 * 6), 1)
const WATER_TILE: Vector2 = Vector2(1 + (1 * 6), 1)
const FLOOR_TILE: Vector2 = Vector2(1 + (2 * 6), 1)

func _ready() -> void:
	ground_layer.tile_set = tileset
	await create_dungeon()

func create_dungeon() -> void:
	print("Drawing dungeon")
	for x in range(map_width):
		for y in range(map_height):
			var tile = get_atlas_coords(x, y)
			ground_layer.set_cell(Vector2(x, y), tileset.get_source_id(0), tile)


func get_atlas_coords(x: int, y: int) -> Vector2:
	if is_hard_border(x, y):
		return WALL_TILE
	if is_soft_border(x, y):
		return WATER_TILE
	return FLOOR_TILE

func is_hard_border(x: int, y: int) -> bool:
	return x == 0 or x == map_width - 1 or y == 0 or y == map_height - 1

func is_soft_border(x: int, y: int) -> bool:
	return x == 1 or x == map_width - 2 or y == 1 or y == map_height - 2
