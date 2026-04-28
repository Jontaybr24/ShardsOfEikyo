extends TileMapLayer

@export var grass : PackedScene

func _ready() -> void:
	var cells = get_used_cells()
	for cell in cells:
		var cell_data : TileData = get_cell_tile_data(cell)
		if cell_data.get_custom_data("spawn_grass"):
			var world_pos = map_to_local(cell)
			var grass_spawn = grass.instantiate()
			grass_spawn.position = Vector2(world_pos.x, world_pos.y - tile_set.tile_size.y)
			add_child(grass_spawn)
