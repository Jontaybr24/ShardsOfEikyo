extends Node2D

var spawnpoints : Array[SpawnPoint]

func _ready():
	for child in get_children():
		if child is SpawnPoint:
			spawnpoints.append(child)
	random_spawn()

func random_spawn():
	spawnpoints.pick_random().spawn()
