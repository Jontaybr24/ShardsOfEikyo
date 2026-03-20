extends EnemyState
class_name DemonJump

var time_til_jump = 0
var jump_time = 1
var jump_velocity = Vector2(400, -600)

func Enter():
	super.Enter()
	time_til_jump = jump_time

func Physics_Update(delta: float):
	super.Physics_Update(delta)
	time_til_jump -= delta

	if time_til_jump < 0:
		enemy.velocity = jump_velocity * Vector2(direction, 1)
		Transitioned.emit(self, "falling")
