extends CharacterBody2D
class_name Player

var move_speed = 300
var sprint_multiplier = 1.5
var slow_multiplier = .2
var jump_velocity = -620
var jump_timer = 0
var boost_timer = 0
var max_boost_time = .55
var boost_gravity_reduction = .5

var dir = 0
var last_dir = 1
var frozen = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2.5
var type = TypeManager.ELEMENTS.WOOD
var current_type = type
var current_attack = null
var heal_source = null
var buffered_input = ''

signal shield_available(shield_ready)
signal blocking(is_blocking)
signal shards_changed(new_shard)
signal shield_changed(new_shield)
signal ink_changed(new_ink)
signal ink_increased(amount)
signal unlocked_spell()

@onready var attacks: Node2D = $Attacks
@onready var shield: Sprite2D = $Shield
@onready var channel_aura: Sprite2D = $"Channel Aura"
@onready var collision: CollisionShape2D = $Interaction/CollisionShape2D
@onready var state_machine = $"State Machine"
@onready var indicator: Node2D = $"Type Indicator"
@onready var audio_in: AudioStreamPlayer2D = $AudioIn
@onready var audio_out: AudioStreamPlayer2D = $AudioOut
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export_group("Overides")
@export var unlock_abilities = false
@export var dash_unlocked = false
@export var block_unlocked = false
@export var channel_unlocked = false
@export var jump2_unlocked = false
@export var inkBlast_unlocked = false
@export var inkSlam_unlocked = false
@export var heal_unlocked = false

@export_group("Sounds")
@export var shield_break : AudioStream
@export var damage_sound : AudioStream
@export var death_sound : AudioStream
@export var charge_attack_sound : AudioStream
@export var dash_sound : AudioStream
@export var dash_recharge_sound : AudioStream
@export var heal_sound : AudioStream

var tilemap : TileMapLayer
var current_tile
var last_tile = null

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
	SUSPENDED,
	JUMPING,
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
var boosting_jump = false
var sprinting = false
var stuck = false

# dash
var dash_timer = 0

var data = {
	"Channel": false,
	"Inkblast": false,
	"Inkslam": false,
	"Doublejump": false,
	"Shield": true,
	"Dash": true,
	"Dash_mult": 1,
	"shards": 100,
	"max_ink": max_ink
}

var DMG_TYPE = TypeManager.ELEMENTS.WOOD

func _init():
	sprint_multiplier = 1
	z_index = 1
	
func _ready():
	print("player ready")
	process_mode = Node.PROCESS_MODE_PAUSABLE
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
	else:
		if dash_unlocked:
			unlock_ability("dash")
		if channel_unlocked:
			unlock_ability("channel")
		if jump2_unlocked:
			unlock_ability("doublejump")
		if inkBlast_unlocked:
			unlock_ability("inkblast")
		if inkSlam_unlocked:
			unlock_ability("slam")
		if block_unlocked:
			unlock_ability("block")
	max = position.y
	tilemap = get_tree().get_first_node_in_group("TileMap")
	current_tile = tilemap.get_cell_data(global_position)

func _physics_process(delta):
	sprint_multiplier = data.Dash_mult
	if current_ink <= 0 or position.y > 500:
		die()
	if sprite:
		sprite.flip_h = last_dir == 1
		if dir != 0 and state_machine.current_state.name.to_lower() == "listen":
			sprite.play("Walk")
			last_dir = dir
			current_tile = tilemap.get_cell_data(global_position)
			if current_tile != last_tile:
				last_tile = current_tile
				check_tile_type()
		else:
			sprite.play("Idle")
	# regen the shield when it's not being used or is broken
	if shield_broke or not Input.is_action_pressed("block") and current_shield < max_shield:
		current_shield = clamp(current_shield + shield_regen * delta, 0, max_shield)
		emit_signal("shield_changed", current_shield)
		if current_shield == max_shield:
			shield_broke = false
			emit_signal("shield_available", not shield_broke)
			shield.material.set_shader_parameter("tint", Color.WHITE)
	
	if channeling:
		channel_aura.show()
	else:
		channel_aura.hide()
	
	for enemy in enemies:
		if enemy.contact_damage: enemy.contact(self)
		
	if not is_on_floor() \
	and not current_state == CONDITIONS.SUSPENDED:
		var new_grav = gravity * delta * (boost_gravity_reduction if boosting_jump else 1)
		velocity.y += new_grav
	
	if current_state == CONDITIONS.JUMPING and is_on_floor() and jump_timer > .05:
		current_state = CONDITIONS.DEFAULT
	
	if current_state == CONDITIONS.JUMPING and boost_timer > 0\
	and Input.is_action_pressed("jump"):
		boosting_jump = true
	
	if boost_timer < 0 or is_on_floor(): 
		boosting_jump = false
	
	# get the sign of last dir when it isn't a whole number
	last_dir = last_dir / abs(last_dir)
	for hurtbox in attacks.get_children():
		hurtbox.position.x = hurtbox.offset * last_dir
	
	if time_since_charge > charge_attack_time and not charged:
		charged = true
		audio_out.stream = charge_attack_sound
		audio_out.play()
		sprite.modulate = Color.SKY_BLUE
		await get_tree().create_timer(.2).timeout
		sprite.modulate = Color.WHITE
		
	attack_timer -= delta
	reset_timer -= delta
	dash_timer -= delta
	if current_state == CONDITIONS.JUMPING:
		jump_timer += delta
		boost_timer -= delta
	
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
			emit_signal("shield_available", not shield_broke)
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
			data.Dash_mult = 1.75
			data.Dash = true

