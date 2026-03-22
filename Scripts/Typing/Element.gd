extends Resource
class_name Element

@export var name : String
@export var strengths : Array[Element]
@export var weakness : Array[Element]

func get_weak():
	return weakness
	
func get_strong():
	return strengths
	
