extends Area2D

@export var ability_name: String
@export_multiline var description: String
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var data = {}

func _ready():
	data = {
	"name": ability_name,
	"description": description
	}

func activate():
	visible = true
	collision_shape_2d.disabled = false
	
func deactivate():
	visible = false
	collision_shape_2d.disabled = true

func set_data(meta_data):
	data = meta_data
