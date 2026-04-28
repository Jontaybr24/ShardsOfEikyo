extends Area2D
class_name Attack

var offset = 0
var player: Node2D
var hit = false
var multiplier = 1
var bonus = 0
var dir = 1
@export var parent: Node2D
@export var damage = 10
@export var type = TypeManager.ELEMENTS.NONE
@export var start_delay = .1
@export var duration = 0.1
@export var tic_rate = .2
@export var knockback = Vector2()
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite : Sprite2D = $Sprite

var tic_time = 0
var hits = []

signal hit_successful()

func _ready():
	visible = false
	monitoring = false

func flash():
	player = get_tree().get_first_node_in_group("Player")
	visible = true
	monitoring = true
	hits.clear()
	
	await get_tree().create_timer(duration).timeout
	visible = false
	monitoring = false
	bonus = 0
	multiplier = 1
	return hits

func _physics_process(delta: float) -> void:
	if sprite:
		sprite.flip_h = parent.sprite.flip_h
		if sprite.flip_h:
			sprite.rotation = abs(sprite.rotation) * -1
		else:
			sprite.rotation = abs(sprite.rotation)

func inflict_damage(target):
	if target.is_in_group("Enemy") and parent.is_in_group("Enemy"):
		return
	if target.is_in_group('Attackable') and target != parent:
		if damage == null or bonus == null:
			print("Null Flagged")
		target.take_damage((damage + bonus) * multiplier, type, parent.global_position, knockback)
		hit = true
		tic_time = tic_rate

func _on_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	if area.is_in_group("Projectile"):
		if area.type == TypeManager.ELEMENTS.SHARD and type == TypeManager.ELEMENTS.SHARD:
			area.dir *= -1
			area.parried = true
		return
	if type == TypeManager.ELEMENTS.FIRE and area.is_in_group("Flammable"):
		area.take_damage(damage)
	if area.name != "Interaction":
		return
	hits.append(target)
	hit_successful.emit()
	inflict_damage(target)
