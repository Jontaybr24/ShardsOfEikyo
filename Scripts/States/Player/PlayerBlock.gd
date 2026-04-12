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
	player.type = TypeManager.ELEMENTS.WOOD
	player.indicator.update()
	player.emit_signal("blocking", true)
	player.current_state = player.CONDITIONS.BLOCK
	above_ground = true
	direction = Input.get_axis("left", "right")
	speed = player.move_speed * (player.sprint_multiplier if player.sprinting else 1.0)

func Exit():
	player.shield.hide()
	player.type = TypeManager.ELEMENTS.INK
	player.indicator.update()
	player.emit_signal("blocking", false)
	player.current_state = player.CONDITIONS.DEFAULT

func Update(delta: float):
	if player.current_state != player.CONDITIONS.SUSPENDED and above_ground:
		player.position.x += direction * speed * delta
	
	if player.is_on_floor():
		above_ground = false
	
	if !Input.is_action_pressed("block"):
		Transitioned.emit(self, "listen")
