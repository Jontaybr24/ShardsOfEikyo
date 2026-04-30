extends Camera2D

@export var player: Node2D
var yOffset = -444
var transition_offsest = -120
var ceiling = 0
var floor = 0
var viewport_size : Vector2

func _ready() -> void:
	GameManager.player_spawned.connect(_on_player_spawned)
	viewport_size = get_viewport_rect().size
	ceiling = get_screen_center_position().y - (viewport_size.y / 2) / zoom.y + transition_offsest
	floor = get_screen_center_position().y + (viewport_size.y / 2) / zoom.y

func _process(delta: float) -> void:
	if not player:
		return
	#position = Vector2(player.global_position.x, floor + yOffset)
	var player_yPos = player.global_position.y
	if player_yPos > floor + transition_offsest:
		lower_cam()
	if player_yPos < ceiling:
		raise_cam()
	#yOffset -= 100 * delta
	#print(yOffset)

func _on_player_spawned(new_player: Node2D) -> void:
	player = new_player

func lower_cam():
	ceiling += viewport_size.y
	floor += viewport_size.y
func raise_cam():
	ceiling -= viewport_size.y
	floor -= viewport_size.y
