extends EnemyState
class_name EnemyFalling

func Physics_Update(delta: float):
	super.Physics_Update(delta)
	if enemy.is_on_floor():
		if enemy.second_phase and enemy.smash_count < enemy.num_smashes:
			enemy.smash_count += 1
			Transitioned.emit(self, "smash")
		else:
			Transitioned.emit(self, "idle")
