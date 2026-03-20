extends EnemyState
class_name DemonWait

var range = 400

func Physics_Update(delta: float):
	super.Physics_Update(delta)
	if not enemy or not player:
		return
	if abs(player.position.x - enemy.global_position.x) < range:
		Transitioned.emit(self, "Follow")
