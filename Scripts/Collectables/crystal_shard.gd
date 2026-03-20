extends Collectable

@export var worth = 1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.add_shards(worth)
		queue_free()
