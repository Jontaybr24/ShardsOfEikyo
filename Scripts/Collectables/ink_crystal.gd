extends Collectable

var heal_amount = 5

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.add_ink(heal_amount)
		queue_free()
