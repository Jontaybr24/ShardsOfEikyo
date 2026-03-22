extends Node

signal text_requested(text)
signal player_spawned(new_player)
signal player_died()
signal paused_game()
signal inventory()
signal setting_spawn(checkpoint)

var player_scene = preload("res://Scenes/naiko.tscn")
var spawnpoint: Node2D

var current_player: Node2D
var in_inventory = false
var paused = false
var last_pause = 0
var input_spam_delay = .1
var player_data = {}
var deaths = 0
var respawn_time = 3

enum State {
	INACTIVE,
	ACTIVE,
}
var current_state := State.ACTIVE

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	last_pause += delta
	
	if Input.is_action_just_pressed("pause"):
		pause_game()
	#if Input.is_action_just_pressed('inventory') and !paused:
		#show_inventory()

func respawn_player():
	deaths += 1
	if current_player:
		player_data = current_player.data
		current_player.queue_free()
	emit_signal("player_died")
	
	# wait the respawn time before continiuing
	await get_tree().create_timer(respawn_time).timeout
	
	current_player = player_scene.instantiate()
	current_player.data = player_data
	if current_player.data.Channel and current_player.data.shards < 100:
		current_player.data.shards = 100
	add_child(current_player)
	if spawnpoint: # spawn using checkpoint
		current_player.position = spawnpoint.global_position
	else: # Default spawn
		current_player.position = Vector2(0, 175) 
	emit_signal("player_spawned", current_player)

func set_spawn(new_spawn):
	spawnpoint = new_spawn
	emit_signal("setting_spawn", spawnpoint)

func get_player():
	return current_player

func set_player(player):
	current_player = player
	emit_signal("player_spawned", current_player)
	
func text_request(text):
	emit_signal("text_requested", text)
	current_state = State.INACTIVE
	get_tree().paused = true

func end_text():
	current_state = State.ACTIVE
	get_tree().paused = false

func pause_game():
	if in_inventory or current_state == State.INACTIVE: return
	if last_pause > 0 and last_pause < input_spam_delay: return
	last_pause = 0
	emit_signal('paused_game')
	paused = !paused
	get_tree().paused = !get_tree().paused
	
func show_inventory():
	if paused: return
	if last_pause > 0 and last_pause < input_spam_delay: return
	last_pause = 0
	emit_signal('inventory')
	in_inventory = !in_inventory
	get_tree().paused = !get_tree().paused
