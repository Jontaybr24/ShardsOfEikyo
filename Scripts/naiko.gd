extends CharacterBody2D

var move_speed = 300
var sprint_multiplier = 1.5
var jump_velocity = -900
var sprite: AnimatedSprite2D
var dir = 0
var last_dir = 1
var frozen = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2.5
var type = TypeManager.ELEMENTS.INK
var current_type = type
var current_attack = null
var heal_source = null
var buffered_input = ''

signal shield_changed(new_shield)
signal shards_changed(new_shard)
signal ink_changed(new_ink)
signal unlocked_spell()

@onready var attacks: Node2D = $Attacks
@onready var shield: Sprite2D = $Shield
@onready var channel_aura: Sprite2D = $"Channel Aura"
@onready var collision: CollisionShape2D = $Interaction/CollisionShape2D
@onready var state_machine = $"State Machine"
@onready var indicator: Node2D = $"Type Indicator"

@export var unlock_abilities = false


# health stats
var max_shield = 50
var max_ink = 60
var current_shield = max_shield
var current_ink = max_ink

enum CONDITIONS {
	DEFAULT,
	BLOCK,
	INVULNERABLE,
	CHANNEL,
	SUSPENDED
}

var current_state = CONDITIONS.DEFAULT

# shield
var shield_regen = 20
var shield_broke = false

# taking damage
# amount of time in seconds that the player is immune to damage after getting hit
var iframes = .25
var knockback = Vector2(600, -600)

# dealing damage
var attack_timer = 0
var attack_delay = .2 # the amount of time before the player can attack again
var attack_recharge = .6
var attack_damage = 10

# the number of attacks in the attack chain
var combo = 0
var max_combo = 3 

# timer to reset the combo if left incomplete
var reset_timer = 0
var reset_time = .6

# channeling
var channel_cost = 5
var channel_min = 5
var channel_time = .5
var channeling = false

var time_since_charge = 0
var charge_attack_time = .4
var charged = false
var charged_bonus = 10
var interactables: Array[Interactable]
var enemies: Array[Entity]
var healing_objects : Array[Area2D]

var max = 0

# moving
var has_second_jump = false
var jump_ready = false
var decay_velocity = false
var kill_velocity = 50
var can_climb = false

# dash
var dash_timer = 0

var data = {
	"Channel": false,
	"Inkblast": false,
	"Inkslam": false,
	"Doublejump": false,
	"Shield": false,
	"Dash": false,
	"Dash_mult": 1,
	"shards": 0,
	"max_ink": max_ink
}

var DMG_TYPE = TypeManager.ELEMENTS.WOOD

func _init():
	sprint_multiplier = 1
	z_index = 1
	
func _ready():
	print("player ready")
	process_mode = Node.PROCESS_MODE_PAUSABLE
	sprite = $AnimatedSprite2D
	GameManager.set_player(self)
	current_ink = data.max_ink
	emit_signal("shards_changed", data.shards)
	emit_signal("ink_changed", current_ink)
	for hurtbox in attacks.get_children():
		hurtbox.offset = abs(hurtbox.position.x)
	shield.hide()
	channel_aura.hide()
	if unlock_abilities:
		unlock_ability("block")
		unlock_ability("channel")
		unlock_ability("inkblast")
		unlock_ability("slam")
		unlock_ability("doublejump")
		unlock_ability("dash")
	max = position.y


func _physics_process(delta):
	sprint_multiplier = data.Dash_mult
	if current_ink <= 0 or position.y > 500:
		die()
	
	if sprite:
		sprite.flip_h = last_dir == 1
		if dir != 0:
			sprite.play("Walk")
			last_dir = dir
		else:
			sprite.play("Idle")
	# regen the shield when it's not being used or is broken
	if shield_broke or not Input.is_action_pressed("block") and current_shield < max_shield:
		current_shield = clamp(current_shield + shield_regen * delta, 0, max_shield)
		if current_shield == max_shield:
			shield_broke = false
			emit_signal("shield_changed", not shield_broke)
			shield.material.set_shader_parameter("tint", Color.WHITE)
	
	if channeling:
		channel_aura.show()
	else:
		channel_aura.hide()
	
	for enemy in enemies:
		if enemy.contact_damage: enemy.contact(self)
	
	if not is_on_floor() \
	and not current_state == CONDITIONS.SUSPENDED:
		velocity.y += gravity * delta
	
	# get the sign of last dir when it isn't a whole number
	last_dir = last_dir / abs(last_dir)
	for hurtbox in attacks.get_children():
		hurtbox.position.x = hurtbox.offset * last_dir
	
	if time_since_charge > charge_attack_time and not charged:
		charged = true
		sprite.modulate = Color.SKY_BLUE
		await get_tree().create_timer(.2).timeout
		sprite.modulate = Color.WHITE
		
	attack_timer -= delta
	reset_timer -= delta
	dash_timer -= delta
	
	if reset_timer < 0: combo = 0
	if combo >= max_combo:
		attack_timer = attack_recharge
		combo = 0
	
	if decay_velocity:
		velocity.x = round(velocity.x * .9)
		if abs(velocity.x) < kill_velocity: 
			velocity.x = 0
			decay_velocity = false
	
	move_and_slide()

