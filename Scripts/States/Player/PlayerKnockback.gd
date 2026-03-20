extends PlayerState
class_name PlayerKnockback

var kb_time = .2
var timer = 0
#func _ready():
	#buffer_time = 2

func Enter():
	super.Enter()
	timer = kb_time
	player.channeling = false
	player.current_state = player.CONDITIONS.INVULNERABLE
	player.sprite.modulate = Color.RED

func Exit():
	player.current_state = player.CONDITIONS.DEFAULT
	player.sprite.modulate = Color(1, 1, 1)

func Physics_Update(delta: float):
	timer -= delta
	if timer < 0 or player.is_on_floor():
		if !buffer():
			Transitioned.emit(self, "listen")
