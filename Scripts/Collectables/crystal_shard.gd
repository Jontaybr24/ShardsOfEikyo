extends Collectable

@export var worth = 1
@export var audio_stream : AudioStream
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.add_shards(worth)
		audio_player.stream = audio_stream
		audio_player.play()
		audio_player.reparent(body)
		audio_player.finished.connect(audio_player.queue_free)
		queue_free()
