extends Node

enum ELEMENTS {
	NONE,
	INK,
	WOOD,
	SHARD,
	FIRE
}

# [Attacking Type, Defending Type]
var matchups = {
	[ELEMENTS.INK  , ELEMENTS.SHARD]: {"scalar": 2.0, "SFX": preload("res://Assets/Audio/ShardFX10.wav")},
	[ELEMENTS.INK  , ELEMENTS.WOOD ]: {"scalar": 0.5, "SFX": preload("res://Assets/Audio/WoodFX2.wav")},
	[ELEMENTS.SHARD, ELEMENTS.INK  ]: {"scalar": 0.5, "SFX": preload("res://Assets/Audio/BadHitFX.wav")},
	[ELEMENTS.SHARD, ELEMENTS.WOOD ]: {"scalar": 2.0, "SFX": preload("res://Assets/Audio/DigFX2.wav")},
	[ELEMENTS.SHARD, ELEMENTS.SHARD]: {"scalar": 1.0, "SFX": preload("res://Assets/Audio/ShardFX1.wav")},
	[ELEMENTS.WOOD , ELEMENTS.INK  ]: {"scalar": 2.0, "SFX": preload("res://Assets/Audio/BadHitFX.wav")},
	[ELEMENTS.WOOD , ELEMENTS.SHARD]: {"scalar": 0.5, "SFX": preload("res://Assets/Audio/ShardFX14.wav")},
	[ELEMENTS.FIRE , ELEMENTS.WOOD ]: {"scalar": 2.5, "SFX": preload("res://Assets/Audio/SwipeFX2.wav")},
}

var DEFAULT = {"scalar": 1.0, "SFX": preload("res://Assets/Audio/HitFX1.wav")}

func get_matchup(atk_type, def_type) -> Dictionary:
	return matchups.get([atk_type, def_type], DEFAULT)

func get_scalar(atk_type, def_type) -> float:
	var d = get_matchup(atk_type, def_type)
	return d["scalar"]

func get_SFX(atk_type, def_type) -> String:
	var d = get_matchup(atk_type, def_type)
	return d["SFX"]
