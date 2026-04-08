extends PlayerState
class_name PlayerBlock

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

func Exit():
	player.shield.hide()
	player.type = TypeManager.ELEMENTS.INK
	player.indicator.update()
	player.emit_signal("blocking", false)
	player.current_state = player.CONDITIONS.DEFAULT

func Update(delta: float):
	if !Input.is_action_pressed("block"):
		Transitioned.emit(self, "listen")
