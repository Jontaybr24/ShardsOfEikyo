extends Area2D

@export var health = 45
var current_health: float
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	GameManager.player_spawned.connect(reset)
	current_health = health
	sprite.material = sprite.material.duplicate()
	sprite.material.set_shader_parameter("Strength", clamp(1 - (current_health) / health, 0, 1))

func take_damage(dmg):
	current_health -= dmg
	sprite.material.set_shader_parameter("Strength", clamp(1 - (current_health) / health, 0, 1))

func reset(p):
	current_health = health
	sprite.material.set_shader_parameter("Strength", clamp(1 - (current_health) / health, 0, 1))
