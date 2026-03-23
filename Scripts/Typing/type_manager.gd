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
	[ELEMENTS.INK  , ELEMENTS.SHARD]: {"scalar": 2.0, "SFX": "Ink to Shard"},
	[ELEMENTS.INK  , ELEMENTS.WOOD ]: {"scalar": 0.5, "SFX": "Ink to Wood"},
	[ELEMENTS.SHARD, ELEMENTS.INK  ]: {"scalar": 0.5, "SFX": "Shard to Ink"},
	[ELEMENTS.SHARD, ELEMENTS.WOOD ]: {"scalar": 2.0, "SFX": "Shard to Wood"},
	[ELEMENTS.SHARD, ELEMENTS.SHARD]: {"scalar": 1.0, "SFX": "Shard to Shard"},
	[ELEMENTS.WOOD , ELEMENTS.INK  ]: {"scalar": 2.0, "SFX": "Wood to Ink"},
	[ELEMENTS.WOOD , ELEMENTS.SHARD]: {"scalar": 0.5, "SFX": "Wood to Shard"},
	[ELEMENTS.FIRE , ELEMENTS.WOOD ]: {"scalar": 2.5, "SFX": "Fire to Wood"},
}

var DEFAULT = {"scalar": 1.0, "SFX": "Default Sound"}

func get_matchup(atk_type, def_type) -> Dictionary:
	return matchups.get([atk_type, def_type], DEFAULT)

func get_scalar(atk_type, def_type) -> float:
	var d = get_matchup(atk_type, def_type)
	return d["scalar"]

func get_SFX(atk_type, def_type) -> String:
	var d = get_matchup(atk_type, def_type)
	return d["SFX"]
