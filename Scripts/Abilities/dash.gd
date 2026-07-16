extends Ability


func Update(delta):
	if player.data.Dash:
		if Input.is_action_just_pressed('dash') and player.dash_timer < 0:
			player.state_machine.on_child_transition(player.state_machine.current_state, "dash")
			print("using new dash")
		if Input.is_action_pressed("dash") and player.is_on_floor():
				player.current_states.append(player.CONDITIONS.SPRINTING)
		if Input.is_action_just_released("dash"):
			player.current_states.erase(player.CONDITIONS.SPRINTING)
	
	if Input.is_action_just_released("dash"):
		player.current_states.erase(player.CONDITIONS.SPRINTING)
	
	if player.CONDITIONS.SPRINTING in player.current_states and not Input.is_action_pressed("dash"):
		player.current_states.erase(player.CONDITIONS.SPRINTING)
