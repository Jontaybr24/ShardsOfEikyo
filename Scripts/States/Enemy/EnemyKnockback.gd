extends EnemyState
class_name EnemyKnockback

@export var kb_time = .5

func Enter():
	if enemy.kb_timer < 0:
		enemy.kb_timer = kb_time

func Exit():
	enemy.velocity = Vector2()

func Physics_Update(delta: float):
	enemy.kb_timer -= delta
	if enemy.kb_timer < 0 and enemy.is_on_floor():
		Transitioned.emit(self, "idle")
