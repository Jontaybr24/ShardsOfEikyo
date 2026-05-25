extends PlayerState
class_name PlayerAttack

var attack = Node2D

func Enter():
	attack = player.current_attack
	#print("Entering Attack")
	if not attack or player.current_ink <= attack.cost:
		#print("Can't Attack")
		await get_tree().process_frame
		Transitioned.emit(self, "listen")
		return
	else:
		#print("Can Attack")
		if attack.freeze_on_start: 
			player.freeze()
		if attack.freeze_on_success: 
			attack.hit_successful.connect(player.freeze, CONNECT_ONE_SHOT)
		if attack.name.to_lower() == "pogo" or attack.name.to_lower() == "channel pogo":
			attack.hit_successful.connect(func (): 
				player.velocity.y = player.jump_velocity
				player.has_second_jump = true,
				CONNECT_ONE_SHOT)
		player.add_ink(-attack.cost)
		player.emit_signal("ink_changed", player.current_ink)
		player.attack_timer = attack.duration
		#print("Finding targets ", attack)
		var hits = await attack.flash()
		#print("Found targets ", attack)
		if not attack:
			print("Can't Get me this time you silly monster bug")
			await get_tree().process_frame
			Transitioned.emit(self, "listen")
			return

		if !buffer():
			#print("Done with attack(No Buffer)", attack)
			Transitioned.emit(self, "listen")

func Exit():
	if attack and attack.hit_successful.is_connected(player.freeze):
		attack.hit_successful.disconnect(player.freeze)
	player.current_attack = null
	player.unfreeze()

func Update(delta: float):
	if player.CONDITIONS.SUSPENDED not in player.current_states:
		player.dir = Input.get_axis("left", "right")
		var speed = player.move_speed * (player.sprint_multiplier if player.sprinting else 1.0)
		player.position.x += player.dir * speed * delta
	
	if Input.is_action_just_released("dash"):
		player.sprinting = false
