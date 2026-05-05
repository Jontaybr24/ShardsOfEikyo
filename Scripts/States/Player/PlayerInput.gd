extends PlayerState
class_name PlayerInput

var jump_ready = false
var channel_timer = 0
var interaction_delay = .2
var interaction_timer = 0
var perserve_sprint = false

func Enter():
	super.Enter()
	if player and player.sprite:
		player.sprite.play("Idle")

func Exit():
	player.boosting_jump = false
	player.channeling = false
	if not perserve_sprint: player.sprinting = false

func Update(delta: float):
	if not player:
		return
	
	if interaction_timer > 0:
		interaction_timer -= delta
	
	if Input.is_action_just_pressed("jump") and player.is_on_floor() and player.interactables.size() == 0:
		player.jump(1.15 if player.sprinting else 1)
	
	if player.buffered_input == 'jump' and (player.is_on_floor() or player.jump_ready):
		player.jump(1.15 if player.sprinting else 1)
		player.buffered_input = ''
	
	if Input.is_action_just_released("jump"):
		player.boosting_jump = false
	
	player.dir = Input.get_axis("left", "right")
	var speed = player.move_speed * (player.sprint_multiplier if player.sprinting else 1.0)\
	* (player.slow_multiplier if player.stuck else 1.0)
	player.position.x += player.dir * speed * delta
	
	if player.is_on_floor():
		if player.data.Doublejump: player.has_second_jump = true
		jump_ready = false
	elif jump_ready and Input.is_action_just_pressed("jump") and player.has_second_jump:
		jump_ready = false
		player.has_second_jump = false
		player.jump()
	
	if Input.is_action_just_released("jump"): jump_ready = true
	
	if player.data.Shield and Input.is_action_just_pressed("block") \
	and not player.shield_broke:
		Transitioned.emit(self, "block")
		
	if player.data.Channel and Input.is_action_pressed('channel_hold') \
	and player.data.shards >= player.channel_min:
		player.channeling = true
		
	if player.data.Channel and Input.is_action_just_released('channel_hold') \
	or player.data.shards < player.channel_min:
		player.channeling = false
	
	if Input.is_action_just_pressed('attack'):
		if Input.is_action_pressed('down') and not player.is_on_floor():
			if player.channeling:
				player.add_shards(-player.channel_cost)
				player.emit_signal('shards_changed', player.data.shards)
				player.current_attack = player.attacks.get_node("Channel Pogo")
			else:
				player.current_attack = player.attacks.get_node("Pogo")
		else:
			player.current_attack = player.CheckCombo()
		perserve_sprint = true
		Transitioned.emit(self, "attack")
		
	if Input.is_action_just_released('attack'):
		if player.charged:
			player.current_attack = player.attacks.get_node("Attack")
			player.current_attack.bonus = player.charged_bonus
			player.charged = false
			Transitioned.emit(self, "attack")
		player.time_since_charge = 0
		
	if Input.is_action_just_pressed('spell'):
		if player.data.Inkslam and Input.is_action_pressed("down") \
		and not player.is_on_floor():
			Transitioned.emit(self, "slam")
		elif player.data.Inkblast:
			player.current_attack = player.attacks.get_node("Spell")
			Transitioned.emit(self, "attack")
	
	if not player.charged and Input.is_action_pressed('attack'):
		player.time_since_charge += delta
	
	if player.data.Dash:
		if Input.is_action_just_pressed('dash') and player.dash_timer < 0:
			Transitioned.emit(self, "dash")
		if Input.is_action_pressed("dash") and player.is_on_floor():
			player.sprinting = true
		if Input.is_action_just_released("dash"):
			player.sprinting = false
	
	if Input.is_action_just_pressed('heal') and player.current_ink < player.data.max_ink:
		Transitioned.emit(self, "heal")
	
	if player.can_climb and player.state_machine.current_state.name != "climb" \
	and (Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		Transitioned.emit(self, "climb")
	
	if Input.is_action_just_pressed("confirm") and player.interactables.size() > 0 and interaction_timer <= 0:
		interaction_timer = interaction_delay
		player.interactables.back().interact()
