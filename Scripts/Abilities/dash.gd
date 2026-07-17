extends Ability

var dash_timer = 0
@export var dash_sound : AudioStream
@export var dash_recharge_sound : AudioStream

func Update(delta):
	if dash_timer > 0:
		dash_timer -= delta
	
	if Input.is_action_just_pressed('dash') and dash_timer <= 0:
		player.state_machine.on_child_transition(player.state_machine.current_state, "dash")
	
	if Input.is_action_pressed("dash") and player.is_on_floor():
			player.current_states.append(player.CONDITIONS.SPRINTING)
	
	if Input.is_action_just_released("dash"):
		player.current_states.erase(player.CONDITIONS.SPRINTING)
	
	if Input.is_action_just_released("dash"):
		player.current_states.erase(player.CONDITIONS.SPRINTING)
	
	if player.CONDITIONS.SPRINTING in player.current_states and not Input.is_action_pressed("dash"):
		player.current_states.erase(player.CONDITIONS.SPRINTING)
