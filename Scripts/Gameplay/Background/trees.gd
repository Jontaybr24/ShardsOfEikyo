extends Sprite2D

@export var tree_textures: Array[Texture2D]
var target_height = 600

func _ready():
	texture = tree_textures.pick_random()
	flip_h = [false, true].pick_random()
	centered = false
	var size = texture.get_size()
	var scalar = target_height / size.y
	scale = Vector2(scalar, scalar) * randf_range(1, 2)
	offset = Vector2(0, -texture.get_height())
