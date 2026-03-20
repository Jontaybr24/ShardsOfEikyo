extends Interactable

@export var reward : Node2D
@export_multiline var follow_up : String
var quest_complete = false
var goal = 200

func _ready() -> void:
	reward.deactivate()

func interact():
	var player = get_tree().get_first_node_in_group("Player")
	if quest_complete or player.data.shards < goal:
		super.interact()
	elif not quest_complete:
		GameManager.text_request("Thank you! Here's your reward.")
		quest_complete = true
		reward.activate()
		my_text.clear()
		my_text.append(follow_up)
