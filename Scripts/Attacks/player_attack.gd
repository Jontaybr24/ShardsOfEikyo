extends Attack
class_name AttackPlayer

@export var cost = 0
@export var freeze_on_start = false
@export var freeze_on_success = false

func _ready():
	super._ready()
	start_delay = 0
