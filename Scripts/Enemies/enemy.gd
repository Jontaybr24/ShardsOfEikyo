extends Entity
class_name BasicEnemy

var vert_range = 100
var attack_range : int
var attack_damage = 10
var attack_rate = .4
var combo = 0
@export var max_combo = 1
@onready var attack_box: Area2D = $"Attack Box"
@onready var state_machine = $"State Machine"
var player : Node2D
var dir = 1

func _ready():
	super._ready()
	attack_range = abs(attack_box.position.x)
	contact_damage = true
	move_speed = 100
	scale.x = -1
	GameManager.player_spawned.connect(update_player)
	GameManager.player_died.connect(on_player_death)
	player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	super._process(delta)
	if action_timer > 0:
		action_timer -= delta

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	var current_state = state_machine.current_state.name.to_lower()
	if player:
		var distance = player.global_position.x - global_position.x
		if current_state == "idle" and abs(velocity.x) > 0:
			dir = -sign(velocity.x)
		elif current_state == "follow":
			dir = -sign(distance)
		sprite.flip_h = dir == 1
		attack_box.position.x = attack_range * dir
		if attack_box.sprite:
			attack_box.sprite.flip_h = dir == 1
			attack_box.sprite.position.x = -abs(attack_box.sprite.position.x) * dir
	move_and_slide()

func take_damage(dmg, dmg_type, pos, kb = data.knockback):
	print("Damage Data: ", dmg_type, ' ', data.immunities)
	if dmg_type not in data.immunities and not immune_to_knockback:
		state_machine.on_child_transition(state_machine.current_state, "knockback")
	super.take_damage(dmg, dmg_type, pos, kb)

	
func update_player(new):
	player = new

func on_player_death():
	state_machine.current_state.Transitioned.emit(state_machine.current_state, "idle")
