extends CanvasLayer

@onready var panel: Panel = $Panel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	GameManager.inventory.connect(toggle_inventory)
	panel.visible = false
	visible = false

func _process(delta: float) -> void:
	pass

func toggle_inventory():
	panel.visible = !panel.visible
	visible = !visible
