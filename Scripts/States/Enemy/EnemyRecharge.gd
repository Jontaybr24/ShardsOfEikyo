extends EnemyState
class_name EnemyRecharge

@export var time_to_recharge = 0.5

func Enter():
	enemy.sprite.modulate = Color.WHITE
	if enemy.action_timer <= 0:
		enemy.action_timer = time_to_recharge

func Physics_Update(delta: float):
	if enemy.action_timer < 0:
		Transitioned.emit(self, "follow")
