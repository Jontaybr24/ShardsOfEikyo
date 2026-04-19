extends EnemyState
class_name EnemyAttack

var attack: Area2D

func Enter():
	super.Enter()
	attack = enemy.attack_box
	await get_tree().create_timer(attack.start_delay).timeout
	await attack.flash()
	enemy.combo += 1
	print(enemy.combo, ' ', enemy.max_combo)
	if enemy.combo >= enemy.max_combo:
		enemy.combo = 0
		Transitioned.emit(self, "recharge")
	elif distance > enemy.attack_range:
		Transitioned.emit(self, "follow")
	else:
		Transitioned.emit(self, "attack")
