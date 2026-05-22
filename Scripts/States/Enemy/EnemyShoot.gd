extends EnemyState
class_name EnemyShoot

@export var shoot_rate = 2
@export var shot_count = 1
@export var offset = Vector2()
@export var exit_delay = 0
@export var charged_up_SFX : AudioStream
@export var fire_SFX : AudioStream
@export var charged_up_mark : float

var shoot_timer = 0
var exit_timer = 0
var num_shots = 0

func Enter():
	super.Enter()
	shoot_timer = shoot_rate / 2
	num_shots = 0
	exit_timer = exit_delay

func Physics_Update(delta: float):
	super.Physics_Update(delta)
	shoot_timer -= delta
	if shoot_timer < charged_up_mark and !enemy.audio_player.playing:
		enemy.audio_player.stream = charged_up_SFX
		enemy.audio_player.play()
	if shoot_timer < 0 and is_instance_valid(player) and num_shots < shot_count:
		enemy.audio_player.stream = fire_SFX
		enemy.audio_player.play()
		num_shots += 1
		shoot_timer = shoot_rate
		var projectile = enemy.projectile.instantiate()
		if enemy.sprite.flip_h: direction = -1
		else: direction = 1
		projectile.dir = direction
		projectile.parent = enemy
		projectile.position = enemy.global_position + (offset * Vector2(direction, 1))
		get_tree().get_first_node_in_group("Projectile Layer").add_child(projectile)
	if num_shots >= shot_count:
		exit_timer -= delta
	if distance > enemy.detection_range or exit_timer < 0:
		Transitioned.emit(self, "idle")
