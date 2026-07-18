extends Ability

func Update(delta):
	if Input.is_action_just_pressed("block") and not player.shield_broke:
		player.state_machine.on_child_transition(player.state_machine.current_state, "block")
