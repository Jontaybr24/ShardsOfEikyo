extends Area2D
class_name Ability

@export var ability_name: String
@export_multiline var description: String
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var player : Player
var data = {}
var unlocked = false

func _ready():
	data = {
	"name": ability_name,
	"description": description
	}
	player = get_tree().get_first_node_in_group("Player")

# If the ability requires a listener or other conditions to activate the ability
func Update(delta):
	pass

# What the ability does
func activate():
	pass
	
func activate_interaction():
	show()
	collision_shape_2d.disabled = false
	
func deactivate_interaction():
	hide()
	collision_shape_2d.disabled = true

func set_data(meta_data):
	data = meta_data
