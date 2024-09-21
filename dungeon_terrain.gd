extends Node2D

@export var tileset: TileSet
@export var map_width: int = 10
@export var map_height: int = 10

# Reference video: https://www.youtube.com/watch?v=fudOO713qYo&t=399s

# In reference video, "M"
@export var regions_horizontal := 3
# In reference video, "N"
@export var regions_vertical := 2
# Determines how many rooms are created, the rest a dummy 1x1 rooms
# Negative value -> exact room count
# Positive value -> +/-1 random variance
# At least 2 rooms with ALWAYS be generated
@export var room_density := -2

const MIN_ROOM_WIDTH := 5
const MIN_ROOM_HEIGHT := 4
const MAX_ROOM_SCALE_RATIO := .666666
const MERGE_ROOM_CHANCE := .05

@onready var ground_layer: TileMapLayer = $GroundLayer

const WALL_TILE: Vector2 = Vector2(1 + (0 * 6), 1)
const WATER_TILE: Vector2 = Vector2(1 + (1 * 6), 1)
const FLOOR_TILE: Vector2 = Vector2(1 + (2 * 6), 1)

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	ground_layer.tile_set = tileset
	await create_dungeon()

func create_dungeon() -> void:
	print("Drawing dungeon")
	# Fill with walls
	for x in range(map_width):
		for y in range(map_height):
			var tile = get_atlas_coords(x, y)
			ground_layer.set_cell(Vector2(x, y), tileset.get_source_id(0), tile)
	
	# Create rooms
	var room_count = get_room_count()
	var region_width = (map_width - 4) / regions_horizontal
	var region_height = (map_height - 4) / regions_vertical
	if (region_width < MIN_ROOM_WIDTH):
		printerr("Region width cannot be smaller than MIN_ROOM_WIDTH")
	if (region_height < MIN_ROOM_HEIGHT):
		printerr("Region width cannot be smaller than MIN_ROOM_HEIGHT")
	for m in range(regions_horizontal):
		for n in range(regions_vertical):
			fill_room(Vector2(m * region_width + 2, n * region_height + 2), Vector2(5, 4))
	
	# Create corridors
	for m in range(regions_horizontal):
		for n in range(regions_vertical):
			var corridors_to_add = get_corridors_to_add(m, n)
	
func get_corridors_to_add(m: int, n: int) -> Array:
	return []

func get_room_count() -> int:
	var rooms = 2
	if room_density < 0:
		rooms = abs(room_density)
	else:
		rooms = rng.randi_range(abs(room_density) - 1, abs(room_density) + 1)
	if rooms < 2:
		rooms = 2
	return rooms

func fill_room(start_point: Vector2i, size: Vector2i) -> void:
	for x in range(size.x):
		for y in range(size.y):
			ground_layer.set_cell(
				Vector2(start_point.x + x, start_point.y + y), 
				tileset.get_source_id(0), 
				FLOOR_TILE)

func get_atlas_coords(x: int, y: int) -> Vector2:
	if is_hard_border(x, y):
		return WALL_TILE
	if is_soft_border(x, y):
		return WATER_TILE
	return WALL_TILE

func is_hard_border(x: int, y: int) -> bool:
	return x == 0 or x == map_width - 1 or y == 0 or y == map_height - 1

func is_soft_border(x: int, y: int) -> bool:
	return x == 1 or x == map_width - 2 or y == 1 or y == map_height - 2
