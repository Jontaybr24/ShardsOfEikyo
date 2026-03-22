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
	[ELEMENTS.INK  , ELEMENTS.SHARD]: {"Scalar": 2.0, "SFX": "Ink to Shard"},
	[ELEMENTS.INK  , ELEMENTS.WOOD ]: {"Scalar": 0.5, "SFX": "Ink to Wood"},
	[ELEMENTS.SHARD, ELEMENTS.INK  ]: {"Scalar": 0.5, "SFX": "Shard to Ink"},
	[ELEMENTS.SHARD, ELEMENTS.WOOD ]: {"Scalar": 2.0, "SFX": "Shard to Wood"},
	[ELEMENTS.SHARD, ELEMENTS.SHARD]: {"Scalar": 1.0, "SFX": "Shard to Shard"},
	[ELEMENTS.WOOD , ELEMENTS.INK  ]: {"Scalar": 2.0, "SFX": "Wood to Ink"},
	[ELEMENTS.WOOD , ELEMENTS.SHARD]: {"Scalar": 0.5, "SFX": "Wood to Shard"},
	[ELEMENTS.FIRE , ELEMENTS.WOOD ]: {"Scalar": 2.5, "SFX": "Fire to Wood"},
}

var DEFAULT = {"Scalar": 1.0, "SFX": "Default Sound"}

func get_matchup(atk_type, def_type) -> Dictionary:
	return matchups.get([atk_type, def_type], DEFAULT)

func get_scalar(atk_type, def_type) -> float:
	var d = get_matchup(atk_type, def_type)
	print("Type Matchup is ", d["SFX"])
	return d["Scalar"]

func get_SFX(atk_type, def_type) -> String:
	var d = get_matchup(atk_type, def_type)
	print("Type Matchup is ", d["SFX"])
	return d["SFX"]
