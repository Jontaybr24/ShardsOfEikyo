extends Node2D

var spawnpoints : Array[SpawnPoint]
@export var wave_count = 5
@export var spawn_count = 30
var spawn_limit = 5
var spawn_timer = 5

func _ready():
	for child in get_children():
		if child is SpawnPoint:
			spawnpoints.append(child)
	random_spawn()

func random_spawn():
	spawnpoints.pick_random().spawn()
