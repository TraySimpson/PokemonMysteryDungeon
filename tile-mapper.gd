extends Node



func get_coords_for_tile(map: Array, coords: Vector2i) -> Vector2i:
	var neighbors = get_neighbors(map, coords)
	# TODO return atlas coord based on neighbor value
	return Vector2i.ZERO

func get_neighbors(map: Array, coords: Vector2i):
	var bit = 1
	var total = 0
	for x in range(coords.x - 1, coords.x + 1):
		for y in range(coords.y - 1, coords.y + 1):
			if x == coords.x and y == coords.y:
				continue
			# TODO check for out of bounds, add bit if so
			if map[x][y]:
				total += bit
			bit = bit << 1
	return total
