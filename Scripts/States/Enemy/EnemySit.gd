extends EnemyState
class_name EnenmySit

@export var detection_range = 1000

func Physics_Update(delta: float):
	super.Physics_Update(delta)
	
	if distance < enemy.detection_range:
		Transitioned.emit(self, "shoot")
