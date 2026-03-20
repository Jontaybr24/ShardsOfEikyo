extends Node2D

@export var parent : Node2D

@onready var ink: Sprite2D = $Ink
@onready var root: Sprite2D = $Root
@onready var shard: Sprite2D = $Shard


func _ready():
	hide_all()
	if parent:
		if parent.type == GameManager.ELEMENTS.INK: ink.show()
		elif parent.type == GameManager.ELEMENTS.ROOT: root.show()
		elif parent.type == GameManager.ELEMENTS.SHARD: shard.show()

func update():
	hide_all()
	if parent:
		if parent.type == GameManager.ELEMENTS.INK: ink.show()
		elif parent.type == GameManager.ELEMENTS.ROOT: root.show()
		elif parent.type == GameManager.ELEMENTS.SHARD: shard.show()

func hide_all():
	ink.hide()
	root.hide()
	shard.hide()
	
