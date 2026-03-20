extends EnemyState
class_name EnemyIdle


var move_direction = 1
var wander_time = 1.0

func Enter():
	super.Enter()
	if enemy.sprite:
		enemy.sprite.modulate = Color.WHITE

func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		move_direction *= -1
		wander_time = 1.0

func Physics_Update(delta: float):
	super.Physics_Update(delta)
	if enemy.action_timer > 0:
		Transitioned.emit(self, "recharge")
		return
	if distance < enemy.detection_range and enemy.in_range(vert):
		Transitioned.emit(self, "follow")
	enemy.velocity.x = move_direction * enemy.move_speed
