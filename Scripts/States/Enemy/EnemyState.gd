extends State
class_name EnemyState

@export var enemy : CharacterBody2D
var player: CharacterBody2D
var distance = 0.0
var direction = 0.0
var vert = 0.0

func _ready():
	GameManager.player_spawned.connect(update_target)

func Enter():
	player = get_tree().get_first_node_in_group("Player")

func Physics_Update(delta: float):
	if not enemy or not player or not is_instance_valid(player):
		return
	distance = player.global_position.x - enemy.global_position.x
	vert = enemy.global_position.y - player.global_position.y
	direction = sign(distance)
	distance = abs(distance)

func update_target(new_player):
	player = new_player
