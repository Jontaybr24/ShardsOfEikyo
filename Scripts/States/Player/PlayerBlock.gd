extends PlayerState
class_name PlayerBlock

var above_ground : bool = false
var speed : float
var direction

func Enter():
	super.Enter()
	if player.shield_broke:
		Transitioned.emit(self, "listen")
		return
	player.shield.show()
	player.sprite.play("Block")
	player.emit_signal("blocking", true)
	player.current_states.append(player.CONDITIONS.BLOCK)
	above_ground = true
	direction = Input.get_axis("left", "right")
	speed = player.move_speed * (player.sprint_multiplier\
	if player.CONDITIONS.SPRINTING in player.current_states else 1.0)

func Exit():
	player.shield.hide()
	player.emit_signal("blocking", false)
	player.current_states.erase(player.CONDITIONS.BLOCK)

func Update(delta: float):
	if player.CONDITIONS.SUSPENDED not in player.current_states and above_ground:
		player.position.x += direction * speed * (player.slow_multiplier\
		if player.CONDITIONS.STUCK in player.current_states else 1) * delta
	
	if player.is_on_floor():
		above_ground = false
	
	if !Input.is_action_pressed("block"):
		Transitioned.emit(self, "listen")
