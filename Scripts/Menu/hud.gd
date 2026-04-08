extends CanvasLayer

@onready var shard_label: Label = $"Shard/Label"
@onready var ink_label: Label = $"Ink/Label"
@onready var timer_label: Label = $"Timer Label"
@onready var ink: Control = $"Ink UI"
@onready var shield: Control = $Shield
@onready var ink_bar: ProgressBar = $Ink/HealthBar
@onready var shield_bar: ProgressBar = $Shard/ShieldBar

var current_shield = 0
var current_shard = 0
var current_ink = 0
var timepassed = 0

func _ready():
	GameManager.connect("player_spawned", player_spawned)
	visible = true
	shield.hide()

func _process(delta):
	timepassed += delta
	set_time(timepassed)

func set_ink(amount):
	ink_label.text = str(int(round(amount)))
	ink_bar.value = float(round(amount))
	current_ink = amount
	if amount < 5:
		return
	if current_ink > amount:
		ink_label.modulate = Color.RED
	elif current_ink < amount:		
		ink_label.modulate = Color.GREEN
	await get_tree().create_timer(.2).timeout
	ink_label.modulate = Color.WHITE
	
func set_shield(amount):
	shield_bar.value = float(round(amount))
	current_shield = amount
	
func shield_bar_visible(visible):
	shield_bar.visible = visible
	
func set_shard(amount):
	shard_label.text = str(int(round(amount)))
	current_shard = amount

func player_spawned(new_player):
	new_player.connect("shards_changed", set_shard)
	new_player.connect("ink_changed", set_ink)
	new_player.connect("shield_available", show_shield)
	new_player.connect("blocking", shield_bar_visible)
	new_player.connect("shield_changed", set_shield)

func round_to(value: float, places: int) -> float:
	var factor = pow(10, places)
	return round(value * factor) / factor

func set_time(time):
	var current = str(round_to(time, 2))
	if time: timer_label.text = current

func show_shield(toggle):
	if toggle:
		shield.show()
	else:
		shield.hide()
