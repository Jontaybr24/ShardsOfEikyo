extends BasicEnemy
class_name Demon

@onready var decisionstate: DemonFollow = $"State Machine/Follow"
var projectile = preload("res://Scenes/Attacks/fire.tscn")
var second_phase = false
var smash_count = 0
var num_smashes = 0


func _ready():
	super._ready()
	attack_range = 178
	detection_range = 10000
	vertical_range.min = -1000


func _physics_process(delta):
	super._physics_process(delta)
	move_and_slide()

func die():
	GameManager.text_request("You saved the forest! Thanks for playing!")
	super.die()

func take_damage(dmg, dmg_type, pos, kb = data.knockback):
	super.take_damage(dmg, dmg_type, pos, kb)
	if health < (data.health / 2) and not second_phase:
		second_phase = true
		armor = 150
		decisionstate.attacks.append("smash")
		decisionstate.colors.append(Color.BLACK)
		decisionstate.ranges.append(attack_range * 100)
