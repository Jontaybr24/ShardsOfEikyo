extends Parallax2D

@export var num_trees: int
@onready var canvas_group: CanvasGroup = $CanvasGroup

var tree = preload("res://Scenes/World Items/tree.tscn")

func _ready():
	canvas_group.material = canvas_group.material.duplicate()
	
	# Adds trees to the layer in random positions
	for num in range(num_trees):
		var new_tree = tree.instantiate()
		new_tree.position.x = randi_range(-30000, 30000)
		canvas_group.add_child(new_tree)
