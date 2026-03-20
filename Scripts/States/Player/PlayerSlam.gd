extends PlayerState
class_name PlayerSlam

var slam_velocity = 1000
var max_velocity = 0

func Enter():
	super.Enter()
	if player.current_ink <= player.attacks.get_node("Slam").cost:
		Transitioned.emit(self, "listen")
		return
	player.current_state = player.CONDITIONS.INVULNERABLE
	player.velocity.y = slam_velocity
	max_velocity = 0
func Exit():	
	player.current_state = player.CONDITIONS.DEFAULT

func Physics_Update(delta: float):
	if player.velocity.y > max_velocity:
		max_velocity = player.velocity.y
	if player.is_on_floor():
		var bonus = roundi(clamp(max_velocity - 1300, 0, 400) / 10)
		player.current_attack = player.attacks.get_node("Slam")
		player.current_attack.bonus = bonus
		Transitioned.emit(self, "attack")
