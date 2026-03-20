extends CanvasLayer

# amount of seconds it takes to display each character
const CHAR_READ_RATE := 0.05
var tween := create_tween()

@onready var start_symbol = $MarginContainer/MarginContainer2/MarginContainer/HBoxContainer/Start
@onready var textbox = $MarginContainer/MarginContainer2/MarginContainer/HBoxContainer/Text
@onready var end_symbol = $MarginContainer/MarginContainer2/MarginContainer/HBoxContainer/End
@onready var text_container = $MarginContainer

enum State {
	READY,
	READING,
	FINISHED
}

var current_state := State.READY
var text_queue = []

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	GameManager.text_requested.connect(_queue_text)
	#print("Starting state: READY")
	hide_textbox()

func _process(delta):
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
		State.READING:
			if Input.is_action_just_pressed("confirm"):
				tween.kill()
				textbox.visible_ratio = 1
				_on_tween_finished()
		State.FINISHED:
			if Input.is_action_just_pressed("confirm"):
				change_state(State.READY)
				hide_textbox()
				is_queue_empty()

func hide_textbox():
	start_symbol.text = ""
	textbox.text = ""
	end_symbol.text = ""
	text_container.hide()
	visible = false

func show_textbox():
	start_symbol.text = " "
	text_container.show()	
	visible = true
	
func _queue_text(text):
	text_queue.push_back(text)

func display_text():
	var next_text = text_queue.pop_front()
	textbox.text = next_text
	show_textbox()
	reset_tween()
	change_state(State.READING)
	# (Object, Property, target value, transition duration)
	tween.tween_property(textbox, "visible_ratio", 1, len(next_text) * CHAR_READ_RATE).from(0.0)
	tween.finished.connect(_on_tween_finished)

func reset_tween():
	if tween:
		tween.kill()
	tween = create_tween()

func _on_tween_finished():
	change_state(State.FINISHED)
	end_symbol.text = ">"
	end_symbol.show()

func change_state(next_state):
	current_state = next_state
	#match current_state:
		#State.READY:
			#print("State changed: READY")
		#State.READING:
			#print("State changed: READING")
		#State.FINISHED:
			#print("State changed: FINISHED")

func is_queue_empty():
	if text_queue.is_empty():
		GameManager.end_text()
