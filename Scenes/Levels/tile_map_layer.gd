extends TileMapLayer

@export var grass : PackedScene

func _ready() -> void:
	var cells = get_used_cells()
	for cell in cells:
		var cell_data : TileData = get_cell_tile_data(cell)
		if cell_data.get_custom_data("spawn_grass"):
			var world_pos = map_to_local(cell)
			if randi() % 100 < 100:
				if valid_grass_conditions(cell):
					var grass_spawn = grass.instantiate()
					grass_spawn.position = Vector2(world_pos.x + randf_range(-20, 20), world_pos.y - tile_set.tile_size.y / 2)
					add_child(grass_spawn)

func get_cell_data(position):
	return get_cell_tile_data(local_to_map(to_local(position)))

func valid_grass_conditions(cell):
	var grass_checks = [Vector2i(-1, 0), Vector2i(1, 0)]
	var air_checks = [Vector2i(-1, -1), Vector2i(1, -1), Vector2i(0, -1)]
	var valid = true
	for check in grass_checks:
		var cell_data = get_cell_tile_data(cell + check)
		if !cell_data or !cell_data.get_custom_data("spawn_grass"):
			valid = false
	for check in air_checks:
		var cell_data = get_cell_tile_data(cell + check)
		if cell_data != null:
			valid = false
	return valid
