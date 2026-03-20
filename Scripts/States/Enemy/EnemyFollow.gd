extends EnemyState
class_name EnemyFollow


func Physics_Update(delta: float):
	super.Physics_Update(delta)
	if distance > enemy.attack_range:
		enemy.velocity.x = enemy.move_speed * direction
	else:
		enemy.velocity.x = 0
		Transitioned.emit(self, "attack")
	
	if distance > enemy.detection_range or not enemy.in_range(vert):
		Transitioned.emit(self, "idle")
