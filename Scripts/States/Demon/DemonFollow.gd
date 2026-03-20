extends EnemyState
class_name DemonFollow

var time_following = 0
var attacks = ["attack", "fire"]
var colors = [Color.BLUE, Color.RED]
var ranges = [0, 0]
var i = 0

func Enter():
	super.Enter()
	time_following = 0
	if ranges == [0, 0]:
		ranges[0] = enemy.attack_range
		ranges[1] = enemy.attack_range
	i = randi_range(0, attacks.size() - 1)

func Physics_Update(delta: float):
	super.Physics_Update(delta)
	
	time_following += delta
	
	if distance > ranges[i]:
		enemy.velocity.x = enemy.move_speed * direction
	else:
		enemy.velocity.x = 0
		var tween = create_tween()
		tween.tween_property(enemy.sprite, "modulate", colors[i], .1)
		Transitioned.emit(self, attacks[i])
	
	if distance > enemy.detection_range:
		Transitioned.emit(self, "idle")
	
	
	if time_following > 3:
		enemy.velocity.x = 0
		Transitioned.emit(self, "jump")
