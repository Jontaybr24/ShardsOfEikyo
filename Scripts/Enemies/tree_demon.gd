extends Entity

var enemy = preload("res://Scenes/Enemies/enemy.tscn")
@export var spawn_height: float

var spawn_range = 600
var spawn_time = 5

func _init():
	health = 300
	armor = 0
	armor_type = null
	type = TypeManager.ELEMENTS.WOOD

func _process(delta: float) -> void:
	pass
	#if the_player:
		#if abs(the_player.position.x - position.x) < spawn_range:
			#time_since_spawn += delta
	
	
