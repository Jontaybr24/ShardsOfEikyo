extends Area2D

var tween : Tween
@export var camera : Camera2D
@export var zoom : Vector2

func _ready():
	tween = create_tween()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Tweening")
		tween.tween_property(camera, "zoom", zoom, .2)
