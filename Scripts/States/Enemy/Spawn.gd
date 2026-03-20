extends State
class_name  EnemySpawn

@export var enemy: Node2D

var time_since_spawn = 0
var spawn_time = 3
var player = Node2D

func Enter():
	player = get_tree().get_first_node_in_group("Player")

func Update(delta: float):
	if  time_since_spawn > spawn_time:
		var new_spawn = enemy.instantiate()
		get_parent().add_child(new_spawn)
		new_spawn.position.x = player.position.x - 100
		new_spawn.position.y = player.position.y - 50
		new_spawn.update_target(player)
		time_since_spawn = 0
