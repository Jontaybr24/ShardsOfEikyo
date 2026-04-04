extends State
class_name PlayerState

@export var player : Player
var buffer_timer = 0
var buffer_time = .3

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	player.buffered_input = ''

func _unhandled_input(event: InputEvent) -> void:
	BufferInput(event)

func Update(delta: float):
	buffer_timer -= delta
	if player.buffered_input:
		if buffer_timer < 0: player.buffered_input = ''

func BufferInput(event):
	if not player:
		return
	if event.is_action_pressed('attack'):
		player.buffered_input = 'attack'
		buffer_timer = buffer_time
	if event.is_action_pressed('dash'):
		player.buffered_input = 'dash'
		buffer_timer = buffer_time
	if event.is_action_pressed('jump') and player.is_on_floor():
		player.buffered_input = 'jump'
		buffer_timer = buffer_time
	if event.is_action_pressed('block'):
		player.buffered_input = 'block'
		buffer_timer = buffer_time

func buffer():
	if player.buffered_input == 'attack':
		player.buffered_input = ''
		player.current_attack = player.CheckCombo()
		Transitioned.emit(self, 'attack')
		return true
	elif player.buffered_input == 'block' and player.data.Shield:
		player.buffered_input = ''
		Transitioned.emit(self, 'block')
		return true
	elif player.buffered_input == 'dash' and player.data.Dash:
		player.buffered_input = ''
		Transitioned.emit(self, 'dash')
		return true
	return false
	
