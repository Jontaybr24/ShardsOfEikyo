extends StaticBody2D

@export var player : Node2D
@export var camera : Camera2D
var range = 300
var change = 1.0002
@export  var start : Vector2
@export var finish : Vector2
var diffrence
var total = 2000
var offset = 1001.0

func _ready():
	GameManager.player_spawned.connect(update_player)
	diffrence = start - finish
	#GameManager.text_request("Welcome to the first Shards of EIKYO Prototype")
	
func _process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = abs(player.position.x - position.x)
		var rate = diffrence
		var result = clamp(rate , finish, start)
		var progress = clamp(distance - offset, 0, total)
		var percent = progress / total
		#camera.zoom = finish + percent * diffrence

func update_player(new_player):
	player = new_player
