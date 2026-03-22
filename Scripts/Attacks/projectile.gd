extends Area2D
class_name Projectile

@export var move_speed = 800
@export var damage = 5
@export var type = TypeManager.ELEMENTS.SHARD
var dir = -1
var end_of_life = 5
var lifetime = 0
var parried = false
var parent = null
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	GameManager.player_died.connect(die)

func _physics_process(delta: float) -> void:
	position.x += move_speed * dir * delta
	lifetime += delta
	if lifetime > end_of_life:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	if target.is_in_group("Player"):
		target.take_damage(damage, type, global_position)
		queue_free()
	elif target == parent and parried:
		target.take_damage(damage, type, global_position)
		queue_free()

func die():
	queue_free()
