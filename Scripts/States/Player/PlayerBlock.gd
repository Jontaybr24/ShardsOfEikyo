extends PlayerState
class_name PlayerBlock

func Enter():
	super.Enter()
	if player.shield_broke:
		Transitioned.emit(self, "listen")
		return
	player.shield.show()
	player.sprite.play("Block")
	player.type = GameManager.ELEMENTS.ROOT
	player.indicator.update()
	player.current_state = player.CONDITIONS.BLOCK

func Exit():
	player.shield.hide()
	player.type = GameManager.ELEMENTS.INK
	player.indicator.update()
	player.current_state = player.CONDITIONS.DEFAULT

func Update(delta: float):
	if !Input.is_action_pressed("block"):
		Transitioned.emit(self, "listen")
