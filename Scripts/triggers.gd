extends Node

@export var disabled = false

func _ready():
	if disabled:
		for child in get_children():
			child.queue_free()
