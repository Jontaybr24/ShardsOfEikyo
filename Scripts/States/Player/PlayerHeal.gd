extends PlayerState
class_name PlayerHeal

var heal_time = 0.3
var succesive_heal_shave = 0.05
var heal_count = 0
var heal_timer = 0
var regen_rate = 5
@export var healSFX : AudioStream

func Enter():
	super.Enter()
	heal_timer = heal_time
	heal_count = 0
	if player.healing_objects == []:
		Transitioned.emit(self, "listen")

func Update(delta: float):
	if Input.is_action_just_released("heal") or player.current_ink >= player.data.max_ink\
	 or not player.healing_objects.back() or player.healing_objects.back().current_health <= 0:
		Transitioned.emit(self, "listen")
	
	heal_timer -= delta
	
	if heal_timer < 0:
		heal_count += 1
		player.current_ink = clamp(player.current_ink + regen_rate, 0, player.data.max_ink)
		player.healing_objects.back().take_damage(regen_rate)
		player.audio_out.stream = healSFX
		player.audio_out.play()
		heal_timer = clamp(heal_time - (succesive_heal_shave * heal_count), 0.1, heal_time)
		player.emit_signal("ink_changed", player.current_ink)
