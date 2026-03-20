extends Node2D

signal activated

@onready var sprite: Sprite2D = $Sprite2D
var timer = 0
var time_to_set = .5
var active = false

func _ready():
	GameManager.setting_spawn.connect(reset)
	sprite.material = sprite.material.duplicate()
	sprite.material.set_shader_parameter("Strength", 1)

func _process(delta: float) -> void:
	if timer > 0:
		timer -= delta
		var glow = 1 - ((1 - .1) * ((time_to_set - timer)/ time_to_set))
		sprite.material.set_shader_parameter("Strength", glow)

func reset(newspawn):
	sprite.material.set_shader_parameter("Strength", 1)
	active = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and !active:
		GameManager.set_spawn(self)
		timer = time_to_set
		active = true
		activated.emit()
