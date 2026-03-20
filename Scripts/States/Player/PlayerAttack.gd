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
		if attack.freeze_player: player.freeze()
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
		
		for hit in hits:
			var pogo = false
			if is_instance_valid(hit) and hit.is_in_group("Attackable"):
				if !pogo and attack.name.to_lower() == "pogo" or attack.name.to_lower() == "channel pogo":
					player.velocity.y = player.jump_velocity * .66
					pogo = true
		if !buffer():
			#print("Done with attack(No Buffer)", attack)
			player.current_attack = null
			Transitioned.emit(self, "listen")

func Exit():
	player.unfreeze()
