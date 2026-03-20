extends CanvasLayer

@onready var panel: Panel = $Panel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	GameManager.paused_game.connect(toggle_menu)
	panel.visible = false
	visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		#quit()
		pass

func toggle_menu():
	panel.visible = !panel.visible
	visible = !visible

func quit():
	get_tree().quit()
