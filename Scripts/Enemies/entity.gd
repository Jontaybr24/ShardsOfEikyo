extends CharacterBody2D
class_name Entity

signal died

@export var health = 30
@export var armor = 0
@export var damage = 5
@export var loot_table : Array[LootEntry]
@export var knockback = Vector2(150, -200)
@export var immunities = [TypeManager.ELEMENTS.NONE]
@export var base_type = TypeManager.ELEMENTS.NONE
@export var armor_type = TypeManager.ELEMENTS.NONE
@export var immune_to_knockback = false

@export var audio_player : AudioStreamPlayer2D
@export var audio_player2 : AudioStreamPlayer2D
@export var good_hit : AudioStream
@export var bad_hit : AudioStream
@export var shield_break : AudioStream

@onready var sprite: Sprite2D = $Sprite2D

var move_speed = 0
var data = {}
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var broken = false
var damage_tic = .2
var time_since_last_damage = 0.0
var contact_damage = true
var direction = 1
var drop_variance = 25
var kb_timer = 0
var detection_range = 400
var action_timer = 0
var combo = 0
var vertical_range = {
	"min": 0,
	"max": 400
}

@onready var armor_sprite = $Armor
@onready var indicator: Node2D = $"Type Indicator"
@onready var interaction: Area2D = $Interaction

var type = TypeManager.ELEMENTS.NONE

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	data = {
	"damage": damage,
	"health": health,
	"armor": armor,
	"base_type": type,
	"armor_type": armor_type,
	"knockback": knockback,
	"immunities": immunities,
	}
	if armor_sprite:
		armor_sprite.hide()
	TypeManager.set_collision_layer_type(self, type)
	if indicator:
		indicator.update()
	
func _process(delta: float) -> void:
	if armor_sprite:
		if armor > 0:
			type = armor_type
			armor_sprite.show()
			indicator.update()
		else:
			type = base_type
			armor_sprite.hide()
			indicator.update()
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if interaction:
		interaction.position.x = abs(interaction.position.x) * -direction
	move_and_slide()
	

func in_range(y):
	return y > vertical_range.min and y < vertical_range.max

func take_damage(dmg, dmg_type, pos, kb = data.knockback):
	if dmg_type in data.immunities:
		return
	var total_dmg = 0
	var res = TypeManager.get_matchup(dmg_type, type)
	var scalar = res.scalar
	total_dmg = dmg * scalar
	audio_player.stream = res.SFX
	print(res.SFX)
	audio_player.play()
	if scalar != 1:
		if scalar > 1:
			#play good sound
			audio_player2.stream = good_hit
			print("Strong Hit")
		elif scalar < 0.6:
			#play bad sound
			audio_player2.stream = bad_hit
			print("Weak Hit")	
		audio_player2.play()
	
	if (armor > 0): 
		armor -= total_dmg
		if armor <= 0:
			audio_player.stream = shield_break
			audio_player.play()
			armor_sprite.hide()
			type = base_type
			TypeManager.set_collision_layer_type(self, type)
	else: 
		health -= total_dmg
		var distance = pos.x - global_position.x
		var dir = -sign(distance)
		if not immune_to_knockback:
			velocity.x = kb.x * dir
			velocity.y = kb.y
	
	print(self.name, ' took ', total_dmg, ' damage. ', health, ' health left')
	var spri = sprite
	
	if armor > 0 and armor_sprite: spri = armor_sprite
	
	if (health <= 0):
		die()


func set_data(meta_data):
	data = meta_data
	health = data.health
	armor = data.armor
	type = base_type
	if armor > 0:
		armor_sprite.show()
		indicator.update()
		type = armor_type
	TypeManager.set_collision_layer_type(self, type)

func contact(p):
	p.take_damage(data.damage, TypeManager.ELEMENTS.NONE, global_position)

func die():
	audio_player.reparent(get_parent())
	audio_player.finished.connect(audio_player.queue_free)
	for item in loot_table:
		var num = randi_range(item.min, item.max)
		for i in range(num):
			var drop = item.scene.instantiate()
			var variance = Vector2(randf_range(-drop_variance, drop_variance), randf_range(-drop_variance, drop_variance))
			drop.position = global_position + variance
			get_tree().get_first_node_in_group("Collectable Layer").add_child(drop)
			
	emit_signal("died")
	queue_free()
