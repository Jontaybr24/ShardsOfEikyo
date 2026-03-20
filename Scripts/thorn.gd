extends Attack

func _ready():
	parent = self
	
func _physics_process(delta: float) -> void:
	if tic_time < 0:
		for area in get_overlapping_areas():
			var body = area.get_parent()
			if body.is_in_group("Player"):
				inflict_damage(body)
	else:
		tic_time -= delta