func check_tile_type():
	if current_tile:
		var tile_type = current_tile.get_custom_data("tile_type")
		match tile_type:
			"shard_vine":
				stuck = true
			_:
				print("Not Vine")
	else:
		stuck = false

func add_ink(amount):
	if amount > 1 and current_ink < data.max_ink:
		audio_out.stream = heal_sound
		audio_out.play()
	current_ink = clamp(current_ink + amount, 0, data.max_ink)
	emit_signal("ink_changed", current_ink)

func add_shards(amount):
	data.shards += amount
	emit_signal("shards_changed", data.shards)

func take_damage(dmg, attack_type, source, kb = Vector2()):
	if current_state == CONDITIONS.INVULNERABLE: return
	var res = TypeManager.get_matchup(attack_type, type)
	var distance = global_position.x - source.x
	var dir = sign(distance)
	print(dmg * res.scalar, " damage taken")
	audio_in.stream = res.SFX
	audio_in.play()
	if kb == Vector2():
		kb = knockback
		
	if current_state == CONDITIONS.BLOCK and current_shield > 0:
		if res.scalar < 0:
			add_ink(dmg * -res.scalar)
			emit_signal("ink_changed", current_ink)
		else:
			current_shield = clamp(current_shield - (dmg * res.scalar * 0.5), 0, max_shield)
			emit_signal("shield_changed", current_shield)
		if current_shield > 0:
			shield.material.set_shader_parameter("tint", Color.PINK)
			await get_tree().create_timer(iframes).timeout
			shield.material.set_shader_parameter("tint", Color.WHITE)
			return
		else:
			audio_in.stream = shield_break
			audio_in.play()
			shield_broke = true
			shield.material.set_shader_parameter("tint", Color.RED)
			emit_signal("shield_available", not shield_broke)
			current_state = CONDITIONS.DEFAULT
			add_knockback(kb, dir)
			return
	add_knockback(kb, dir)
	current_ink -= clamp((dmg * res.scalar), 0, data.max_ink)
	audio_out.stream = damage_sound
	audio_out.play()
	emit_signal("ink_changed", current_ink)

func add_knockback(vel, direction):
	velocity.x = vel[0] * direction
	velocity.y = vel[1]
	state_machine.on_child_transition(state_machine.current_state, "knockback")
	decay_velocity = true

func freeze():
	current_state = CONDITIONS.SUSPENDED
	velocity = Vector2(velocity.x, 0)
	sprinting = false

func unfreeze():
	current_state = CONDITIONS.DEFAULT

func die():	
	audio_in.reparent(get_parent())
	audio_in.finished.connect(audio_in.queue_free)
	audio_out.stream = death_sound
	audio_out.play()
	audio_out.reparent(get_parent())
	audio_out.finished.connect(audio_out.queue_free)
	GameManager.respawn_player()

func jump(percentage = 1.0):
	velocity = jump_velocity * Vector2(0, percentage)
	current_state = CONDITIONS.JUMPING
	boost_timer = max_boost_time
	jump_timer = 0

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
		var amount = 10
		data.max_ink += amount
		area.queue_free()
		current_ink = data.max_ink
		emit_signal("ink_increased", amount)
		emit_signal("ink_changed", current_ink)
		GameManager.text_request("Max Ink Increased")

func _on_interaction_area_exited(area: Area2D) -> void:
	if area.is_in_group("Ink Source"):
		healing_objects.erase(area)
	elif area.is_in_group("Climbable"):
		can_climb = false
	elif area.is_in_group("Interactable"):
		interactables.erase(area)
	elif area.name == "Interaction" and area.get_parent().is_in_group("Enemy"):
		var enemy = area.get_parent()
		enemies.erase(enemy)
