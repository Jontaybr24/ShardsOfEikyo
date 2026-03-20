extends Node

@export var default : Wave
var waves = []
var idx = 0

func _ready():
	waves = get_children()
	if default:
		GameManager.set_spawn(default.checkpoint)
		var player = get_tree().get_first_node_in_group("Player")
		player.position = default.checkpoint.global_position
	else:
		GameManager.set_spawn(waves[idx].checkpoint)
