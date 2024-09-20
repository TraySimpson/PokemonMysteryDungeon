extends Node2D

@export var tileset: TileSet
@export var map_width: int = 10
@export var map_height: int = 10

@onready var ground_layer: TileMapLayer = $GroundLayer


func _ready() -> void:
	ground_layer.tile_set = tileset
	create_dungeon()

func create_dungeon() -> void:
	for x in range(map_width):
		for y in range(map_height):
			ground_layer.set_cell(Vector2(x, y), 1, Vector2(1 + (2 * 6), 1))
