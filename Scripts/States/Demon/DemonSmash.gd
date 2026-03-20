extends EnemyState
class_name DemomSmash

var target = 0
var y_vel = -600
var x_vel = 0
var air_time = 2

func Enter():
	super.Enter()
	if player:
		target = player.global_position.x
	else:
		target = enemy.global_position.x
	
	if enemy.smash_count == 0:
		enemy.num_smashes = randi_range(2, 5)
	elif enemy.smash_count > enemy.num_smashes:
		enemy.num_smashes = 0
		enemy.smash_count = 0
		Transitioned.emit(self, "idle")
	enemy.smash_count += 1
	x_vel = (target - enemy.global_position.x) / air_time
	enemy.velocity = Vector2(x_vel, y_vel)

func Physics_Update(delta: float):
	if abs(enemy.global_position.x - target) < 5:
		enemy.velocity = Vector2(0, 600)
		Transitioned.emit(self, "falling")
