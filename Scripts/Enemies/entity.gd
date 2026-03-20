extends CharacterBody2D
class_name Entity

signal died

@export var health = 30
@export var armor = 0
@export var damage = 5
@export var loot_table : Array[LootEntry]
@export var knockback = Vector2(150, -200)
@export var immunities = [ELEMENTS.NONE]
@export var base_type = ELEMENTS.NONE
@export var armor_type = ELEMENTS.NONE
@export var immune_to_knockback = false
@onready var sprite: Sprite2D = $Sprite2D

var move_speed = 0
var data = {}
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var damage_tic = .2
var time_since_last_damage = 0.0
var contact_damage = true
var direction = 1
var drop_variance = 25
var kb_timer = 0

enum ELEMENTS {
	NONE,
	INK,
	ROOT,
	SHARD,
	FIRE,
}
@onready var armor_sprite = $Armor
@onready var indicator: Node2D = $"Type Indicator"
@onready var interaction: Area2D = $Interaction

var type = GameManager.ELEMENTS.NONE

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
	type = base_type
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
	
func damage_scaling(type, dmg_type):
	var multiplier = 1
	var color
	if type == ELEMENTS.SHARD:
		if dmg_type == ELEMENTS.ROOT:
			multiplier = .5
			color = Color.DARK_MAGENTA
		elif dmg_type == ELEMENTS.INK:
			multiplier = 1.5
			color = Color.GOLD
	elif type == ELEMENTS.ROOT:
		if dmg_type == ELEMENTS.SHARD:
			multiplier = 1.5
			color = Color.GOLD
		elif dmg_type == ELEMENTS.INK:
			multiplier = .5
			color = Color.DARK_MAGENTA
	elif type == ELEMENTS.INK:
		if dmg_type == ELEMENTS.ROOT:
			multiplier = 1.5
			color = Color.GOLD
		elif dmg_type == ELEMENTS.SHARD:
			multiplier = .5
			color = Color.DARK_MAGENTA
	else:
		print('No Element Type')
	if multiplier == 1:
		color = Color.RED
	
	return {
		"multiplier": multiplier,
		"color": color
		} 

func take_damage(dmg, dmg_type, pos, kb = data.knockback):
	if dmg_type in data.immunities:
		return
	var total_dmg = 0
	var res = damage_scaling(type, dmg_type)
	total_dmg = dmg * res.multiplier
	
	if (armor > 0): 
		armor -= total_dmg
		if armor <= 0: armor_sprite.hide()
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
	spri.modulate = res.color
	
	
	await get_tree().create_timer(.2).timeout
	
	spri.modulate = Color.WHITE
	
	if (health <= 0):
		die()


func set_data(meta_data):
	data = meta_data
	health = data.health
	armor = data.armor

func contact(p):
	p.take_damage(data.damage, ELEMENTS.NONE, global_position)

func die():
	for item in loot_table:
		var num = randi_range(item.min, item.max)
		for i in range(num):
			var drop = item.scene.instantiate()
			var variance = Vector2(randf_range(-drop_variance, drop_variance), randf_range(-drop_variance, drop_variance))
			drop.position = global_position + variance
			get_tree().get_first_node_in_group("Collectable Layer").add_child(drop)
			
	emit_signal("died")
	queue_free()
