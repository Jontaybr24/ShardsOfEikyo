extends Node2D

@export var player = Node2D

func _ready():
	GameManager.player_spawned.connect(update_player)

func _process(delta: float) -> void:
	if player:
		position = player.position

func update_player(new_player):
	player = new_player