func unlock_ability(ability):
	match ability:
		"slam":
			current_ink = data.max_ink
			data.Inkslam = true
			emit_signal("unlocked_spell")
			emit_signal("ink_changed", current_ink)
		"block":
			data.Shield = true
			emit_signal("shield_changed", not shield_broke)
		"inkblast":
			current_ink = data.max_ink
			data.Inkblast = true
			emit_signal("unlocked_spell")
			emit_signal("ink_changed", current_ink)
		"doublejump":
			data.Doublejump = true
		"channel":
			data.Channel = true
		"dash":
			data.Dash_mult = 2
			data.Dash = true

func add_ink(amount):
	current_ink = clamp(current_ink + amount, 0, data.max_ink)
	emit_signal("ink_changed", current_ink)

func add_shards(amount):
	data.shards += amount
	emit_signal("shards_changed", data.shards)

func take_damage(dmg, typ, source, kb = Vector2()):
	if current_state == CONDITIONS.INVULNERABLE: return
	var res = TypeManager.get_matchup(typ, type)
	var distance = global_position.x - source.x
	var dir = sign(distance)
	if kb == Vector2():
		kb = knockback
		
	if current_state == CONDITIONS.BLOCK and current_shield > 0:
		current_shield = clamp(current_shield - (dmg * res.scalar), 0, max_shield)
		if current_shield > 0:
			shield.material.set_shader_parameter("tint", Color.PINK)
			await get_tree().create_timer(iframes).timeout
			shield.material.set_shader_parameter("tint", Color.WHITE)
			return
		else:
			shield_broke = true
			shield.material.set_shader_parameter("tint", Color.RED)
			emit_signal("shield_changed", not shield_broke)
			current_state = CONDITIONS.DEFAULT
			add_knockback(kb, dir)
			return
	add_knockback(kb, dir)
	current_ink -= clamp((dmg * res.scalar), 0, data.max_ink)
	emit_signal("ink_changed", current_ink)

func add_knockback(vel, direction):
	velocity.x = vel[0] * direction
	velocity.y = vel[1]
	state_machine.on_child_transition(state_machine.current_state, "knockback")
	decay_velocity = true
	

func freeze():
	current_state = CONDITIONS.SUSPENDED
	velocity = Vector2(velocity.x, 0)

func unfreeze():
	current_state = CONDITIONS.DEFAULT

func die():
	GameManager.respawn_player()

func CheckAttackTime():
	return attack_timer < 0

func CheckCombo():
	var res = null
	if CheckAttackTime():
		reset_timer = reset_time
		attack_timer = attack_delay
		combo += 1
		if combo < max_combo:
			if channeling:
				add_shards(-channel_cost)
				emit_signal('shards_changed', data.shards)
				res = attacks.get_node("Channel")
			else:
				res = attacks.get_node("Attack")
		elif combo == max_combo:
			if channeling:
				add_shards(-channel_cost)
				emit_signal('shards_changed', data.shards)
				res = attacks.get_node("Heavy Channel")
			else:
				res = attacks.get_node("Heavy Attack")
		else:
			combo = 0
	return res

func _on_interaction_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if area.is_in_group("Ability"):
		var ability = area.data
		unlock_ability(ability.name)
		GameManager.text_request("Unlocked " + ability.name + "\n" + ability.description)
		area.queue_free()
	elif area.name == "Interaction" and area.get_parent().is_in_group("Enemy"):
		enemies.append(enemy)
		enemy.contact(self)
	elif area.is_in_group("Ink Source"):
		healing_objects.append(area)
	elif area.is_in_group("Climbable"):
		can_climb = true
	elif area.is_in_group("Interactable"):
		interactables.append(area)
	elif area.is_in_group("Ink Heart"):
		data.max_ink += 10
		area.queue_free()
		current_ink = data.max_ink
		emit_signal("ink_changed", current_ink)
		GameManager.text_request("Max Ink Increased")

func _on_interaction_area_exited(area: Area2D) -> void:
	if area == heal_source:
		healing_objects.erase(area)
	elif area.is_in_group("Climbable"):
		can_climb = false
	elif area.is_in_group("Interactable"):
		interactables.erase(area)
	elif area.name == "Interaction" and area.get_parent().is_in_group("Enemy"):
		var enemy = area.get_parent()
		enemies.erase(enemy)
