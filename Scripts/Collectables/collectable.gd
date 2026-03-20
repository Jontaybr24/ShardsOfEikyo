extends Area2D
class_name Collectable

@export var world_spawn = false
var move_speed = 400
var in_range = false
var player = null

func _ready():
	GameManager.player_died.connect(despawn)

func _process(delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		position += direction * move_speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Magnet"):
		player = get_tree().get_first_node_in_group("Player")

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Magnet"):
		player = null

func despawn():
	if not world_spawn:
		queue_free()
