extends PlayerInput
class_name PlayerClimb

var climb_speed = 300

func Enter():
	super.Enter()
	player.freeze()
	
func Exit():
	player.unfreeze()
	player.jump_ready = true
	player.has_second_jump = true

func Update(delta: float):
	var movement = Input.get_axis("up", "down")
	player.position.y += movement * climb_speed * delta
	
	if Input.is_action_just_pressed("jump"):
		player.velocity.y = player.jump_velocity
		Transitioned.emit(self, "listen")
	if not player.can_climb:
		Transitioned.emit(self, "listen")
	super.Update(delta)
