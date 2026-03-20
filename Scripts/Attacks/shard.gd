extends Sprite2D

func _physics_process(delta: float) -> void:
	flip_h = get_parent().flip_h
	if flip_h:
		rotation = abs(rotation) * -1
	else:
		rotation = abs(rotation)
		
