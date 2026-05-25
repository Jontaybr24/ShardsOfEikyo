extends PlayerState
class_name PlayerDash

# dash
var dash_start_pos = 0
var dash_cooldown = 0.5
var dash_velocity = Vector2(1500, 0)
var dash_distance = 200
var last = 0
var dir = 0

func Enter():
	super.Enter()
	var new_dir = Input.get_axis("left", "right")
	player.position.y -= 5
	dash_start_pos = player.global_position.x
	player.current_states.append(player.CONDITIONS.INVULNERABLE)
	player.current_states.erase(player.CONDITIONS.STUCK)
	player.set_collision_mask_value(3, false)
	TypeManager.set_collision_mask_type(player, TypeManager.ELEMENTS.INK, true)
	dir = player.last_dir if new_dir == 0 else sign(new_dir)
	player.velocity = Vector2(dash_velocity[0] * dir, 0)
	player.type = TypeManager.ELEMENTS.INK
	player.indicator.update()
	
func Exit():
	if abs(player.velocity.x) >= dash_velocity[0]:
		player.velocity.x -= dash_velocity[0] * dir
	player.current_states.erase(player.CONDITIONS.INVULNERABLE)
	player.set_collision_mask_value(3, true)
	TypeManager.set_collision_mask_type(player, TypeManager.ELEMENTS.INK, false)
	player.dash_timer = dash_cooldown
	player.type = TypeManager.ELEMENTS.WOOD
	player.indicator.update()

func Physics_Update(delta: float):
	player.velocity.y = 0
	if abs(player.global_position.x - dash_start_pos) > dash_distance or last == player.global_position.x:
		Transitioned.emit(self, "listen")
	last = player.global_position.x
