extends Area2D
class_name Interactable

@export_multiline var my_text: Array[String]

func interact():
	for line in my_text:
		GameManager.text_request(line)
