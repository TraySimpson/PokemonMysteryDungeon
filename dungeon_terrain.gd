extends Node2D

@export var tileset: TileSet
@export var map_width: int = 10
@export var map_height: int = 10

@onready var ground_layer: TileMapLayer = $GroundLayer
const WALL_TILE: Vector2 = Vector2(1 + (0 * 6), 1)
const WATER_TILE: Vector2 = Vector2(1 + (1 * 6), 1)
const FLOOR_TILE: Vector2 = Vector2(1 + (2 * 6), 1)

func _ready() -> void:
	ground_layer.tile_set = tileset
	create_dungeon()

func create_dungeon() -> void:
	print("Drawing dungeon")
	for x in range(map_width):
		for y in range(map_height):
			ground_layer.set_cell(Vector2(x, y), tileset.get_source_id(0), WALL_TILE)
