extends Node2D
class_name Wave

@onready var checkpoint: Area2D = $checkpoint
var spawn_data = []
var complete = false
var child_count = 0


func _ready():
	GameManager.player_spawned.connect(spawn_wave)
	var meta_data = null
	for child in get_children():
		if child.is_in_group("Checkpoint"):
			#child.activated.connect(spawn_wave)
			pass
		else:
			meta_data = child.data
			print(meta_data)
			spawn_data.append({
				"path": child.scene_file_path,
				"position": child.position,
				"meta_data": meta_data
			})
	clear()
	spawn_wave()

func clear():
	for child in get_children():
		if child != checkpoint:
			remove_child(child)
			child.queue_free()

func spawn_wave(player = null):
	if complete:
		return
	clear()
	for child_data in spawn_data:
		var scene = load(child_data.path)
		var new_spawn = scene.instantiate()
		new_spawn.position = child_data.position
		add_child(new_spawn)
		new_spawn.set_data(child_data.meta_data)
		new_spawn.died.connect(_on_child_died)
	child_count = get_child_count() - 1
		
func wave_running():
	return len(get_children()) > 1
	
func _on_child_died():
	child_count -= 1
	complete = child_count == 0
