extends Entity
class_name BasicShooter

var projectile = preload("res://Scenes/Attacks/projectile.tscn")
var detection_range = 600
@onready var state_machine = $"State Machine"
var player = null

func _ready():
	super._ready()
	GameManager.player_spawned.connect(update_player)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not player:
		player = get_tree().get_first_node_in_group("Player")
	if player:
		if player.global_position.x < global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

func update_player(new_player):
	player = new_player

func take_damage(dmg, dmg_type, pos, kb = data.knockback):
	state_machine.on_child_transition(state_machine.current_state, "knockback")
	super.take_damage(dmg, dmg_type, pos, kb)
