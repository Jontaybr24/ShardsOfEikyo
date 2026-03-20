extends BasicEnemy
class_name QuickInkling

func _ready():
	super._ready()
	move_speed = 200
	detection_range = 800
	attack_rate = .2
	vertical_range.min = -30
