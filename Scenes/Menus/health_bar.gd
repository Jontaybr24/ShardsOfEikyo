extends ProgressBar

var health_chunk = 25

signal size_increased(size)

func increase_health(amount):
	size.x += health_chunk
	max_value += amount
	size_increased.emit(size)
