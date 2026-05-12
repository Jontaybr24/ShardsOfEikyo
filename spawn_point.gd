extends Node2D

@export var spawn_list : Array[SpawnData]
@export var spawn_timer = 1
@export var spawncount = 5

var timer = 0

func _process(delta: float) -> void:
	if timer > 0:
		timer -= delta
	else:
		timer = spawn_timer
		if spawncount > 0:
			spawn()

func spawn(wait = false):
	if wait:
		await get_tree().create_timer(spawn_timer).timeout
	var enemy = spawn_list.pick_random()
	var new_spawn = enemy.scene.instantiate()
	add_child(new_spawn)
	new_spawn.global_position = global_position
	spawncount -= 1
