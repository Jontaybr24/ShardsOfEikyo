extends Attack

@export var permanent = false
var lifetime = 0

func _ready():
	parent = self
	GameManager.player_died.connect(despawn)
	
func _physics_process(delta: float) -> void:
	if not permanent:
		lifetime += delta
		if lifetime > duration:
			queue_free()
	
	if tic_time < 0:
		for area in get_overlapping_areas():
			var body = area.get_parent()
			if body:
				inflict_damage(body)
			if area.is_in_group("Flammable"):
				area.take_damage(damage)
	else:
		tic_time -= delta

func despawn():
	if not permanent:
		queue_free()
