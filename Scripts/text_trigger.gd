extends Area2D
class_name TextTrigger

@export_multiline var text : String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GameManager.text_request(text)
		queue_free()
